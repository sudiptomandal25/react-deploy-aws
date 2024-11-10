variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "MyEC2Instance"
}

variable "security_group" {
  description = "Value of the security group for the EC2"
  type = string
  default = "sg-0a32c1aadaced4f7f"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  default = "ec2-key"
}

data "http" "my_public_ip" {
    url = "https://ipv4.icanhazip.com"
    request_headers = {
        Accept = "application/json"
    }
}

locals {
    my_ip = chomp(data.http.my_public_ip.response_body)
}
