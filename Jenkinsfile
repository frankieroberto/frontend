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
      echo "In beforeTest stage"
    }
  )
}
