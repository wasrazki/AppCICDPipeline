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

       

        stage (" Building the Application"){
            steps{
                sh "mvn clean package"
            }
        } 

        stage("Grype Scanning"){
            steps{
                sh "grype dir:. > grype-scanning"
                script{
                    def report = readFile("grype-scanning")
                    def htmlreport = """
                    <html> 
                    <head> <title> Grype Scanning Report </title> </head> 
                    <body>
                        <h1> Grype Scanning Report </h1> 
                        <pre> ${report}</pre>
                    </body>
                    </html>
                    """
                    writeFile file: 'target/grype-scanning-report.html', text: htmlreport
                }

                archiveArtifacts artifacts: 'target/grype-scanning-report.html', allowEmptyArchive: true
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

    
