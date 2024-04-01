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

        stage("Grype Scanning and Generating an html Report"){
            steps{
                sh "grype dir:. --scope AllLayers > grype-scanning"
                script{
                    def report-grype = readFile("grype-scanning")
                    def htmlreport = """
                    <html> 
                    <head> <title> Grype Scanning Report </title> </head> 
                    <body>
                        <h1> Grype Scanning Report </h1> 
                        <pre> ${report-grype}</pre>
                    </body>
                    </html>
                    """
                    writeFile file: 'target/grype-scanning-report.html', text: htmlreport
                }

                archiveArtifacts artifacts: 'target/grype-scanning-report.html', allowEmptyArchive: true
            }
        }

        stage (" Unit Testing "){
            steps{
                sh "mvn test"
            }
            post {
               always {
                    junit 'target/surefire-reports/**/*.xml'
                }   
            }


        } 

        stage ("Trivy Scanning and generating an html Report"){
            steps{
                sh 'trivy filesystem . > trivy-scan'
                script{
                    def report-trivy = readFile("trivy-scan")
                    def htmlreport = """
                    <html> 
                    <head> <title> Trivy Scanning Report </title> </head> 
                    <body>
                        <h1> Trivy Scanning Report </h1> 
                        <pre> ${report-trivy}</pre>
                    </body>
                    </html>
                    """
                    writeFile file: 'target/trivy-scanning-report.html', text: htmlreport
                }

                archiveArtifacts artifacts: 'target/trivy-scanning-report.html', allowEmptyArchive: true

            }
        }


}}

    
