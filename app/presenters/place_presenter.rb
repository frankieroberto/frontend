class PlacePresenter < ContentItemPresenter
  PASS_THROUGH_DETAILS_KEYS = %i(
    introduction
    more_information
    need_to_know
    place_type
  ).freeze

  PASS_THROUGH_DETAILS_KEYS.each do |key|
    define_method key do
      details[key.to_s] if details
    end
  end

  def initialize(content_item, places = nil)
    @content_item = content_item
    @places = places
  end

  def places
    if @places
      @places.map do |place|
        place['text']    = place['url'].truncate(36) if place['url']
        place['address'] = [place['address1'], place['address2']].compact.map(&:strip).join(", ")
        place
      end
    end
  end
end
