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
                sh './gradlew test jacocoTestReport'
                sh './gradlew check'
            }
            post {
                always {
                    junit skipOldReports: true, skipPublishingChecks: true, testResults: 'build/test-results/test/*xml'
                    jacoco classPattern: 'build/classes/java/main', execPattern: 'build/jacoco/*.exec', sourcePattern: 'src/main/java/com/example/restservice'
                    recordIssues(tools: [pmdParser(pattern: 'build/reports/pmd/*.xml')])
                    recordIssues(tools: [trivy(pattern: 'trivy repo -f json -o results_repo.json https://github.com/qebyn/hello-springrest')])
                }
            }
        }
        stage('Building the Docker image') {
            steps {
                sh 'docker-compose build'
                sh 'git tag 1.0.${BUILD_NUMBER}'
                sshagent(['github_access_ssh']) {
                    sh 'git push --tags'
                    sh "docker tag ghcr.io/qebyn/hello-springrest/springrest:latest ghcr.io/qebyn/hello-springrest/springrest:1.0.${BUILD_NUMBER}"
                    sh "docker run -d -p 8080:8080 ghcr.io/qebyn/hello-springrest/springrest:1.0.${BUILD_NUMBER}"
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: '**/*.jar', fingerprint: true
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
                withAWS(credentials:'clave-aws') {
                    dir('./elasticfolder') {
			sh 'eb deploy springrest-qebyn'
                    }
                }
            }
        }
    }
}

