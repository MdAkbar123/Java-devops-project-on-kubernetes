output "jenkins_sg_id" {
  value = aws_security_group.jenkins_sg.id
}
output "k8s_master_sg_id" {
  value = aws_security_group.k8s_master_sg.id
}
output "k8s_worker_sg_id" {
  value = aws_security_group.k8s_worker_sg.id
}
output "sonarqube_sg_id" {
  value = aws_security_group.sonarqube_sg.id
}
output "nexus_sg_id" {      
  value = aws_security_group.nexus_sg.id
} 
output "monitoring_sg_id" {
  value = aws_security_group.monitoring_sg.id
}

