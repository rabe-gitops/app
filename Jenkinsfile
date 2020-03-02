pipeline {
  agent none

  /*** ENVIRONMENT ***/
  environment {
    AWS_ACCOUNT = '904573531492'
    AWS_REGION = 'eu-west-1'
    ECR_REPO_NAME = 'app'
    ECR_REPO_URI = "${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}"
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
          sh """
          /kaniko/executor \
            --dockerfile \$(pwd)/Dockerfile \
            --context \$(pwd) \
            --destination=${env.ECR_REPO_URI}:${env.TAG_NAME}
          """
        }
      }
    }
    stage('change-build') {

      when {
        // Only for change requests (pull/merge requests)
        changeRequest target: 'master'
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
          sh """
          /kaniko/executor \
            --dockerfile \$(pwd)/Dockerfile \
            --context \$(pwd) \
            --destination=${env.ECR_REPO_URI}:${env.CHANGE_ID}
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
          sh """
          /kaniko/executor \
            --dockerfile \$(pwd)/Dockerfile \
            --context \$(pwd) \
            --destination=${env.ECR_REPO_URI}:${env.GIT_COMMIT.take(7)} \
            --destination=${env.ECR_REPO_URI}:latest
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