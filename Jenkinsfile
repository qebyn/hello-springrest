pipeline {
    agent any
    options {
        timestamps()
        ansiColor('xterm')
    }
    stages {
        stage('Testing the application') {
            steps {
                sh 'docker-compose config'
                sh './gradlew test'
            }
            post {
                always {
                    junit skipOldReports: true, skipPublishingChecks: true, testResults: 'build/test-results/test/*xml'
                    jacoco classPattern: 'app/build/classes/java/main', execPattern: 'app/build/jacoco/*.exec', inclusionPattern: 'app/build/java/main', sourcePattern: 'app/src/main/java'
                }
            }
        }
        stage('Building the Docker image') {
            steps {
                sh 'docker-compose build'
                sh "git tag 1.0.${BUILD_NUMBER}"
                sshagent(['github_access_ssh']) {
                    sh 'git push --tags'
                    sh "docker tag ghcr.io/qebyn/hello-springrest/springrest:latest ghcr.io/qebyn/hello-springrest/springrest:1.0.${BUILD_NUMBER}"
                }
            }
        }
        stage('Publishing the Docker image') {
           steps {
             withCredentials([string(credentialsId: 'github-tokenqebyn', variable: 'PAT')]) {
                 sh 'echo $PAT | docker login ghcr.io -u qebyn --password-stdin && docker-compose push && docker push ghcr.io/qebyn/hello-springrest/springrest:1.0.${BUILD_NUMBER}'
                }
            }
        }
        stage('Deploying the application to Elastic Beanstalk') {
            steps {
                withAWS(credentials: 'aws_access_key') {
                    dir('./elasticfolder') {
                        sh 'eb create springrest-qebyn'
                    }
                }
            }
        }
    }
}
