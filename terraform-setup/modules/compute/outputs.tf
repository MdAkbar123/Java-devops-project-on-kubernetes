
output "instance_id" {
  value = aws_instance.server.id
}
# terraform/modules/compute/outputs.tf

output "instance_public_ip" {
  description = "Public IP of the EC2 instances"
  value       = aws_instance.server.public_ip
}