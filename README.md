# End-to-End DevSecOps Pipeline: Deployment of Java Application on Kubernetes


## 🚀 Project Overview
This project demonstrates a robust **DevSecOps CI/CD pipeline** for a Java-based application ("BoardGame"). It automates the entire software delivery lifecycle—from infrastructure provisioning to production deployment and monitoring—using industry-standard tools.

The infrastructure is hosted on **AWS**, provisioned via **Terraform**, configured using **Ansible**, and orchestrated by **Jenkins**. The application is deployed to a **Kubernetes cluster** with integrated monitoring and security scanning.

---

## 🛠️ Tech Stack & Tools

| Category | Tools Used |
| :--- | :--- |
| **Cloud Provider** | AWS (EC2, VPC, Security Groups) |
| **IaC (Infrastructure as Code)** | Terraform |
| **Config Management** | Ansible |
| **CI/CD Orchestration** | Jenkins (Declarative Pipeline) |
| **Containerization** | Docker |
| **Orchestration** | Kubernetes (Self-managed Cluster with Kubeadm) |
| **Build Tool** | Maven (JDK 17) |
| **Code Quality** | SonarQube |
| **Security Scanning** | Trivy (Filesystem & Image Scan) |
| **Artifact Management** | Nexus Repository Manager |
| **Monitoring** | Prometheus & Grafana (Helm Stack) |

---

## 🏗️ Infrastructure Architecture

We used **Terraform** to provision 5 AWS EC2 instances and **Ansible** to configure software dependencies (Java, Docker, Kubeadm, etc.) on them.

**The 5 Instances:**
1.  **Jenkins Server:** The heart of the CI/CD pipeline.
2.  **SonarQube Server:** Dedicated server for static code analysis.
3.  **Nexus Server:** Centralized artifact repository for storing JARs and dependencies.
4.  **K8s Master Node:** Control plane for the Kubernetes cluster.
5.  **K8s Worker Node:** Compute node where the application runs.

---

## 🔄 The CI/CD Pipeline (Jenkins)

The pipeline is defined in a `Jenkinsfile` using Groovy syntax. It implements a **"Build Once, Deploy Anywhere"** strategy with integrated security gates.

### Pipeline Stages Breakdown:

1.  **Git Checkout**: Pulls the latest source code from the `main` branch.
2.  **Compile**: Compiles the Java source code using Maven.
3.  **Unit Test**: Runs unit tests (`mvn test`) to ensure code integrity.
4.  **Trivy FS Scan**: Scans the filesystem for vulnerabilities before building (Security First).
5.  **SonarQube Analysis**: Performs static analysis to detect bugs, code smells, and vulnerabilities.
6.  **Quality Gate**: **Stops the pipeline** if the code fails the defined quality rules in SonarQube (e.g., coverage < 80%).
7.  **Build**: Packages the application into a `.jar` file (`mvn package`).
8.  **Publish to Nexus**: Uploads the generated `.jar` to the Nexus Repository for version control.
9.  **Docker Build & Tag**: Builds the container image `akbar00/boardgame:latest`.
10. **Docker Image Scan**: Uses Trivy to scan the final Docker image for OS/Library vulnerabilities.
11. **Push Docker Image**: Pushes the secure image to Docker Hub.
12. **Deploy to Kubernetes**:
    * Connects to the K8s Master.
    * Deploys the application to the `webapps` namespace using `deployment-service.yaml`.
    * Updates the deployment with the new image.

### 📧 Post-Build Actions
* **Email Notifications:** Automatically sends an email with the build status (Success/Failure) and a link to the console logs.
* **Reports:** Attaches the Trivy vulnerability report (`trivy-image-report.html`) to the email.

---

## 📊 Monitoring & Observability

We implemented a full observability stack directly on the Kubernetes cluster using **Helm**.

* **Prometheus:** Scrapes metrics from the cluster, nodes, and pods.
* **Grafana:** Visualizes the data with rich dashboards.
    * **Cluster Monitoring:** CPU/Memory usage of Master/Worker nodes.
    * **Workload Monitoring:** Real-time status of the `boardgame` pods.
    * **Network I/O:** Visualizing traffic spikes during load testing.

---

## 🚀 How to Run

1.  **Infrastructure:**
    ```bash
    cd terraform/
    terraform init
    terraform apply --auto-approve
    ```
2.  **Configuration:**
    ```bash
    ansible-playbook -i inventory.ini playbook.yml
    ```
3.  **Deployment:**
    * Commit changes to the repository.
    * Jenkins automatically triggers the pipeline.
    * Access the app at `http://<WORKER-NODE-IP>:30005`.

---

## 👤 Author
**Md Akbar**
* [LinkedIn Profile](https://www.linkedin.com/in/md-akbar-ali0/)
* [GitHub Profile](https://github.com/MdAkbar123)
