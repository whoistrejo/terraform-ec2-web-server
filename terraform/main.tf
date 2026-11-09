data "aws_ami" "al2023" {
  most_recent = true
  owners = ["amazon"]
  filter { name = "name", values = ["al2023-ami-2023.*-x86_64"] }
  filter { name = "architecture", values = ["x86_64"] }
}
resource "aws_vpc" "main" {
  cidr_block = "10.20.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = { Name = "${var.project_name}-vpc" }
}
resource "aws_internet_gateway" "main" { vpc_id = aws_vpc.main.id }
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.20.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[0]
}
data "aws_availability_zones" "available" { state = "available" }
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route { cidr_block = "0.0.0.0/0", gateway_id = aws_internet_gateway.main.id }
}
resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
resource "aws_security_group" "web" {
  name = "${var.project_name}-web"
  description = "Restricted HTTP ingress"
  vpc_id = aws_vpc.main.id
  ingress { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = [var.allowed_http_cidr] }
  egress { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
}
resource "aws_instance" "web" {
  ami = data.aws_ami.al2023.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]
  user_data = <<-EOF
    #!/bin/bash
    dnf install -y httpd
    systemctl enable --now httpd
    echo '<h1>Terraform EC2 Web Lab</h1><p>Amazon Linux 2023</p>' > /var/www/html/index.html
  EOF
  metadata_options { http_tokens = "required" }
  root_block_device { encrypted = true, volume_type = "gp3", volume_size = 8 }
  tags = { Name = "${var.project_name}-instance" }
}
output "instance_id" { value = aws_instance.web.id }
output "public_ip" { value = aws_instance.web.public_ip }
output "url" { value = "http://${aws_instance.web.public_ip}" }
