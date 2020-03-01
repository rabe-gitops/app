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
    stage('tag-build') {

      when {
        // Only for a tag build
        buildingTag()
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
          sh """
          /kaniko/executor \
            --dockerfile \$(pwd)/Dockerfile \
            --context \$(pwd) \
            --destination=904573531492.dkr.ecr.eu-west-1.amazonaws.com/app:${TAG_NAME}
          """
        }
      }
    }
    stage('branch-build') {

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
          sh """
          /kaniko/executor \
            --dockerfile \$(pwd)/Dockerfile \
            --context \$(pwd) \
            --destination=904573531492.dkr.ecr.eu-west-1.amazonaws.com/app:${GIT_COMMIT} \
            --destination=904573531492.dkr.ecr.eu-west-1.amazonaws.com/app:latest
          """
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