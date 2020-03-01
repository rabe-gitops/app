pipeline {
  agent none

  /*** ENVIRONMENT ***/
  environment {
    PROJECT_NAME = 'rabe-gitops'
    REPOSITORY_NAME = 'app'
  }

  /*** STAGES ***/
  stages {

    // /* CHECKOUT */
    // stage('checkout') {
    //   agent {
    //     label 'jenkins-slave'
    //   }
    //   steps {
    //     echo 'CHECKOUT'
    //   }
    // }

    /* BUILD */
    stage('build') {

      when {
        // Only for the master branch
        branch 'master'
      }

      agent {
        // Execute on Kaniko Slave pod
        kubernetes {
          label 'kaniko-slave'
        }
      }

      steps {
        // Select Kaniko container inside Kaniko Slave pod
        container('kaniko') {
          sh 'printenv'
          script {

            def git_tag = ''
            def image_tag = ''

            // Retrieve git tag
            git_tag = sh (
              returnStdout: true,
              script: "git fetch --tags && git tag --points-at ${GIT_COMMIT} | awk NF"
            ).trim()

            // Set image tag
            if (git_tag) {
              image_tag = git_tag
            }
            else {
              image_tag = sh (
                returnStdout: true,
                script: "git rev-parse --short=7 ${GIT_COMMIT}"
              ).trim()
            }

            /kaniko/executor \
              --dockerfile $(pwd)/Dockerfile \
              --context $(pwd) \
              --destination=904573531492.dkr.ecr.eu-west-1.amazonaws.com/app:latest \
              --destination=904573531492.dkr.ecr.eu-west-1.amazonaws.com/app:latest
          }
        }
      }
    }

  }

  // /*** POST-EXECUTION ***/
  // post {
  //   success {
  //     node('ci-jenkins-slave') {
  //       echo 'SUCCESS'
  //     }
  //   }
  //   failure {
  //     node('ci-jenkins-slave') {
  //       echo 'FAILURE'
  //     }
  //   }
  //   always {
  //     node('ci-jenkins-slave') {
  //       echo 'ENDED'
  //     }
  //   }
  // }
}