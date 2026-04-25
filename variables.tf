variable "aws_region" {
  description = "AWS region for the instance and provider."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Tag value for Project on created resources."
  type        = string
  default     = "ec2-learning"
}

variable "instance_name" {
  description = "Value for the Name tag on the EC2 instance."
  type        = string
  default     = "learning-ec2"
}

variable "instance_type" {
  description = "EC2 instance type (e.g. t3.micro for Free Tier eligible in many accounts)."
  type        = string
  default     = "t3.micro"
}

variable "allowed_ssh_cidr" {
  description = "IPv4 CIDR allowed to SSH (port 22). Prefer your public IP /32, e.g. 203.0.113.10/32 — not 0.0.0.0/0 in production."
  type        = string
  default     = "0.0.0.0/0"
}

variable "ssh_public_key" {
  description = "If non-null, use this OpenSSH public key string for aws_key_pair instead of generating a new private key in Terraform state."
  type        = string
  default     = null
}

variable "key_name" {
  description = "AWS EC2 key pair name (logical name in AWS)."
  type        = string
  default     = "learning-ec2-key"
}
