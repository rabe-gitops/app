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
    * - push builds, for commits on the master branch
    */
    stage('image-build') {

      options {
        lock (resource: 'IMAGE_BUILD_LOCK')
      }

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
              label 'kaniko-slave'
            }
          }

          steps {
            // select 'kaniko' container inside the 'kaniko slave' pod
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
            label 'amazon-slave'
          }

          steps {
            // select 'kaniko' container inside the 'kaniko slave' pod
            container('awscli') {
              sh """
                manifest=\$(aws ecr batch-get-image --repository-name ${env.ECR_REPO_NAME} --image-ids imageTag=${env.GIT_COMMIT.take(7)} --region ${env.AWS_REGION} --query images[].imageManifest --output text)
                aws ecr put-image --repository-name ${env.ECR_REPO_NAME} --image-tag ${env.TAG_NAME} --image-manifest "\${manifest}" --region ${env.AWS_REGION}
              """
            }
          }
        }
      }
    }

    stage('update-manifests') {

      environment {
        GIT_COMMIT_SHORT = sh(script: "printf \$(git rev-parse --short ${GIT_COMMIT})", returnStdout: true)
        GIT_MANIFESTS_REPO_URI = 'github.com/rabe-gitops/manifests.git'
        GIT_MANIFESTS_REPO_NAME = 'manifests'
        APP_MANIFEST_FILE_NAME = 'app-deployment.yaml'
        GIT_USERNAME = 'jenkinsci'
        GIT_EMAIL = 'jenkins.ci@rabe.gitops.it'
        IMAGE_TAG = "${TAG_NAME != null ? TAG_NAME : GIT_COMMIT_SHORT}"
      }

      agent {
        label 'jenkins-slave'
      }

      steps {
        
        sh 'printenv'
        withCredentials([string(
          credentialsId: 'rabe-gitops-jenkinsci',
          variable: 'GIT_TOKEN'
        )]) {
          sh """
            git clone -b master --single-branch https://${GIT_USERNAME}:${GIT_TOKEN}@${env.GIT_MANIFESTS_REPO_URI}
            cd ${env.GIT_MANIFESTS_REPO_NAME}
            sed -i 's|image: .*|image: ${env.ECR_REPO_URI}:${env.IMAGE_TAG}|g' base/${env.APP_MANIFEST_FILE_NAME}
            git config user.name ${env.GIT_USERNAME}
            git config user.email ${env.GIT_EMAIL}
            git add .
            git diff-index --quiet HEAD || git commit -m "Update base image with version ${env.IMAGE_TAG}"
            git tag ${env.IMAGE_TAG}
            git push origin master --tags
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
