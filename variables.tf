variable "aws_profile" {
  description = "name of the aws profile"
}

variable "aws_region" {
  description = "The aws region"
  default     = "us-east-1"
}

variable "aws_artifact_bucket_name" {
  description = "An AWS S3 bucket name for staging generated beanstalk application artifacts for deployment. This bucket should should not exist prior to running 'terraform apply ...'. Additionally, any objects placed in the bucket   will be destroed on 'terraform destroy...'."
}

variable "fcrepo_version" {
  description = "The docker version of Fedora"
  default     = "latest"
}

variable "db_engine" {
  description = "Database engine:  postgresql, mariadb, mysql: default = postgresql"
  default     = "postgresql"
}

variable "db_port" {
  description = "The port"
  default     = "5432"
}

variable "db_version" {
  description = "The database version: default 12.3 - supported  versions: postgresql 12.3, mariadb 10.5.3, mysql 8.0"
  default     = "12.3"
}

variable "db_instance_class" {
  description = "The database instance class"
  default     = "db.t2.micro"
}

variable "db_username" {
  description = "database username"
  default     = "fcrepo"
}

variable "db_password" {
  description = "database password"
  default     = "fcrepo-pw"
}

variable "instance_class" {
  description = "The Fedora ec2 instance class"
  default     = "t3.small"
}

variable "ec2_keypair" {
  description = "The EC2 keypair to use in case you want to access the instance."
}
