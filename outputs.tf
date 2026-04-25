output "instance_id" {
  description = "EC2 instance ID."
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "Public IPv4 address for SSH."
  value       = aws_instance.this.public_ip
}

output "ssh_user" {
  description = "SSH username on Amazon Linux 2023."
  value       = "ec2-user"
}

output "ssh_command" {
  description = "Example SSH command (use private key from private_key_pem output or your own .pem)."
  value       = "ssh -i learning-ec2.pem ec2-user@${aws_instance.this.public_ip}"
}

output "private_key_pem" {
  description = "RSA private key PEM when Terraform generated the key (null if ssh_public_key was set). Save once, e.g. terraform output -raw private_key_pem > learning-ec2.pem && chmod 400 learning-ec2.pem. Key is in state — protect state."
  value       = try(tls_private_key.ssh[0].private_key_pem, null)
  sensitive   = true
}
