pipeline {
    agent none
    tools {
        maven 'my_maven' 
    }
    parameters{
        string(name:'Env',defaultValue:'Test',description:'version to deploy')
        booleanParam(name:'executeTests',defaultValue: true,description:'decide to run tc')
        choice(name:'APPVERSION',choices:['1.1','1.2','1.3'])

    }
    environment{
        DEV_SERVER='ec2-user@172.31.1.139'
        IMAGE_NAME='rushikeshpardeshi1507/project_image:$BUILD_NUMBER'
    }
    stages {
        stage('Compile') {
            agent any
            steps {
                echo 'Compiling the code'
                echo "compiling in env: ${params.Env}"
                sh "mvn compile"

            }
        }
        //  stage('CodeReview') {
        //     agent any
        //     steps {
        //         echo 'Reviewing the code'
        //         echo "Deploying the app version ${params.APPVERSION}"
        //         sh "mvn pmd:pmd"
        //     }
        //     // post{
        //     //     always{
        //     //         pmd pattern: 'target/pmd.xml'
        //     //     }
        //     // }
        // }
         stage('UniTest') {
           agent {label 'linux_slave1'}
            when{
                expression{
                    params.executeTests == true
                }
            }
            
            steps {
                echo 'UnitTest the code'
                sh "mvn test"
            }
            post{
                always{
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }

         stage('Package') {
            //agent {label 'linux_slave'}
            agent any
            steps {
                script{
                sshagent(['shh-agent-4']) {
                withCredentials([usernamePassword(credentialsId: 'docker_login', passwordVariable: 'PASSWORD', usernameVariable: 'USER_NAME')]) 
                echo 'Package the code'
                echo "Deploying the app version ${params.APPVERSION}"
                // scp for copy script from jenkin server to new ssh agent
                sh "scp -o StrictHostKeyChecking=no server-script.sh ${DEV_SERVER}:/home/ec2-user"
                // sh "ssh -o StrictHostKeyChecking=no ${DEV_SERVER} 'bash /home/ec2-user/server-script.sh'"
                sh "ssh -o StrictHostKeyChecking=no ${DEV_SERVER} bash /home/ec2-user/server-script.sh ${IMAGE_NAME}"
                sh "ssh ${DEV_SERVER} sudo docker login -u ${USER_NAME} -p ${PASSWORD}"
                sh "ssh ${DEV_SERVER} sudo docker push ${IMAGE_NAME}"
            }
        }
            }
         }
          stage('Deploy') {
            agent any
            input{
                message "Select the platform to deploy"
                ok "Platform selected"
                parameters{
                    choice(name:'Platform',choices:['On-prem','EKS','EC2'])
                }
            }
            steps {
                echo 'Deploy the code'
                echo "Deploying the app version ${params.APPVERSION}"
                echo "Deploying on ${params.Platform}"
            }
        }
    }
}
