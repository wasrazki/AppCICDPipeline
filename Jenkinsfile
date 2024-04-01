pipeline{
    agent{
        label "jenkins-agent"
    }
    tools{
        jdk 'java17'
        maven 'Maven3'
    }
    environment{
        APP_NAME="MyCICDPipeline"
        RELEASE="1.0.0"
        DOCKER_USER="wasraz"
        DOCKER_PASS="vault-dockerhub-access-token"
        IMAGE_NAME="${DOCKER_USER}"+"/"+"${APP_NAME}"
        IMAGE_TAG="${RELEASE}-${BUILD_NUMBER}"
        Github_access_token= credentials("vault-github-access-token")
    }
    stages{

        stage("Cleanup Worksapce"){
            steps{
                cleanWs()
            }
            
        }
        stage (" Checkout from SCM"){
            steps{
                
                git branch: 'main', credentialsId: 'vault-github-access-token', url: 'https://github.com/wasrazki/AppCICDPipeline'
            }
        } 

        stage("Secret Scanning with Trufflehog"){
            steps{
                script{
                    sh'pwd'
                    sh 'docker run  gesellix/trufflehog --json https://wasrazki:${Github_access_token}@github.com/wasrazki/AppCICDPipeline.git> secret-scanning'
                    sh 'sudo cat secret-scanning'
                }
            }
            
        }
        stage (" Building the Application"){
            steps{
                sh "mvn clean package"
            }
        } 

        stage (" Testing the Application"){
            steps{
                sh "mvn test"
            }
            post {
               always {
                    junit 'target/surefire-reports/**/*.xml'
                }   
            }


        } 


}}

    
