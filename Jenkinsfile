#!/usr/bin/env groovy

REPOSITORY = 'frontend'
DEFAULT_SCHEMA_BRANCH = 'deployed-to-production'

node() {

  stage("Checkout") {
    checkout scm
  }

  def govuk = load 'govuk_jenkinslib.groovy'

  govuk.buildProject(
    sassLint: false,
    beforeTest: {
      // TODO: Make this the default in Jenkinslib and override in individual
      // projects that need `env.RACK_ENV`
      stage("Test setup") {
        // govuk.setEnvar("RACK_ENV", "")
      }
    },
  )
}
