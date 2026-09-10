pipeline {
    agent any

    stages {

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan'
            }
        }

        stage('Terraform Apply') {
            steps {
                input message: 'Do you want to create EKS Cluster and Node Group?', ok: 'Apply'

                sh 'terraform apply -auto-approve'
            }
        }
    }

    post {
        success {
            echo 'EKS Cluster and Node Group created successfully!'
        }

        failure {
            echo 'Terraform deployment failed!'
        }
    }
}

