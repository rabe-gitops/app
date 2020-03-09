pipeline {
  agent none

  /*** PIPELINE ENVIRONMENT ***/
  environment {
    AWS_ACCOUNT = '904573531492'
    AWS_REGION = 'eu-west-1'
    ECR_REPO_NAME = 'app'
    ECR_REPO_URI = "${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}"
  }

  /*** STAGES ***/
  stages {

    /** TEST **/
    /* executed for all branches, but not for building tags */
    stage('unit-testing') {

      when {
        beforeAgent true
        not { buildingTag() }
      }

      agent {
        label 'jenkins-slave' // image: jenkins/jnlp-slave:alpine
      }

      steps {
        sh 'printenv'
        echo 'TODO: UNIT TESTING'
      }
    }

    /** BUILD **/
    /* executed in two ways:
     * - tag builds, for new software releases
     * - push builds, for commits (i.e. merges from feature branches) on master
     */
    stage('image-build') {

      parallel {

        stage('branch-build') {

          when {
            // only for the master branch
            beforeAgent true
            branch 'master'
          }

          agent {
            // execute on the 'kaniko slave' pod
            kubernetes {
              label 'kaniko-slave' // image: gcr.io/kaniko-project/executor:debug
            }
          }

          steps {
            // select the 'kaniko' container inside the 'kaniko slave' pod
            container('kaniko') {
              sh """
                pwd
                /kaniko/executor \
                  --dockerfile \$(pwd)/Dockerfile \
                  --context \$(pwd) \
                  --destination=${env.ECR_REPO_URI}:${env.GIT_COMMIT.take(7)} \
                  --destination=${env.ECR_REPO_URI}:latest
              """
            }
          }
        }

        stage('tag-build') {

          when {
            // only for a tag build
            beforeAgent true
            buildingTag()
          }

          agent {
            // execute on the 'amazon slave' pod
            label 'amazon-slave' // image: mesosphere/aws-cli
          }

          steps {
            // select the 'awscli' container inside the 'amazon slave' pod
            container('awscli') {
              script {
                waitUntil {
                  sh(script: """
                      aws ecr describe-images --repository-name=${env.ECR_REPO_NAME} --image-ids=imageTag=${env.GIT_COMMIT.take(7)} --region ${env.AWS_REGION}
                    """, returnStatus: true
                  ) == 0
                }
              }
              sh """
                manifest=\$(aws ecr batch-get-image --repository-name ${env.ECR_REPO_NAME} --image-ids imageTag=${env.GIT_COMMIT.take(7)} --region ${env.AWS_REGION} --query 'images[].imageManifest' --output text)
                aws ecr put-image --repository-name ${env.ECR_REPO_NAME} --image-tag ${env.TAG_NAME} --image-manifest "\${manifest}" --region ${env.AWS_REGION}
              """
            }
          }
        }
      }
    }

    stage('update-manifests') {

      when {
        beforeAgent true
        anyOf {
          branch 'master'
          buildingTag()
        }
      }

      environment {
        GIT_MANIFESTS_REPO_URI = 'github.com/rabe-gitops/manifests.git'
        GIT_MANIFESTS_REPO_NAME = 'manifests'
        APP_MANIFEST_FILE = 'base/app-deployment.yaml'
        GIT_USERNAME = 'jenkinsci'
        GIT_EMAIL = 'jenkins.ci@rabe.gitops.it'
      }

      agent {
        // execute on the 'jenkins slave' pod
        label 'jenkins-slave' // image: jenkins/jnlp-slave:alpine
      }

      steps {
        
        withCredentials([string(
          credentialsId: 'rabe-gitops-jenkinsci',
          variable: 'GIT_TOKEN'
        )]) {
          script {
            def IMAGE_TAG = env.GIT_COMMIT.take(7)
            def IMAGE_TAG_PREFIX = 'app'
            if (env.TAG_NAME) {
              IMAGE_TAG = env.TAG_NAME
              IMAGE_TAG_PREFIX = 'rel'
            }
            sh """
              git clone -b master --single-branch https://${env.GIT_USERNAME}:${GIT_TOKEN}@${env.GIT_MANIFESTS_REPO_URI}
              cd ${env.GIT_MANIFESTS_REPO_NAME}
              sed -i 's|image: .*|image: ${env.ECR_REPO_URI}:${IMAGE_TAG}|g' ${env.APP_MANIFEST_FILE}
              git config user.name ${env.GIT_USERNAME}
              git config user.email ${env.GIT_EMAIL}
              git add .
              git diff-index --quiet HEAD || git commit -m "Update base image with version '${IMAGE_TAG}'"
              git tag ${IMAGE_TAG_PREFIX}-${IMAGE_TAG}
              git push origin master --tags
            """
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
