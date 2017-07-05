class PollingStationController < ApplicationController
  def index
  end

  def find
    if polling_station.success?
      redirect_to polling_station_details_path(postcode: postcode)
    else
      redirect_to polling_station_not_found_path
    end
  end

  def not_found
  end

  def result
    render :results, locals: { address: polling_station_address, demo_url: remote_url }
  end

  private

  def postcode
    params[:postcode]
  end

  def polling_station_address
    polling_station['properties']['address']
  end

  def remote_url
    polling_station['properties']['urls']['detail']
  end

  def polling_station
    @_polling_station ||= begin
      WhereDoIVote::PollingStationFinder.by_postcode(postcode)
    end
  end
end
