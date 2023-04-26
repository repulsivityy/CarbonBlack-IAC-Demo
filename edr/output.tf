output "Deployment" {
  value = "Finalizing configuration may take up to 20 minutes after deployment is finished."
}

output "public_IP" {
  value = aws_eip.edr_eip.public_ip
}
output "private_ip" {
  value = aws_instance.edr_server.private_ip
}

output "instance_id" {
  description = "AWS ID for the EC2 instance used"
  value       = aws_instance.edr_server.id
}

output "security_group_id" {
  description = "Security Group ID"
  value       = aws_security_group.edr_sg.id
}