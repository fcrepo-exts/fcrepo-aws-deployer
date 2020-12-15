# fcrepo-aws-deployer
A terraform script for automatically deploying a Fedora repository to AWS.
By default, Fedora is deployed on a t3.small instance and is backed by postgresql 12.3  hosted in RDS on
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
terraform apply -var 'aws_profile=<your profile>'  -var 'ec2_keypair=<your ec2 keypair name>' -var 'aws_artifact_bucket_name=<your bucket name>'
```
NB: make sure that the  aws  bucket you designate does not already exist and do not anything in that bucket that you do not want deleted on teardown.

## Tear it down
```
terraform destroy -var 'aws_profile=<your profile>' -var 'ec2_keypair=<your ec2 keypair name>'
```

##  Other variables
See ./variables.tf for a complete list of optional parameters.


