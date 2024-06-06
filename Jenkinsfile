/* -*- mode: groovy -*-
  Configure how to run our job in Jenkins.
  See https://castle-engine.io/jenkins .
*/

pipeline {
  options {
    /* Sometimes Jenkins can go crazy and schedule numerous builds of
       the same job in a short time (like new escape-universe job scheduled
       every ~5 minutes, for a total of ~50 jobs, on one Saturday morning).
       This can easily exhaust both GitLFS quota and disk space on slaves,
       also causing lots of noise in Jenkins mails.
       Using disableConcurrentBuilds avoids this. */
    disableConcurrentBuilds()
    /* Trying to resume builds when controller restarts usually results
       in job just being stuck forever. So we disable it. */
    disableResume()
    /* Makes failure in any paralel job to stop the build,
       instead of needlessly trying to finish on one node,
       when another node already failed. */
    parallelsAlwaysFailFast()
  }
  triggers {
    pollSCM('H/4 * * * *')
    upstream(upstreamProjects: 'castle_game_engine_organization/castle-engine/master', threshold: hudson.model.Result.SUCCESS)
  }
  agent any
  stages {
    stage('Rebuild Docker Image') {
      steps {
        withCredentials([
          string(credentialsId: 'docker-user', variable: 'DOCKER_USER'),
          string(credentialsId: 'docker-password', variable: 'DOCKER_PASSWORD')
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
