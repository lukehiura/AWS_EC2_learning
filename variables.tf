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
  description = "EC2 instance type. Default t2.micro matches the classic 12-month Free Tier Linux offer; use t3.micro if t2 is unavailable in your region (also commonly Free Tier eligible—verify in your account)."
  type        = string
  default     = "t2.micro"
}

variable "root_volume_size_gb" {
  description = "Root gp2 volume size (GiB). Free Tier includes up to 30 GiB gp2 combined for new accounts—keep this small unless you need more."
  type        = number
  default     = 8

  validation {
    condition     = var.root_volume_size_gb >= 8 && var.root_volume_size_gb <= 30
    error_message = "Use between 8 and 30 GiB for a typical Free Tier–friendly root disk."
  }
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

variable "tags" {
  description = "Extra tags merged onto the GitHub CI IAM role (provider default_tags still apply to other resources)."
  type        = map(string)
  default     = {}
}

variable "create_github_actions_ci_role" {
  description = "Create an IAM role this GitHub repo can assume via OIDC. Requires the GitHub OIDC provider to already exist in the account (e.g. from AWS_IAM_learning)."
  type        = bool
  default     = true
}

variable "github_actions_repository" {
  description = "GitHub repository owner/name for the OIDC sub claim (repo:OWNER/NAME:*)."
  type        = string
  default     = "lukehiura/AWS_EC2_learning"
}

variable "github_actions_role_name" {
  description = "IAM role name; use a name distinct from other repos (e.g. IAM learning uses github-actions-terraform)."
  type        = string
  default     = "github-actions-ec2"
}

variable "github_actions_role_policy_arn" {
  description = "Managed policy for CI (broad default for learning; narrow for production)."
  type        = string
  default     = "arn:aws:iam::aws:policy/AdministratorAccess"
}
