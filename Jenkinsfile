pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'flask-calculator:latest'
        DOCKERHUB_USERNAME = 'mahendra4774'
        DOCKERHUB_ACCESS_TOKEN = credentials('dockerhub-access-token')
        DOCKER_REGISTRY = 'mahendra4774/python-app'
    }

    stages {

        stage('Checkout/source') {
            steps {
                git 'https://github.com/akulamahendra/python-app.git'
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -out=tfplan'
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve'
            }
        }

        stage('Sleep 120') {
            steps {
                sh 'sleep 120'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "sudo docker build -t ${DOCKER_IMAGE} ."
                }
            }
        }

        stage('Test') {
            steps {
                script {
                    sh """
                    sudo docker run --name test-container ${DOCKER_IMAGE} /bin/sh -c 'python -m unittest discover -s /app/tests'
                    sudo docker rm test-container
                    """
                }
            }
        }

        stage('Push to Docker Registry') {
            steps {
                script {
                    sh """
                    echo ${DOCKERHUB_ACCESS_TOKEN} | sudo docker login -u ${DOCKERHUB_USERNAME} --password-stdin

                    sudo docker tag ${DOCKER_IMAGE} ${DOCKERHUB_USERNAME}/${DOCKER_IMAGE}

                    sudo docker push ${DOCKERHUB_USERNAME}/${DOCKER_IMAGE}
                    """
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    sh """
                    sudo docker run -d -p 5000:80 ${DOCKER_IMAGE}
                    """
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline executed successfully!'
        }

        failure {
            echo 'Pipeline failed.'
        }
    }
}