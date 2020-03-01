pipeline {
  agent none

  // ENVIRONMENT
  environment {
    PROJECT_NAME = 'rabe-gitops'
    REPOSITORY_NAME = 'app'
  }

  // STAGES
  stages {
    stage('checkout') {
      agent {
        label 'ci-jenkins-slave'
      }
      steps {
        echo 'CHECKOUT'
      }
    }

    stage('build') {
      when {
        branch 'master'
      }
      agent {
        kubernetes {
          label 'image-builder-slave'
        }
      }
      steps {
        sh '''
        /kaniko/executor --dockerfile `pwd`/Dockerfile \
                         --context `pwd` \
                         --destination=904573531492.dkr.ecr.eu-west-1.amazonaws.com/app:latest
        '''
      }
    }

  }

  // POST-EXECUTION
  post {
    success {
      node('master') {
        echo 'SUCCESS'
      }
    }
    failure {
      node('master') {
        echo 'FAILURE'
      }
    }
    always {
      node('master') {
        echo 'ENDED'
      }
    }
  }
}