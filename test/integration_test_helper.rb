require 'test_helper'
require 'capybara/rails'
require 'capybara/poltergeist'

require 'slimmer/test'

class ActionDispatch::IntegrationTest
  include Capybara::DSL

  def setup
    super
    # Stub website_root to match test fixtures
    Frontend.stubs(:govuk_website_root).returns("https://www.gov.uk")

    GovukAbTesting.configure do |config|
      config.acceptance_test_framework = :capybara
    end
  end

  def teardown
    Capybara.use_default_driver
    WebMock.reset!
  end

  def setup_api_response(slug, options = {})
    options[:file] ||= "#{slug}.json"
    options[:deep_merge] ||= {}
    json = File.read(Rails.root.join("test/fixtures/#{options[:file]}"))
    content_item = JSON.parse(json).deep_merge(options[:deep_merge])
    content_store_has_page(slug, schema: content_item['format'])
    content_item
  end

  def assert_page_has_content(text)
    assert page.has_content?(text), %(expected there to be content #{text} in #{page.text.inspect})
  end

  def assert_page_is_full_width
    assert_not page.has_css?(".grid-row")
  end

  def assert_current_url(path_with_query, options = {})
    expected = URI.parse(path_with_query)
    wait_until { expected.path == URI.parse(current_url).path }
    current = URI.parse(current_url)
    assert_equal expected.path, current.path
    unless options[:ignore_query]
      assert_equal Rack::Utils.parse_query(expected.query), Rack::Utils.parse_query(current.query)
    end
  end

  # The following selectors are specified using XPath because Capybara/Nokogiri does not seem to find non-standard tags
  # using the usual "CSS-style" selectors.
  def assert_breadcrumb_rendered
    assert page.has_selector?(:xpath, "//test-govuk-component[@data-template='govuk_component-breadcrumbs']", visible: true)
  end

  def assert_related_items_rendered
    assert page.has_selector?(:xpath, "//test-govuk-component[@data-template='govuk_component-related_items']", visible: true)
  end

  # Adapted from http://www.elabs.se/blog/53-why-wait_until-was-removed-from-capybara
  def wait_until
    if Capybara.current_driver == Capybara.javascript_driver
      begin
        Timeout.timeout(Capybara.default_max_wait_time) do
          sleep(0.1) until yield
        end
      rescue TimeoutError
      end
    end
  end

  def self.with_javascript
    context "with javascript" do
      setup do
        Capybara.current_driver = Capybara.javascript_driver
      end

      yield
    end
  end

  def self.without_javascript
    context "without javascript" do
      yield
    end
  end

  def self.with_and_without_javascript
    without_javascript do
      yield
    end

    with_javascript do
      yield
    end
  end
end

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, phantomjs_options: ['--ssl-protocol=TLSv1'])
end

Capybara.javascript_driver = :poltergeist
