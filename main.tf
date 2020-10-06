provider "aws" {
  profile    = "${var.aws_profile}"
  region     = "${var.aws_region}"
}

resource "aws_iam_role" "fcrepo" {
  name = "fcrepo_role"
  force_detach_policies = true
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Name = "fcrepo_role"
  }
}

data "aws_iam_policy" "aws_beanstalk_web_tier" {
  arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

data "aws_iam_policy" "aws_beanstalk_multicontainer_docker" {
  arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}

data "aws_iam_policy" "aws_beanstalk_worker_tier" {
  arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}

resource "aws_iam_role_policy_attachment" "attach_web_tier" {
  role       = aws_iam_role.fcrepo.name
  policy_arn = data.aws_iam_policy.aws_beanstalk_web_tier.arn
}

resource "aws_iam_role_policy_attachment" "attach_docker" {
  role       = aws_iam_role.fcrepo.name
  policy_arn = data.aws_iam_policy.aws_beanstalk_multicontainer_docker.arn
}

resource "aws_iam_role_policy_attachment" "attach_worker_tier" {
  role       = aws_iam_role.fcrepo.name
  policy_arn = data.aws_iam_policy.aws_beanstalk_worker_tier.arn
}


resource "aws_iam_instance_profile" "fcrepo" {
  name = "fcrepo_instance_profile"
  role = "${aws_iam_role.fcrepo.name}"
}


resource "aws_vpc" "fcrepo" {
 cidr_block  = "10.0.0.0/16"
 enable_dns_hostnames =  true
 tags = {
    Name = "fcrepo_vpc"
  }
}

resource "aws_subnet" "fcrepo" {
 vpc_id      = aws_vpc.fcrepo.id
 cidr_block  = "10.0.0.0/24"
 availability_zone = "${var.aws_region}a"

 tags = { 
    Name = "fcrepo_subnet"
  }
}

resource "aws_subnet" "fcrepo_b" {
 vpc_id      = aws_vpc.fcrepo.id
 cidr_block  = "10.0.1.0/24"
 availability_zone = "${var.aws_region}b"

 tags = {
    Name = "fcrepo_subnet"
  }
}

resource "aws_route_table" "fcrepo" {
  vpc_id = aws_vpc.fcrepo.id
  tags = { 
    Name = "fcrepo_route_table"
  }
}

resource "aws_db_subnet_group" "fcrepo_db_subnet_group" {
  name       = "fcrepo_db_subnet_group"
  subnet_ids = ["${aws_subnet.fcrepo.id}", "${aws_subnet.fcrepo_b.id}"]

  tags = {
    Name = "fcrepo_db_subnet_group"
  }
}

resource "aws_security_group" "fcrepo_database" {
  vpc_id = "${aws_vpc.fcrepo.id}"

  ingress {
    cidr_blocks = ["10.0.0.0/24"]
    from_port   = "${var.db_port}"
    to_port   = "${var.db_port}"
    protocol    = "tcp"
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name   = "fcrepo_db_security_group"
  }
}

resource "aws_db_instance" "fcrepo" {
  identifier           = "fcrepodb"
  depends_on           = [aws_db_subnet_group.fcrepo_db_subnet_group]
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "${var.db_engine}"
  engine_version       = "${var.db_version}"
  port                 = "${var.db_port}" 
  instance_class       = "${var.db_instance_class}"
  name                 = "fcrepo" 
  username             = "${var.db_username}"
  password             = "${var.db_password}"
  db_subnet_group_name = "fcrepo_db_subnet_group"
  vpc_security_group_ids =  [ aws_security_group.fcrepo_database.id ]
  skip_final_snapshot  = "true"
  final_snapshot_identifier = "final-fcrepo-db"

  tags = {
    Name       = "fcrepo_database"
  }
}


resource "aws_route_table_association" "fcrepo" {
  subnet_id      = "${aws_subnet.fcrepo.id}"
  route_table_id = "${aws_route_table.fcrepo.id}"
}

resource "aws_route" "route2igc" {
  route_table_id            = "${aws_route_table.fcrepo.id}"
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = "${aws_internet_gateway.fcrepo.id}"
}

resource "aws_internet_gateway" "fcrepo" {
  vpc_id     = aws_vpc.fcrepo.id
}

resource "aws_security_group" "fcrepo" {
  vpc_id = "${aws_vpc.fcrepo.id}"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 8080 
    to_port     = 8080
    protocol    = "tcp"
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "fcrepo_security_group"
  }
}

resource "aws_cloudwatch_log_group" "fcrepo" {
  name = "/ecs/fcrepo"

  tags = {
    Application = "fcrepo_log_group"
  }
}

resource "aws_s3_bucket" "default" {
  bucket = "fcrepo-aws-deploy.fcrepo-artifacts"
}

resource "aws_s3_bucket_object" "eb_docker_zip" {
  bucket = aws_s3_bucket.default.id
  key    = "fcrepo-6.0.0-SNAPSHOT-eb-docker.zip"
  source = "elasticbeanstalk/fcrepo-6.0.0-SNAPSHOT-eb-docker.zip"
}


resource "aws_elastic_beanstalk_application" "fcrepo" {
  name        = "fcrepo"
  description = "Fedora Repository"

  tags = {
    Name= "fcrepo_beanstalk_application"
  }
}

resource "aws_elastic_beanstalk_application_version" "default" {
  name        = "6.0.0-SNAPSHOT"
  application = aws_elastic_beanstalk_application.fcrepo.name
  description = "application version created by terraform"
  bucket      = aws_s3_bucket.default.id
  key         = aws_s3_bucket_object.eb_docker_zip.id
}


resource "aws_elastic_beanstalk_environment" "fcrepo" {
  depends_on =  [aws_elastic_beanstalk_application_version.default]
  name                = "fcrepo-test-env"
  application         = aws_elastic_beanstalk_application.fcrepo.name
  solution_stack_name = "64bit Amazon Linux 2 v3.1.2 running Docker"
  version_label = aws_elastic_beanstalk_application_version.default.name
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = "${aws_vpc.fcrepo.id}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "${aws_subnet.fcrepo.id}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "SingleInstance"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "SingleInstance"
  }

  setting {
    namespace = "aws:ec2:instances"
    name      = "InstanceTypes"
    value     = "${var.instance_class}"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = "${aws_iam_instance_profile.fcrepo.name}"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = "${var.ec2_keypair}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "FCREPO_DB_URL"
    value     = "jdbc:${var.db_engine}://${aws_db_instance.fcrepo.endpoint}/${aws_db_instance.fcrepo.name}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "FCREPO_DB_USERNAME"
    value     = "${aws_db_instance.fcrepo.username}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "FCREPO_DB_PASSWORD"
    value     = "${aws_db_instance.fcrepo.password}"
  }
}
