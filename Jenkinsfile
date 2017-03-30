#!/usr/bin/env groovy

REPOSITORY = 'frontend'
DEFAULT_SCHEMA_BRANCH = 'deployed-to-production'

node() {

  stage("Checkout") {
    checkout scm
  }

  def govuk = load 'govuk_jenkinslib.groovy'

  govuk.buildProject(
    beforeTest: {
      stage('beforeTest') {
        echo "In beforeTest"
      }
    },
    testTask: {
      stage('testTask') {
        echo "In testTask"
      }
    },
    afterTest: {
      stage('afterTest') {
        echo "In afterTest"
      }
    }
  )
}
