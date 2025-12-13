resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow Port 8080 for Jenkins"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "k8s_master_sg" {
    name        = "k8s-master-sg"
    description = "Security group for Kubernetes control plane"
    vpc_id      = var.vpc_id

  # --- SSH Access for Ansible ---
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound: allow all
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "k8s_worker_sg" {
  name        = "k8s-worker-sg"
  description = "Security group for Kubernetes worker nodes"
  vpc_id      = var.vpc_id

# --- SSH Access for Ansible ---
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # --- Egress (Allow all) ---
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ==========================================
# Rules for MASTER Nodes
# ==========================================

# Allow API Access from Workers
resource "aws_security_group_rule" "master_api_from_worker" {
  type                     = "ingress"
  from_port                = 6443
  to_port                  = 6443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.k8s_worker_sg.id
  security_group_id        = aws_security_group.k8s_master_sg.id
}

# Allow API Access from Laptop/CIDR (Example)
resource "aws_security_group_rule" "master_api_from_cidr" {
  type              = "ingress"
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  cidr_blocks       = var.cidr_blocks
  security_group_id = aws_security_group.k8s_master_sg.id
}

# Allow ETCD communication (Master <-> Master/Worker)
resource "aws_security_group_rule" "master_etcd" {
  type                     = "ingress"
  from_port                = 2379
  to_port                  = 2380
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.k8s_worker_sg.id
  security_group_id        = aws_security_group.k8s_master_sg.id
}

# Allow Kubelet API (Master <-> Master)
resource "aws_security_group_rule" "master_kubelet_self" {
  type                     = "ingress"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.k8s_master_sg.id
  security_group_id        = aws_security_group.k8s_master_sg.id
}

# ==========================================
# Rules for WORKER Nodes
# ==========================================

# Allow Kubelet API from Master
resource "aws_security_group_rule" "worker_kubelet_from_master" {
  type                     = "ingress"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.k8s_master_sg.id
  security_group_id        = aws_security_group.k8s_worker_sg.id
}

# Allow NodePort Services (External Access)
resource "aws_security_group_rule" "worker_nodeports" {
  type              = "ingress"
  from_port         = 30000
  to_port           = 32767
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.k8s_worker_sg.id
}

# Allow CNI (Pod Network) - Self Referencing
resource "aws_security_group_rule" "worker_cni_tcp" {
  type                     = "ingress"
  from_port                = 179  # Example for Calico BGP
  to_port                  = 179
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.k8s_worker_sg.id
  security_group_id        = aws_security_group.k8s_worker_sg.id
}

resource "aws_security_group_rule" "worker_cni_udp" {
  type                     = "ingress"
  from_port                = 8472 # Example for Flannel VXLAN
  to_port                  = 8472
  protocol                 = "udp"
  source_security_group_id = aws_security_group.k8s_worker_sg.id
  security_group_id        = aws_security_group.k8s_worker_sg.id
}

resource "aws_security_group" "sonarqube_sg" {
  name        = "sonarqube-sg"
  description = "Security group for SonarQube server"
  vpc_id      = var.vpc_id

  # --- SSH Access for Ansible ---
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Web UI + API (Port 9000)
  ingress {
    description = "SonarQube Web UI / API"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks
  }

  # (Optional) Additional Sonar service port
#   ingress {
#     description = "SonarQube optional service"
#     from_port   = 9001
#     to_port     = 9001
#     protocol    = "tcp"
#     cidr_blocks = ["YOUR_IP/32"]
#   }

  # Egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "nexus_sg" {
  name        = "nexus-server-sg"
  description = "Security group for Nexus Repository Manager"
  vpc_id      = var.vpc_id

# --- SSH Access for Ansible ---
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # --- Nexus UI / API / Repositories ---
  ingress {
    description = "Nexus Web UI / API / Repository endpoints"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks # Or CI server SGs
  }

  # --- Docker Registry (Optional Hosted Registry) ---
  ingress {
    description = "Docker Registry custom port"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks  # Never open to world
  }

  # --- Additional Nexus ports (Optional 8082/8083 if using reverse proxy setup) ---
  ingress {
    description = "Additional Nexus HTTPS / Proxy ports (optional)"
    from_port   = 8082
    to_port     = 8083
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks
  }

  # --- Egress (Allow all) ---
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "monitoring_sg" {
  name        = "monitoring-server-sg"
  description = "Security group for Prometheus, Grafana, Alertmanager"
  vpc_id      = var.vpc_id

  # Grafana
  ingress {
    description = "Grafana Web UI"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks
  }

  # Prometheus
  ingress {
    description = "Prometheus Web UI/API"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks
  }

  # --- SSH Access for Ansible ---
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "monitoring_alertmanager_9093" {
  type                     = "ingress"
  from_port                = 9093
  to_port                  = 9093
  protocol                 = "tcp"
  security_group_id        = aws_security_group.monitoring_sg.id
  source_security_group_id = aws_security_group.monitoring_sg.id
}

resource "aws_security_group_rule" "monitoring_alertmanager_9094" {
  type                     = "ingress"
  from_port                = 9094
  to_port                  = 9094
  protocol                 = "tcp"
  security_group_id        = aws_security_group.monitoring_sg.id
  source_security_group_id = aws_security_group.monitoring_sg.id
}
