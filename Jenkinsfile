pipeline{
    agent{
        label "jenkins-agent"
    }
    tools{
        jdk 'java11'
        maven 'Maven3'
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
        stage (" Building the Application"){
            steps{
                sh "mvn clean package"
            }
        } 

        stage (" Testing the Application"){
            steps{
                sh "mvn test"
            }
        } 



    }
    
}