pipeline {
  agent {
    label 'docker'
  }

  environment {
    DOCKER_HUB = credentials('DockerHubNOAAEPIC')
    UBUNTU_GNU_IMAGE_NAME = 'ubuntu20.04-gnu9.3'
    UBUNTU_GNU_IMAGE_VERSION = '0.1'
    UBUNTU_GNU_IMAGE_TAG = "${env.DOCKER_HUB_USR}/${env.UBUNTU_GNU_IMAGE_NAME}:${env.UBUNTU_GNU_IMAGE_VERSION}"
    UBUNTU_GNU_HPCSTACK_IMAGE_NAME = "${env.UBUNTU_GNU_IMAGE_NAME}-hpc-stack"
    UBUNTU_GNU_HPCSTACK_IMAGE_VERSION = '0.1'
    UBUNTU_GNU_HPCSTACK_IMAGE_TAG = "${env.DOCKER_HUB_USR}/${env.UBUNTU_GNU_HPCSTACK_IMAGE_NAME}:${env.UBUNTU_GNU_HPCSTACK_IMAGE_VERSION}"
    UBUNTU_GNU_SRW_IMAGE_NAME = "${env.UBUNTU_GNU_IMAGE_NAME}-ufs-srwapp"
    UBUNTU_GNU_SRW_IMAGE_VERSION = '0.1'
    UBUNTU_GNU_SRW_IMAGE_TAG = "${env.DOCKER_HUB_USR}/${env.UBUNTU_GNU_SRW_IMAGE_NAME}:${env.UBUNTU_GNU_SRW_IMAGE_VERSION}"
  }

  stages {
    stage('Prepare Environment') {
      steps {
        echo 'Preparing the environment'
        sh 'docker image prune --all'
        sh 'docker login --username "${DOCKER_HUB_USR}" --password "${DOCKER_HUB_PSW}"'
      }
    }

    stage('Build Ubuntu GNU') {
      steps {
        echo "Building ${env.UBUNTU_GNU_IMAGE_TAG}"
        sh 'docker build --tag "${UBUNTU_GNU_IMAGE_TAG}" --file "${WORKSPACE}/Docker/Dockerfile.${UBUNTU_GNU_IMAGE_NAME}" "${WORKSPACE}"'
      }
    }

    stage('Test Ubuntu GNU') {
      steps {
        echo "Testing ${env.UBUNTU_GNU_IMAGE_TAG}"
        sh 'docker run "${UBUNTU_GNU_IMAGE_TAG}" gfortran --version'
      }
    }

    stage('Release Ubuntu GNU') {
      when {
        branch 'main'
      }

      steps {
        echo "Releasing ${env.UBUNTU_GNU_IMAGE_TAG}"
        sh 'docker push "${UBUNTU_GNU_IMAGE_TAG}"'
      }
    }

    stage('Build Ubuntu GNU HPC Stack') {
      steps {
        echo "Building ${env.UBUNTU_GNU_HPCSTACK_IMAGE_TAG}"
        sh 'docker build --tag "${UBUNTU_GNU_HPCSTACK_IMAGE_TAG}" --file "${WORKSPACE}/Docker/Dockerfile.${UBUNTU_GNU_HPCSTACK_IMAGE_NAME}" "${WORKSPACE}"'
      }
    }

    stage('Test Ubuntu GNU HPC Stack') {
      steps {
        echo "Testing ${env.UBUNTU_GNU_HPCSTACK_IMAGE_TAG}"
        sh 'docker run "${UBUNTU_GNU_HPCSTACK_IMAGE_TAG}"'
      }
    }

    stage('Release Ubuntu GNU HPC Stack') {
      when {
        branch 'main'
      }

      steps {
        echo "Releasing ${env.UBUNTU_GNU_HPCSTACK_IMAGE_TAG}"
        sh 'docker push "${UBUNTU_GNU_HPCSTACK_IMAGE_TAG}"'
      }
    }

    stage('Build Ubuntu GNU SRW') {
      steps {
        echo "Building ${env.UBUNTU_GNU_SRW_IMAGE_TAG}"
        sh 'docker build --tag "${UBUNTU_GNU_SRW_IMAGE_TAG}" --file "${WORKSPACE}/Docker/Dockerfile.${UBUNTU_GNU_SRW_IMAGE_NAME}" "${WORKSPACE}"'
      }
    }

    stage('Test Ubuntu GNU SRW') {
      steps {
        echo "Testing ${env.UBUNTU_GNU_SRW_IMAGE_TAG}"
        sh 'docker run "${UBUNTU_GNU_SRW_IMAGE_TAG}"'
      }
    }

    stage('Release Ubuntu GNU SRW') {
      when {
        branch 'main'
      }

      steps {
        echo "Releasing ${env.UBUNTU_GNU_SRW_IMAGE_TAG}"
        sh 'docker push "${UBUNTU_GNU_SRW_IMAGE_TAG}"'
      }
    }
  }
}
