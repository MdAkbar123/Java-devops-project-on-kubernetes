pipeline {
    agent any

    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        ENABLE_TRIVY = "true"
    }

    tools {
        jdk 'jdk17'
        maven 'maven3'
    }

    stages {

        stage('Git Checkout') {
            steps {
                git branch: 'main',
                    credentialsId: 'git-cred',
                    url: 'https://github.com/MdAkbar123/Boardgame.git'
            }
        }

        stage('Compile') {
            steps {
                sh 'mvn compile'
            }
        }

        stage('Test') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Install Trivy') {
            steps {
                // Installs Trivy locally in the workspace
                sh '''
                if [ ! -f trivy ]; then
                    echo "Installing Trivy locally..."
                    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh
                    mv ./bin/trivy ./trivy
                else
                    echo "Trivy already present"
                fi
                '''
            }
        }

        stage('Trivy File System Scan') {
            when {
                expression { env.ENABLE_TRIVY == "true" }
            }
            steps {
                sh "./trivy fs --format table -o trivy-fs-report.html ."
            }
        }

        
        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool 'sonar-scanner'

                    withSonarQubeEnv('SonarQube-Server') {
                        sh """
                        #!/bin/bash
                        set -e

                        ${scannerHome}/bin/sonar-scanner \
                            -Dsonar.projectKey=BoardGame \
                            -Dsonar.projectName=BoardGame \
                            -Dsonar.javascript.enabled=false \
                            -Dsonar.typescript.enabled=false
                        """
                    }
                }
            }
        }




        stage('Quality Gate') {
            steps {
                waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn package'
            }
        }

        stage('Publish Artifacts to Nexus') {
            steps {
                withMaven(
                    maven: 'maven3',
                    globalMavenSettingsConfig: 'global-settings'
                ) {
                    sh 'mvn clean deploy'
                }
            }
        }

        stage('Build and Tag Docker Image') {
            steps {
                // FIXED: Added url: '' (Empty string denotes Docker Hub)
                withDockerRegistry(credentialsId: 'docker-hub-cred', url: '') {
                    sh 'docker build -t akbar00/boardgame:latest .'
                }
            }
        }

        stage('Docker Image Scan') {
            when {
                expression { env.ENABLE_TRIVY == "true" }
            }
            steps {
                sh '''
                export TRIVY_SKIP_DB_UPDATE=true
                export TRIVY_SKIP_JAVA_DB=true
                ./trivy image \
                    --scanners vuln \
                    --exit-code 0 \
                    --format table \
                    -o trivy-image-report.html \
                    akbar00/boardgame:latest
                '''
            }
        }


        stage('Push Docker Image') {
            steps {
                // FIXED: Added url: '' (Empty string denotes Docker Hub)
                withDockerRegistry(credentialsId: 'docker-hub-cred', url: '') {
                    sh 'docker push akbar00/boardgame:latest'
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withKubeConfig(
                    credentialsId: 'k8-cred',
                    namespace: 'webapps',
                    // NOTE: Ensure you replace <K8S_MASTER_IP> with your actual IP
                    serverUrl: 'https://10.0.1.91:6443'
                ) {
                    sh 'kubectl apply -f deployment-service.yaml'
                    sh 'kubectl get pods -n webapps'
                }
            }
        }
    }

    post {
        always {
            script {
                def jobName = env.JOB_NAME
                def buildNumber = env.BUILD_NUMBER
                def pipelineStatus = currentBuild.result ?: 'SUCCESS'
                def bannerColor = pipelineStatus == 'SUCCESS' ? 'green' : 'red'

                def body = """
                <html>
                <body>
                    <p><b>${jobName} - Build #${buildNumber}</b></p>
                    <p>Status:
                       <b style="color:${bannerColor};">
                       ${pipelineStatus}
                       </b>
                    </p>
                    <p>
                      <a href="${env.BUILD_URL}">View Console Output</a>
                    </p>
                </body>
                </html>
                """

                emailext(
                    subject: "${jobName} - Build ${buildNumber} - ${pipelineStatus}",
                    body: body,
                    to: 'iamakbar816@gmail.com',
                    from: 'iamakbar816@gmail.com',
                    replyTo: 'iamakbar816@gmail.com',
                    mimeType: 'text/html',
                    attachmentsPattern: 'trivy-image-report.html'
                )
            }
        }
    }
}