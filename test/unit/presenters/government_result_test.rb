# coding: utf-8
require "test_helper"

class GovernmentResultTest < ActiveSupport::TestCase
  should "report a lack of location field as no locations" do
    result = GovernmentResult.new(SearchParameters.new({}), {})
    assert result.metadata.empty?
  end

  should "report an empty list of locations as no locations" do
    result = GovernmentResult.new(SearchParameters.new({}), "world_locations" => [])
    assert result.metadata.empty?
  end

  should "display a single world location" do
    france = { "title" => "France", "slug" => "france" }
    result = GovernmentResult.new(SearchParameters.new({}), "world_locations" => [france])
    assert_equal "France", result.metadata[0]
  end

  should "not display individual locations when there are several" do
    france = { "title" => "France", "slug" => "france" }
    spain = { "title" => "Spain", "slug" => "spain" }
    result = GovernmentResult.new(SearchParameters.new({}), "world_locations" => [france, spain])
    assert_equal "multiple locations", result.metadata[0]
  end

  should "not display locations when there is only a slug present" do
    united_kingdom = { "slug" => "united_kingdom" }
    result = GovernmentResult.new(SearchParameters.new({}), "world_locations" => [united_kingdom])
    assert result.metadata.empty?
  end

  should "return valid metadata" do
    result = GovernmentResult.new(SearchParameters.new({}), "public_timestamp" => "2014-10-14",
      "display_type" => "my-display-type",
      "organisations" => [{ "slug" => "org-1" }],
      "world_locations" => [{ "title" => "France", "slug" => "france" }])
    assert_equal result.metadata, ['14 October 2014', 'my-display-type', 'org-1', 'France']
  end

  should "return format for corporate information pages in metadata" do
    result = GovernmentResult.new(SearchParameters.new({}), "format" => "corporate_information")
    assert_equal result.metadata, ['Corporate information']
  end

  should "return only display type for corporate information pages if it is present in metadata" do
    result = GovernmentResult.new(SearchParameters.new({}), "display_type" => "my-display-type",
      "format" => "corporate_information")
    assert_equal result.metadata, ["my-display-type"]
  end

  should "not return sections for deputy prime ministers office" do
    result = GovernmentResult.new(SearchParameters.new({}), "format" => "organisation",
      "link" => "/government/organisations/deputy-prime-ministers-office")
    assert_nil result.sections
  end

  should "return sections for some format types" do
    params = SearchParameters.new({})
    minister_results               = GovernmentResult.new(params, "format" => "minister")
    organisation_results           = GovernmentResult.new(params, "format" => "organisation")
    person_results                 = GovernmentResult.new(params, "format" => "person")
    worldwide_organisation_results = GovernmentResult.new(params, "format" => "worldwide_organisation")
    mainstream_results             = GovernmentResult.new(params, "format" => "mainstream")

    assert_equal 2, minister_results.sections.length
    assert_nil organisation_results.sections
    assert_equal 2, person_results.sections.length
    assert_equal 2, worldwide_organisation_results.sections.length

    assert_nil mainstream_results.sections
  end

  should "return sections in correct format" do
    minister_results = GovernmentResult.new(SearchParameters.new({}), "format" => "minister")

    assert_equal [:hash, :title], minister_results.sections.first.keys
  end

  should "have a government name when in history mode" do
    result = GovernmentResult.new(SearchParameters.new({}), "is_historic" => true,
      "government_name" => "XXXX to YYYY Example government")
    assert_equal result.historic?, true
    assert_equal result.government_name, "XXXX to YYYY Example government"
  end

  should "have a government name when not in history mode" do
    result = GovernmentResult.new(SearchParameters.new({}), "is_historic" => false,
      "government_name" => "XXXX to YYYY Example government")
    assert_equal result.historic?, false
    assert_equal result.government_name, "XXXX to YYYY Example government"
  end
end
