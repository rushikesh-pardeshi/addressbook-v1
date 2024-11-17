pipeline {
    agent none
    tools {
        maven 'my_maven'
    }
    parameters {
        string(name: 'Env', defaultValue: 'Test', description: 'Environment to deploy')
        booleanParam(name: 'executeTests', defaultValue: true, description: 'Run test cases')
        choice(name: 'APPVERSION', choices: ['1.1', '1.2', '1.3'], description: 'App version to deploy')
    }
    environment {
        DEV_SERVER = 'ec2-user@172.31.1.139'
        IMAGE_NAME = 'rushikeshpardeshi1507/project_image:$BUILD_NUMBER'
        DEPLOY_SERVER = 'ec2-user@172.31.37.236'
    }
    stages {
        stage('Compile') {
            agent any
            steps {
                echo 'Compiling the code'
                echo "Compiling in environment: ${params.Env}"
                sh "mvn compile"
            }
        }

        stage('Unit Test') {
            agent { label 'linux_slave1' }
            when {
                expression {
                    params.executeTests == true
                }
            }
            steps {
                echo 'Running unit tests'
                sh "mvn test"
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }

        stage('Package') {
            agent any
            steps {
                script {
                    sshagent(['ssh-agent']) {
                        withCredentials([usernamePassword(credentialsId: 'docker_login', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                            echo 'Packaging the code'
                            echo "Deploying the app version: ${params.APPVERSION}"
                            
                            // Copy script to the DEV server
                            sh "scp -o StrictHostKeyChecking=no server-script.sh ${DEV_SERVER}:/home/ec2-user"

                            // Run the script, perform Docker login, and push the image
                            sh "ssh -o StrictHostKeyChecking=no ${DEV_SERVER} bash /home/ec2-user/server-script.sh ${IMAGE_NAME}"
                            sh "ssh ${DEV_SERVER} sudo docker login -u ${USERNAME} -p ${PASSWORD}"
                            sh "ssh ${DEV_SERVER} sudo docker push ${IMAGE_NAME}"
                        }
                    }
                }
            }
        }

        stage('Deploy') {
            agent any
            input {
                message "Select the platform to deploy"
                ok "Platform selected"
                parameters {
                    choice(name: 'Platform', choices: ['On-prem', 'EKS', 'EC2'], description: 'Deployment platform')
                }
            }
            steps {
                script {
                    sshagent(['ssh-agent']) {
                        withCredentials([usernamePassword(credentialsId: 'docker_login', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                            echo "Deploying the app version: ${params.APPVERSION}"
                            echo "Running ${IMAGE_NAME} on ${DEPLOY_SERVER}"

                            // Install Docker and deploy the app
                            sh "ssh -o StrictHostKeyChecking=no ${DEPLOY_SERVER} sudo yum install docker -y"
                            sh "ssh ${DEPLOY_SERVER} sudo systemctl start docker"
                            sh "ssh ${DEPLOY_SERVER} sudo docker login -u ${USERNAME} -p ${PASSWORD}"
                            sh "ssh ${DEPLOY_SERVER} sudo docker run -itd -P ${IMAGE_NAME}"
                        }
                    }
                }
            }
        }
    }
}
