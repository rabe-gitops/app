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

    /** TEST **/
    /* executed for all branches */
    stage('test') {

      agent {
        label 'jenkins-slave'
      }

      steps {
        echo 'TEST'
        sh 'printenv'
      }
    }

    /** BUILD **/
    /* executed for the master branch, in three ways:
     * - tag builds, for new versions on the master branch
     * - change builds, for merge requests into the master branch
     * - push builds, for commits on the master branch
     */
    stage('tag-build') {

      when {
        allOf {
          // only for a tag build on the master branch
          expression { env.TAG_NAME != null }
          expression { env.BRANCH_NAME == 'master' }
        }
      }

      agent {
        // execute on the 'kaniko slave' pod
        kubernetes {
          label 'kaniko-slave'
        }
      }

      steps {
        // select 'kaniko' container inside the 'kaniko slave' pod
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
        // only for change requests (pull/merge requests)
        changeRequest target: 'master'
      }

      agent {
        // execute on the 'kaniko slave' pod
        kubernetes {
          label 'kaniko-slave'
        }
      }

      steps {
        // select 'kaniko' container inside the 'kaniko slave' pod
        container('kaniko') {
          sh """
          /kaniko/executor \
            --dockerfile \$(pwd)/Dockerfile \
            --context \$(pwd) \
            --destination=${env.ECR_REPO_URI}:cr-${env.CHANGE_ID}
          """
        }
      }
    }
    stage('branch-build') {

      when {
        // only for the master branch
        branch 'master'
      }

      agent {
        // execute on the 'kaniko slave' pod
        kubernetes {
          label 'kaniko-slave'
        }
      }

      steps {
        // select 'kaniko' container inside the 'kaniko slave' pod
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
