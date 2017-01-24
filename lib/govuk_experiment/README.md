# GOV.UK Experiment

Helper library to make it easy to perform server side A/B tests on GOV.UK.

## Starting a A/B test

### 1. Get your cookie listed on /help/cookies

https://www.gov.uk/help/cookies

### 2. Configure the CDN

You'll need to add CDN config like this:

https://github.com/alphagov/govuk-cdn-config/blob/38092ad2baa59ca52c49558bf2030c933a60e4c8/vcl_templates/www.vcl.erb#L276-L281

https://github.com/alphagov/govuk-cdn-config/blob/38092ad2baa59ca52c49558bf2030c933a60e4c8/vcl_templates/www.vcl.erb#L201-L210

### 3. Configure Google Analytics

Somehow.

### 4. Configure your Rails app

Your app needs:

1. Some piece of logic to be A/B tested
2. A HTML meta tag that will be used to measure the results
3. A response HTTP header that tells Fastly you're doing an A/B test

Let's say you have this controller:

```ruby
# app/controllers/party_controller.rb
class PartyController < ApplicationController
  def show
    experiment = GovukExperiment::Experiment.new("your_experiment_name")
    @ab_test = experiment.ab_test_for_request(request)

    if @ab_test.variant_b?
      render "new_show_template_to_be_tested"
    else
      render "show"
    end
  end
end
```

Add this to your layouts, so that we have a meta tag that can be picked up
by the extension and analytics.

```html
<!-- application.html.erb -->
<head>
  <%= @experiment.analytics_meta_tag.html_safe %>
</head>
```

You'll be able to test the controller like this:

```ruby
# test/controllers/party_controller_test.rb
class PartyControllerTest < ActionController::TestCase
  should "show the user the B version" do
    with_variant your_experiment_name: "B" do
      get :show

      assert_rendered "new_show_template_to_be_tested"
      assert_ab_test_rendered "example"
    end
  end
end
```
