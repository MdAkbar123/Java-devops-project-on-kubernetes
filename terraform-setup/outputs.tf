output "public_ip_of_jenkins" {
  value = module.jenkins_server.instance_public_ip
}

output "public_ip_of_k8s_master" {
  value = module.k8s_master.instance_public_ip
}

output "public_ip_of_k8s_worker" {
  value = module.k8s_worker.instance_public_ip
}

output "public_ip_of_sonarqube" {
  value = module.sonarqube_server.instance_public_ip
}

output "public_ip_of_nexus" {
  value = module.nexus_server.instance_public_ip
}

output "public_ip_of_monitoring" {
  value = module.monitoring_server.instance_public_ip
}   
