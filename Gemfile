source 'https://rubygems.org'

gem "addressable"
gem 'airbrake', github: 'alphagov/airbrake', branch: 'silence-dep-warnings-for-rails-5'
gem 'cdn_helpers', '0.9'
gem 'gds-api-adapters', '~> 41.2'
gem 'gelf'
gem 'govuk_frontend_toolkit', '~> 4.12.0'
gem 'govuk_navigation_helpers', '~> 5.1'
gem 'htmlentities', '~> 4.3.0'
gem 'logstasher', '~> 1.1.0'
gem 'nokogiri', '~> 1.6.8.0'
gem 'plek', '~> 1.12.0'
gem 'rails', '~> 5.0.2'
gem 'rails-i18n', '~> 4.0.0'
gem 'redis', "~> 3.3.3"
gem 'sass', '~> 3.4.0'
gem 'sass-rails'
gem 'slimmer', '~> 10.1.4'
gem 'sprockets-rails', "~> 3.2.0"
gem 'shared_mustache', '~> 1.0.0'
gem 'statsd-ruby', '1.3.0', require: 'statsd'
gem "therubyracer", "~> 0.12.0"
gem 'uglifier'
gem 'uk_postcode', '~> 2.1.0'
gem 'unicorn', '~> 5.0.0'
gem 'govuk_ab_testing', '~> 2.0'
gem 'minitest', '~> 5.10', '!= 5.10.2'



group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :development, :test do
  gem 'ci_reporter_test_unit'
  gem 'govuk-lint'
  gem 'pry-byebug'
  gem 'ci_reporter_rspec'
end

group :test do
  gem 'rails-controller-testing'
  gem 'capybara'
  gem 'ci_reporter'
  gem 'govuk-content-schema-test-helpers'
  gem 'govuk_schemas'
  gem "launchy"
  gem "mocha"
  gem 'poltergeist'
  gem 'shoulda-context'
  gem 'simplecov'
  gem 'simplecov-rcov'
  gem "timecop"
  gem "webmock", require: false
end
