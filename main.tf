data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "tls_private_key" "ssh" {
  count     = var.ssh_public_key == null ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

locals {
  public_key_openssh = coalesce(
    var.ssh_public_key,
    try(tls_private_key.ssh[0].public_key_openssh, null)
  )
}

resource "aws_key_pair" "this" {
  key_name   = var.key_name
  public_key = local.public_key_openssh
}

resource "aws_security_group" "ssh" {
  name        = "${var.instance_name}-ssh"
  description = "SSH from allowed CIDR"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "this" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.this.key_name
  vpc_security_group_ids = [aws_security_group.ssh.id]
  subnet_id              = data.aws_subnets.default.ids[0]

  # T3/T3a: standard CPU credits avoids surprise charges from unlimited bursting outside Free Tier.
  dynamic "credit_specification" {
    for_each = startswith(var.instance_type, "t3") ? [1] : []
    content {
      cpu_credits = "standard"
    }
  }

  root_block_device {
    volume_size           = var.root_volume_size_gb
    volume_type           = "gp2"
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = {
    Name = var.instance_name
  }
}
