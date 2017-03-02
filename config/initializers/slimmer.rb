Frontend::Application.configure do
  config.slimmer.logger = Rails.logger

  if Rails.env.development?
    config.slimmer.asset_host = ENV['PLEK_SERVICE_STATIC_URI'] || "http://static.dev.gov.uk"
  end
end
