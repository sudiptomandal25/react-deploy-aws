# Introduction
This project creates infrastructure in AWS to deploy a node js application in AWS cloud. It uses terraform for provisioning the infrastucture and ansible for setting up
the server to deploy the application in it.


## Table of contents

- Provisioning EC2 instance using the Terraform
- Bootstraping the server
- Deploy the React Application
- Security Considerations



## Provisioning EC2 instance using the Terraform

This project uses Terraform to provision EC2 instance in AWS using Red Hat Enterprise Linux 9 AMI.
main.tf file contains the instructions for provisioning the EC2 instance and it uses variables.tf to fetch the values of some variables.
Create a private key which will be used to SSH into the server. Save the keypair in local machine, associate it with the key pair to be used with the EC2 instance.
A security group created which opens port 22 (SSH), port 3000 (for http requests).
Once the instance is created, inventory.ini is created with the public IP of the instance created.

To run the terraform - run the below commands from the folder:
terraform init

terraform plan

terraform run



## Bootstraping the server

Run the below command which will setup the neccessary softwares on the newly created ec2 instance.

ansible-playbook -i inventory.ini ec2_instances server-setup.yml

Steps performed:
 - Install Git
 - Install node 16 and all the required packages.
 - Install docker and all the required packages.
 
 
 
 
 ## Deploy the React Application
 
 Run the below ansible command to download the repo, build a docker image, and run the container of the image.
 
 ansible-playbook -i inventory.ini ec2_instances deploy-app.yml
 
 Steps Performed:
 - Clone the repo from github for the react app.
 - Build a docker image from the DockerFile present in the repo
 - Run the image to create a pod exposing 3000.
 
 Open browser and goto AWS_PUBLIC_IP:3000
 
 
 
 ## Security consideration
 - Used S3 for storing terraform state
 - AWS credentials were stored as environment variables.
 - personal token for github was stored encrypted in ansible-vault password location set in environment variable.
 - only the specific ports were specified in the security group for the EC2 instance.
 
