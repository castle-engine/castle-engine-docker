/* -*- mode: groovy -*-
  Configure how to run our job in Jenkins.
  See https://castle-engine.io/cloud_builds_jenkins .
*/

pipeline {
  triggers {
    pollSCM('H/4 * * * *')
    upstream(upstreamProjects: 'castle_game_engine_organization/castle-engine/master', threshold: hudson.model.Result.SUCCESS)
  }
  agent any
  stages {
    stage('Rebuild Docker Image') {
      steps {
        withCredentials([
          string(credentialsId: 'docker-user', variable: 'docker_user'),
          string(credentialsId: 'docker-password', variable: 'docker_password')
        ]) {
          sh './build-cge-unstable.sh'
	}
      }
    }
    stage('Remove Unused Docker Images') {
      steps {
        sh './remove_unused_docker_images.sh'
      }
    }
  }
  post {
    regression {
      mail to: 'michalis@castle-engine.io',
        subject: "[jenkins] Build started failing: ${currentBuild.fullDisplayName}",
        body: "See the build details on ${env.BUILD_URL}"
    }
    failure {
      mail to: 'michalis@castle-engine.io',
        subject: "[jenkins] Build failed: ${currentBuild.fullDisplayName}",
        body: "See the build details on ${env.BUILD_URL}"
    }
    fixed {
      mail to: 'michalis@castle-engine.io',
        subject: "[jenkins] Build is again successfull: ${currentBuild.fullDisplayName}",
        body: "See the build details on ${env.BUILD_URL}"
    }
  }
}
