# fcrepo-aws-deployer
A terraform script for automatically deploying a Fedora repository to AWS.
By default, Fedora is deployed on a t3.small instance and is backed by mysql 8.0 hosted in RDS on
a db.t2.micro instance.

## Requirements
terraform  (https://www.terraform.io/downloads.html)

## Installation

After installing terraform 
```
git clone https://github.com/lyrasis/fcrepo-terraform
terraform init
```

Then set up an aws profile in ~/.aws/config
(c.f. https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html)

## Deploy Fedora
```
terraform apply -var 'aws_profile=<your profile>'  -var 'ec2_keypair=<your ec2 keypair name>'
```
## Tear it ddown
```
terraform destroy -var 'aws_profile=<your profile>' -var 'ec2_keypair=<your ec2 keypair name>'
```

##  Other variables
See ./variables.tf for a complete list of optional parameters.


