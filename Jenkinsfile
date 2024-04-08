pipeline{
    agent{
        label "jenkins-agent"
    }
    tools{
        jdk 'java17'
        maven 'Maven3'
    }
    environment{
        APP_NAME= "appcicdpipeline"
        RELEASE= "1.0.0"
        DOCKER_USER= "wasraz"
        DOCKER_PASS= "vault-dockerhub-access-token"
        IMAGE_NAME= "${DOCKER_USER}"+"/"+"${APP_NAME}"
        IMAGE_TAG= "${RELEASE}-${BUILD_NUMBER}"
        Grype_Cloud_Uploading = credentials("vault-grype-cloud-uploading")
        Trivy_Cloud_Uploading = credentials("vault-trivy-cloud-uploading")
        
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


        stage('OWASP Dependency-Check Vulnerabilities') {
            steps {
                dependencyCheck additionalArguments: ''' 
                            -o './'
                            -s './'
                            -f 'ALL' 
                            --prettyPrint''', odcInstallation: 'Dependency-Check'
                
                dependencyCheckPublisher pattern: 'dependency-check-report.xml'
            }
    }

        stage("Grype Scanning and Report Uploading to the cloud"){
            steps{
                sh "grype dir:. --scope AllLayers > grype-scanning"
                script{
                    def report= readFile("grype-scanning")
                    def htmlreport = """
                    <html> 
                    <head> <title> Grype Scanning Report </title> </head> 
                    <body>
                        <h1> Grype Scanning Report: Build ${BUILD_NUMBER} </h1> 
                        <pre> ${report}</pre>
                    </body>
                    </html>
                    """
                    writeFile file: 'target/grype-scanning-report.html', text: htmlreport
                    sh "azcopy copy 'target/grype-scanning-report.html'  '${Grype_Cloud_Uploading}'  " 
                      

                }

                archiveArtifacts artifacts: 'target/grype-scanning-report.html', allowEmptyArchive: true
                

                
            }
        }

        

        stage ("Trivy Scanning and Report Uploading to the cloud"){
            steps{
                sh 'trivy filesystem . > trivy-scan'
                script{
                    def report = readFile("trivy-scan")
                    def htmlreport = """
                    <html> 
                    <head> <title> Trivy Scanning Report </title> </head> 
                    <body>
                        <h1> Trivy Scanning Report: Build ${BUILD_NUMBER}   </h1> 
                        <pre> ${report}</pre>
                    </body>
                    </html>
                    """
                    writeFile file: 'target/trivy-scanning-report.html', text: htmlreport
                    sh "azcopy copy 'target/trivy-scanning-report.html'   '${Trivy_Cloud_Uploading}'  "
                }

                archiveArtifacts artifacts: 'target/trivy-scanning-report.html', allowEmptyArchive: true

            }
        }


        stage (" SonarQube Code Analysis"){
            steps{
                script{
                    withSonarQubeEnv(installationName: 'SonarQube-Scanner' , credentialsId: 'vault-sonarqube-access-token'){
                        sh 'mvn sonar:sonar'
                    }

                }
                
            }
        }

        stage (" Quality GATE"){
            steps{
                waitForQualityGate abortPipeline: false , credentialsId: 'vault-sonarqube-access-token' // abortPipeline: true ==> in order to abort the pipeline if the code analysis didn't succed
            }
        } 


        stage (" Docker Build and Push"){
            steps{
                script{

                    docker.withRegistry('', DOCKER_PASS){
                    docker_image = docker.build "${IMAGE_NAME}"
                }

                    docker.withRegistry('', DOCKER_PASS){
                        docker_image.push("${IMAGE_TAG}")
                        docker_image.push('latest')
                }

                }
                
                
            }
        }

        stage (" Docker Image Scanning with TRIVY and Report Generating"){
            steps{
                script{
                    sh "trivy image --no-progress --exit-code 0 --severity HIGH,CRITICAL ${IMAGE_NAME}:${IMAGE_TAG} > trivy-image-scan"
                    // houni normalement --exit-code  lazem tkoun 1 khater itha ken l9it high wala critical vulnerabilities in my docker image lazem n aborti el pipeline maadch n9adem.
                    def report = readFile("trivy-image-scan")
                    def htmlreport = """
                    <html> 
                    <head> <title> Trivy Image Scanning Report </title> </head> 
                    <body>
                        <h1> Trivy Scanning Report </h1> 
                        <pre> ${report}</pre>
                    </body>
                    </html>
                    """
                    writeFile file: 'target/trivy-image-scanning-report.html', text: htmlreport

                }
                archiveArtifacts artifacts: 'target/trivy-image-scanning-report.html', allowEmptyArchive: true

            }
        } 




}}

    
