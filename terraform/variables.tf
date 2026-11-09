variable "aws_region" { type = string, default = "us-east-1" }
variable "project_name" { type = string, default = "ec2-web-lab" }
variable "allowed_http_cidr" {
  description = "CIDR allowed to access the demo HTTP page. Set to your public IP /32."
  type = string
  default = "203.0.113.10/32"
}
variable "instance_type" { type = string, default = "t3.micro" }
