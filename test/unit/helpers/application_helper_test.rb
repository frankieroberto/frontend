require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  class ApplicationHelperContainer
    include ApplicationHelper
    def request
      @request ||= OpenStruct.new(:format => OpenStruct.new(:video? => false))
    end
  end

  def setup
    @helper = ApplicationHelperContainer.new
  end

  def basic_artefact
    OpenStruct.new(section: 'missing', need_id: 'missing', kind: 'missing')
  end

  test "the page title always ends with www.gov.uk" do
    assert_equal 'www.gov.uk', @helper.page_title(basic_artefact).split.last
  end

  test "the page title doesn't contain consecutive pipes" do
    assert_no_match %r{\|\s*\|}, @helper.page_title(basic_artefact)
  end

  test "the page title includes the publication alternative title if one's set" do
    publication = OpenStruct.new(alternative_title: 'I am an alternative', title: 'I am not')
    title = @helper.page_title(basic_artefact, publication)
    assert_match %r{I am an alternative}, title
    assert_no_match %r{I am not}, title
  end

  test "the page title doesn't blow up if the publication titles are nil" do
    publication = OpenStruct.new(title: nil)
    assert @helper.page_title(basic_artefact, publication)
  end

  test "it correctly identifies a video guide in the wrapper classes" do
    @helper.request.format.stubs(:video?).returns(true)
    guide = OpenStruct.new(:type => 'guide')
    assert @helper.wrapper_class(guide).split.include?('video-guide')
  end

  test "should build title from publication and artefact" do
    publication = OpenStruct.new(title: "Title")
    artefact = OpenStruct.new(section: "Section")
    assert_equal "Title | Section | www.gov.uk", @helper.page_title(artefact, publication)
  end

  test "should prefix title of video with video" do
    @helper.request.format.stubs(:video?).returns(true)
    publication = OpenStruct.new(title: "Title")
    assert_match /^Video - Title/, @helper.page_title(basic_artefact, publication)
  end

  test "should omit artefact section if missing" do
    publication = OpenStruct.new(title: "Title")
    artefact = OpenStruct.new(section: "")
    assert_equal "Title | www.gov.uk", @helper.page_title(artefact, publication)
  end

  test "should omit first part of title if publication is omitted" do
    @helper.request.format.stubs(:video?).returns(true)
    artefact = OpenStruct.new(section: "Section")
    assert_equal "Section | www.gov.uk", @helper.page_title(artefact)
  end
end