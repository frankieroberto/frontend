#!/usr/bin/env groovy

REPOSITORY = 'frontend'
DEFAULT_SCHEMA_BRANCH = 'deployed-to-production'

def setBuildStatus(repoName, commit, message, state) {
  step([
    $class: "GitHubCommitStatusSetter",
    commitShaSource: [$class: "ManuallyEnteredShaSource", sha: commit],
    reposSource: [$class: "ManuallyEnteredRepositorySource", url: "https://github.com/alphagov/govuk-content-schemas"],
    contextSource: [$class: "ManuallyEnteredCommitContextSource", context: "continuous-integration/jenkins/${repoName}"],
    errorHandlers: [[$class: "ChangingBuildStatusErrorHandler", result: "UNSTABLE"]],
    statusResultSource: [ $class: "ConditionalStatusResultSource", results: [[$class: "AnyBuildResult", message: message, state: state]] ]
  ]);
}

node('mongodb-2.4') {
  def govuk = load '/var/lib/jenkins/groovy_scripts/govuk_jenkinslib.groovy'

  properties([
    buildDiscarder(
      logRotator(
        numToKeepStr: '50')
      ),
    [$class: 'RebuildSettings', autoRebuild: false, rebuildDisabled: false],
    [$class: 'ThrottleJobProperty',
      categories: [],
      limitOneJobWithMatchingParams: true,
      maxConcurrentPerNode: 1,
      maxConcurrentTotal: 0,
      paramsToUseForLimit: 'frontend',
      throttleEnabled: true,
      throttleOption: 'category'],
    [$class: 'ParametersDefinitionProperty',
      parameterDefinitions: [
        [$class: 'BooleanParameterDefinition',
          name: 'IS_SCHEMA_TEST',
          defaultValue: false,
          description: 'Identifies whether this build is being triggered to test a change to the content schemas'],
        [$class: 'StringParameterDefinition',
          name: 'SCHEMA_BRANCH',
          defaultValue: DEFAULT_SCHEMA_BRANCH,
          description: 'The branch of govuk-content-schemas to test against'],
        [$class: 'StringParameterDefinition',
          name: 'SCHEMA_COMMIT',
          defaultValue: 'invalid',
          description: 'The commit of govuk-content-schemas that triggered this build']],

    ],
  ])

  try {
    //if (!govuk.isAllowedBranchBuild(env.BRANCH_NAME)) {
      //return
    //}
    if (params.IS_SCHEMA_TEST) {
      setBuildStatus(REPOSITORY, params.SCHEMA_COMMIT, 'is building on Jenkins', 'PENDING')
    }

    stage("Checkout") {
      checkout scm
    }

    stage("Clean up workspace") {
      govuk.cleanupGit()
    }

    stage("git merge") {
      govuk.mergeMasterBranch()
    }

    stage("Configure Rails environment") {
      govuk.setEnvar("RAILS_ENV", "test")
    }

    stage("Set up content schema dependency") {
      govuk.contentSchemaDependency(params.SCHEMA_BRANCH)
      govuk.setEnvar("GOVUK_CONTENT_SCHEMAS_PATH", "tmp/govuk-content-schemas")
    }

    stage("bundle install") {
      govuk.bundleApp()
    }

    stage("rubylinter") {
      govuk.rubyLinter("app test lib")
    }

    stage("Precompile assets") {
      govuk.precompileAssets()
    }

    stage("Run tests") {
      govuk.runRakeTask("ci:setup:rspec default")
    }

    if (env.BRANCH_NAME == "master") {
      stage("Push release tag") {
        govuk.pushTag(REPOSITORY, env.BRANCH_NAME, "release_${env.BUILD_NUMBER}")
      }

      stage("Deploy to integration") {
        govuk.deployIntegration(REPOSITORY, env.BRANCH_NAME, 'release', 'deploy')
      }
    }

    if (params.IS_SCHEMA_TEST) {
      setBuildStatus(REPOSITORY, params.SCHEMA_COMMIT, 'Succeeded', 'SUCCESS')
    }

  } catch (e) {
    currentBuild.result = "FAILED"
    step([$class: 'Mailer',
          notifyEveryUnstableBuild: true,
          recipients: 'govuk-ci-notifications@digital.cabinet-office.gov.uk',
          sendToIndividuals: true])
    if (params.IS_SCHEMA_TEST) {
      setBuildStatus(REPOSITORY, params.SCHEMA_COMMIT, 'Failed', 'FAILED')
    }
    throw e
  }
}
