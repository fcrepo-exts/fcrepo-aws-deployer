//
//
//

variable "aws_profile" {
  description = "name of the aws profile"
  default     = "default"
}

variable "aws_region" {
  description = "The aws region"
  default     = "us-east-1"
}

variable "app_name" {
  description = "The application name"
  default     = "fcrepo"
}

variable "app_environment" {
  description = "The application environment"
  default     = "staging"
}

variable "aws_artifact_bucket_name" {
  description = "An AWS S3 bucket name for staging generated beanstalk application artifacts for deployment. This bucket should should not exist prior to running 'terraform apply ...'. Additionally, any objects placed in the bucket will be destroyed on 'terraform destroy...'."
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
  description = "The database version: default 17.7 - current versions: postgresql 12.22, mariadb 10.5.26+, mysql 8.0.32+"
  default     = "17.7"
}

variable "db_instance_class" {
  description = "The database instance class"
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "database name"
  default     = "fedora"
}

variable "db_username" {
  description = "database username"
  default     = "fedora"
}

variable "db_password" {
  description = "database password"
  default     = "fedora-pw"
}

variable "volume_id" {
  description = "The Id of the volume to be used for data storage. If the volume already exists, it will not be destroyed when the infrastructure is destroyed"
  default     = ""
}

variable "new_volume_size" {
  description = "The size of a new volume to be used for data storage (in GB). By default it will be destroyed when the infrastructure is destroyed (change behaviour with delete_new_volume_at_exit variable) "
  default     = 10
}

variable "delete_new_volume_at_exit" {
  description = "The new volume will be destroyed when the infrastructure is destroyed"
  default     = true
}

variable "instance_class" {
  description = "The Fedora ec2 instance class"
  default     = "t3.small"
}

# https://docs.aws.amazon.com/elasticbeanstalk/latest/platforms/platform-history-docker.html
variable "eb_solution_stack_name" {
  default = "64bit Amazon Linux 2023 v4.8.0 running Docker"
}

# keypairs are region specific
variable "ec2_keypair" {
  description = "The EC2 keypair to use if you want to access the instance."
}

//
// end of file
//