pipeline{
    agent{
        label "jenkins-agent"
    }
    stages{

        stage("Cleanup Worksapce"){
            steps{
                cleanWs()
            }
            
        }

        stage (" Checkout from SCM"){
            steps{
                withCredentials([[$class: 'VaultUsernamePasswordCredentialBinding', credentialsId: 'vault-github-access-token', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME']]) {
                                git branch: 'main' , url: 'https://github.com/wasrazki/AppCICDPipeline'

    
                    }
               }
        } 



    }
    
}