pipeline {
  agent none

  /*** PIPELINE ENVIRONMENT ***/
  environment {
    AWS_ACCOUNT = '904573531492'
    AWS_REGION = 'eu-central-1'
    ECR_REPO_NAME = 'app'
    ECR_REPO_URI = "${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}"
    SLAVES_TEMPLATES_PATH = 'slaves'
  }

  /*** STAGES ***/
  stages {

    /** UNIT & E2E TESTING **/
    /* executed for all branches and change requests, but not for tag builds */
    stage('test') {

      when {
        beforeAgent true
        not { buildingTag() }
      }

      agent {
        // execute on the 'cypress slave' pod
        kubernetes {
          defaultContainer 'cypress'
          yamlFile "${SLAVES_TEMPLATES_PATH}/cypress-slave.yaml"
        }
      }

      steps {
        sh """
          yarn install --frozen-lockfile --no-cache
          yarn run test:unit
        """
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
              defaultContainer 'kaniko'
              yamlFile "${SLAVES_TEMPLATES_PATH}/kaniko-slave.yaml"
            }
          }

          steps {
            sh """
              /kaniko/executor \
                --dockerfile \$(pwd)/Dockerfile \
                --context \$(pwd) \
                --destination=${env.ECR_REPO_URI}:${env.GIT_COMMIT.take(7)} \
                --destination=${env.ECR_REPO_URI}:latest
            """
          }
        }

        stage('tag-build') {

          when {
            // only for a tag build
            beforeAgent true
            buildingTag()
          }

          agent {
            // execute on the 'awscli slave' pod
            kubernetes {
              defaultContainer 'awscli'
              yamlFile "${SLAVES_TEMPLATES_PATH}/awscli-slave.yaml"
            }
          }

          steps {
            script {
              // this step depends on the branch build one; lock can't be used in this case; poll on ECR
              timeout(300) {
                waitUntil {
                  sleep(10)
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

      options {
        lock (resource: 'UPDATE_MANIFESTS_LOCK')
      }

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
        GIT_USERNAME = 'rabe-gitops-bot'
      }

      agent {
        // execute on the 'python slave' pod
        kubernetes {
          defaultContainer 'python'
          yamlFile "${SLAVES_TEMPLATES_PATH}/python-slave.yaml"
        }
      }

      steps {
        withCredentials([usernamePassword(
          credentialsId: 'rabe-gitops-jenkinsci',
          usernameVariable: 'GIT_EMAIL',
          passwordVariable: 'GIT_TOKEN'
        )]) {
          script {
            def IMAGE_TAG = env.GIT_COMMIT.take(7)
            def IMAGE_TAG_PREFIX = 'app'
            if (env.TAG_NAME) {
              IMAGE_TAG = env.TAG_NAME
              IMAGE_TAG_PREFIX = 'rel'
            }
            // sh """
            //   pip install -r scripts/requirements.txt
            //   python scripts/deploy.py \
            //     --manifests_repo=${env.GIT_MANIFESTS_REPO_NAME} \
            //     --manifests_app_file=${env.APP_MANIFEST_FILE} \
            //     --image_tag_prefix=${IMAGE_TAG_PREFIX} \
            //     --new_image_tag=${IMAGE_TAG} \
            // """
            sh """
              git clone -b master --single-branch https://${env.GIT_USERNAME}:${GIT_TOKEN}@${env.GIT_MANIFESTS_REPO_URI}
              cd ${env.GIT_MANIFESTS_REPO_NAME}
              sed -i 's|image: .*|image: ${env.ECR_REPO_URI}:${IMAGE_TAG}|g' ${env.APP_MANIFEST_FILE}
              git config user.name ${env.GIT_USERNAME}
              git config user.email ${GIT_EMAIL}
              git add .
              git diff-index --quiet HEAD || git commit -m "Update base image with version '${IMAGE_TAG}'"
              git tag ${IMAGE_TAG_PREFIX}${IMAGE_TAG}
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
