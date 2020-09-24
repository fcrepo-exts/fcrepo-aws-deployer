variable "aws_profile" {
  description = "name of the aws profile"
}

variable "aws_region" {
  description = "The aws region"
  default     = "us-east-1"
}

variable "db_engine" {
  description = "Database engine:  mysql, postgres"
  default     = "mysql"
}

variable "db_port" {
  description = "The port"
  default     = "3306"
}

variable "db_version" {
  description = "The database version"
  default     = "8.0"
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
