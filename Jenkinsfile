pipeline {
  agent none

  /*** PIPELINE ENVIRONMENT ***/
  environment {
    AWS_ACCOUNT = '904573531492'
    AWS_REGION = 'eu-west-1'
  }

  /*** STAGES ***/
  stages {

    /** TEST **/
    /* executed for all branches */
    // stage('test') {

    //   agent {
    //     label 'jenkins-slave'
    //   }

    //   steps {
    //     echo 'TEST'
    //     sh 'printenv'
    //   }
    // }

    /** BUILD **/
    /* executed in three ways:
     * - tag builds, for new software versions
     * - change builds, for merge requests into the master branch
     * - push builds, for commits on the master branch
     */
    stage('build') {

      environment {
        ECR_REPO_NAME = 'app'
        ECR_REPO_URI = "${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}"
      }

      parallel {

        stage('tag-build') {

          when {
            // only for a tag build
            beforeAgent true
            buildingTag()
          }

          stages {

            stage('build-image') {

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

            stage('update-manifests') {

              environment {
                GIT_MANIFESTS_REPO_URI = 'github.com/rabe-gitops/manifests.git'
                GIT_MANIFESTS_REPO_NAME = 'manifests'
                APP_MANIFEST_FILE_NAME = 'app-deployment.yaml'
                GIT_USERNAME = 'jenkinsci'
                GIT_EMAIL = 'jenkins.ci@rabe.gitops.it'
              }

              agent {
                label 'jenkins-slave'
              }

              steps {

                withCredentials([string(
                  credentialsId: 'rabe-gitops-jenkinsci',
                  variable: 'GIT_TOKEN'
                )]) {
                  sh """
                    git clone https://${GIT_USERNAME}:${GIT_TOKEN}@${env.GIT_MANIFESTS_REPO_URI}
                    cd ${env.GIT_MANIFESTS_REPO_NAME}
                    sed -i 's|image: .*|image: ${env.ECR_REPO_URI}:${env.TAG_NAME}|g' base/${env.APP_MANIFEST_FILE_NAME}
                    git config user.name ${env.GIT_USERNAME}
                    git config user.email ${env.GIT_EMAIL}
                    git add .
                    git commit -m "Update base image version"
                    git tag ${env.TAG_NAME}
                    git push origin master --tags
                  """
                }
              }
            }
          }
        }

        stage('change-build') {

          when {
            // only for change requests (pull/merge requests)
            beforeAgent true
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
            beforeAgent true
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
