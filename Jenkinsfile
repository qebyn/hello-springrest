pipeline {
    agent any
    options{
        timestamps()
        ansiColor('xterm')
    }
    stages {
        stage('Testing and Vulnerabilities') {
            steps {
                     sh 'docker-compose config'
                     sh './gradlew test'
                     sh './gradlew check'
                     
            }
            post {
                        always {
                                junit(testResults: 'build/test-results/test/*xml', allowEmptyResults: true)
                                jacoco classPattern: 'build/classes/java/main', execPattern: 'build/jacoco/*.exec', sourcePattern: 'src/main/java/com/example/restservice'
                                recordIssues(tools: [pmdParser(pattern: 'build/reports/pmd/*.xml')])
                                
                        }       
                }
 
        }
    
        stage('Building Docker Image') {
            steps {
                sh 'docker-compose build'
                sh 'git tag 1.0.${BUILD_NUMBER}'
                sshagent(['github_access_ssh']) {
                        sh 'git push --tags'
                }
                sh "docker tag ghcr.io/qebyn/hello-springrest/springrest:latest ghcr.io/qebyn/hello-springrest/springrest:1.0.${BUILD_NUMBER}"
            }
        }
        stage('Scanning Docker Image and Vulnerabilities'){
              steps {
                sh 'trivy image --format json -o docker-report.json  ghcr.io/qebyn/hello-springrest/springrest:1.0.${BUILD_NUMBER}'
                sh 'trivy filesystem -format json -o vulnfs.json .'
              }
                 post {
                        always {
                                recordIssues(tools: [trivy(pattern: '*.json')])
                        }       
                }
        }
        stage('Docker Login and Push'){
           steps {
             withCredentials([string(credentialsId: 'github-tokenqebyn', variable: 'PAT')]) {
                 sh 'echo $PAT | docker login ghcr.io -u qebyn --password-stdin && docker-compose push && docker push ghcr.io/qebyn/hello-springrest/springrest:1.0.${BUILD_NUMBER}'

             }

           }
        }
        stage('Building Elastic Beanstalk Environment') {
            steps {
                withAWS(credentials:'aws_access_key') {
                    dir('./elasticfolder') {
			sh 'eb deploy springrest-qebyn'
                    }   
                }
            }
        }
    }
}