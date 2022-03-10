pipeline {
  agent {
    label 'docker'
  }

  environment {
    DOCKER_CREDS = credentials('DockerHubNOAAEPIC')
    DOCKER_IMAGE_NAME = "${env.JOB_BASE_NAME}"
    DOCKER_IMAGE_VERSION = '0.1'
    DOCKER_IMAGE_TAG = "${env.DOCKER_CREDS_USR}/${env.DOCKER_IMAGE_NAME}:${env.DOCKER_IMAGE_VERSION}"
  }

  stages {
    stage('Build') {
      steps {
        sh 'docker build --tag "${DOCKER_IMAGE_TAG}" --file "${WORKSPACE}/docker/ubuntu20.04-gnu9.3.docker" "${WORKSPACE}"'
      }
    }

    stage('Release') {
      steps {
        sh 'docker login --username "${DOCKER_CREDS_USR}" --password "${DOCKER_CREDS_PSW}"'
        sh 'docker push "${DOCKER_IMAGE_TAG}"'
      }
    }
  }
}
