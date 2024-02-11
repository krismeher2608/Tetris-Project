pipeline {
    agent any
    tools{
        jdk 'jdk17'
        nodejs 'node16'
    }
    environment {
        SCANNER_HOME=tool 'sonar-scanner'
        GIT_REPO_NAME= "Tetris-Project"
        GIT_USER_NAME="krismeher2608"
    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/krismeher2608/Tetris-Project.git'
            }
        }
        stage('Sonar analysis') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=TetrisVersion1 \
                    -Dsonar.projectKey=TetrisVersion1 '''
                }
            }
        }
        stage('Quality Gate') {
            steps {
                script{
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token'
                }
            }
        }
        stage('NPM') {
            steps {
                sh 'npm install'
            }
        }
        stage('trivy scan') {
            steps {
                sh 'trivy fs . > trivy.txt'
            }
        }
        stage('OWASP FS SCAN') {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'owasp-dependency-check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        stage('Docker build') {
            steps {
                script {
                    withDockerRegistry(credentialsId: 'docker', toolName: 'docker') {
                        sh '''
                        docker build -t tetrisv1 .
                        docker tag tetrisv1 krishnameher26/tetrisv1:latest
                        docker push krishnameher26/tetrisv1:latest
                        '''
                    }
                }
            }
        }
        stage('trivy image scan') {
            steps {
                sh 'trivy image krishnameher26/tetrisv1:latest > trivyimage.txt'
            }
        }
        stage('Update Deployment File') {
            steps {
                dir('deployment'){
                script {
                    withCredentials([string(credentialsId: 'github', variable: 'GITHUB_TOKEN')]) {
                        // Determine the image name dynamically based on your versioning strategy
                        NEW_IMAGE_NAME = "krishnameher26/tetrisv1:latest"
                        // Replace the image name in the deployment-service.yaml file
                        sh "sed -i 's|image: .*|image: $NEW_IMAGE_NAME|' deployment-service.yml"
                        // Git commands to stage, commit, and push the changes
                        sh 'git add deployment-service.yml'
                        sh "git commit -m 'Update deployment image to $NEW_IMAGE_NAME'"
                        sh "git push https://${GITHUB_TOKEN}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME} HEAD:main"
                        }   
                    }
                }
            }
        }
    }
}
