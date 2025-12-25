# --------------------------
# SSH Key Pair Generation
# --------------------------
resource "tls_private_key" "deploy" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deploy" {
  key_name   = var.key_name
  public_key = tls_private_key.deploy.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.deploy.private_key_pem
  filename        = var.private_key_path
  file_permission = "0400"
}

output "generated_key_name" {
  value = aws_key_pair.deploy.key_name
}



module "vpc" {
  source = "./modules/vpc"
  vpc_cidr = "10.0.0.0/16"
}


module "security" {
  source = "./modules/security"
  vpc_id = module.vpc.vpc_id  # Passes the VPC ID created above to the security module
}

module "jenkins_server" {
  source          = "./modules/compute"
  instance_name   = "Jenkins-Server"
  instance_type   = "t2.large"
  security_group  = module.security.jenkins_sg_id
  subnet_id       = module.vpc.public_subnet_id

  key_name        = aws_key_pair.deploy.key_name
}

module "k8s_master" {
  source          = "./modules/compute"
  instance_name   = "K8s-Master"
  instance_type   = "t2.medium"
  security_group  = module.security.k8s_master_sg_id 
  subnet_id       = module.vpc.public_subnet_id
#   user_data_script = "scripts/install_k8s.sh"
  key_name        = aws_key_pair.deploy.key_name
}

module "k8s_worker" {
  source          = "./modules/compute"
  instance_name   = "K8s-Worker"
  instance_type   = "t2.medium"
  security_group  = module.security.k8s_worker_sg_id
  subnet_id       = module.vpc.public_subnet_id

  key_name        = aws_key_pair.deploy.key_name
#   user_data_script = "scripts/install_k8s_worker.sh"
}

module "sonarqube_server" {
  source          = "./modules/compute"
  instance_name   = "SonarQube-Server"
  instance_type   = "t2.medium"
  security_group  = module.security.sonarqube_sg_id
  subnet_id       = module.vpc.public_subnet_id
#   user_data_script = "scripts/install_sonarqube.sh"

  key_name        = aws_key_pair.deploy.key_name
}

module "nexus_server" {
  source          = "./modules/compute"
  instance_name   = "Nexus-Server"
  instance_type   = "t2.medium"
  security_group  = module.security.nexus_sg_id
  subnet_id       = module.vpc.public_subnet_id
#   user_data_script = "scripts/install_nexus.sh"
  key_name        = aws_key_pair.deploy.key_name
}

module "monitoring_server" {
  source          = "./modules/compute"
  instance_name   = "Monitoring-Server"
  instance_type   = "t2.micro"
  security_group  = module.security.monitoring_sg_id
  subnet_id       = module.vpc.public_subnet_id
#   user_data_script = "scripts/install_monitoring.sh"
  key_name        = aws_key_pair.deploy.key_name
}