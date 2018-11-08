/* -*- mode: groovy -*-
  Confgure how to run our job in Jenkins.
  See https://github.com/castle-engine/castle-engine/wiki/Cloud-Builds-(Jenkins) .
*/

pipeline {
  agent any
  stages {
    stage('Rebuild Docker Image') {
      steps {
        sh './build-cge-unstable.sh'
      }
    }
    stage('Remove Unused Docker Images') {
      steps {
        sh './remove_unused_docker_images.sh'
      }
    }
    stage('Start Dependent Jobs') {
      build job: 'unholy_society'
      build job: 'escape_universe'
    }
  }
  post {
    regression {
      mail to: 'michalis.kambi@gmail.com',
        subject: "[jenkins] Build started failing: ${currentBuild.fullDisplayName}",
        body: "See the build details on ${env.BUILD_URL}"
    }
    failure {
      mail to: 'michalis.kambi@gmail.com',
        subject: "[jenkins] Build failed: ${currentBuild.fullDisplayName}",
        body: "See the build details on ${env.BUILD_URL}"
    }
    fixed {
      mail to: 'michalis.kambi@gmail.com',
        subject: "[jenkins] Build is again successfull: ${currentBuild.fullDisplayName}",
        body: "See the build details on ${env.BUILD_URL}"
    }
  }
}
