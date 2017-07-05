require 'frontend'

Frontend::Application.routes.draw do
  get "/homepage" => redirect("/")

  get "/search" => "search#index", as: :search
  get "/search/opensearch" => "search#opensearch"

  get "/random" => "random#random_page"

  # Crude way of handling the situation described at
  # http://stackoverflow.com/a/3443678
  get "*path.gif", to: proc { |env| [404, {}, ["Not Found"]] }

  get "/find-local-council" => "find_local_council#index"
  post "/find-local-council" => "find_local_council#find"
  get "/find-local-council/:authority_slug" => "find_local_council#result"

  get '/foreign-travel-advice', to: "travel_advice#index", as: :travel_advice

  # Help pages
  get "/help", to: "help#index"
  get "/help/ab-testing", to: "help#ab_testing"
  get "/tour", to: "help#tour"

  # polling station pages
  get "/find-polling-station", to: "polling_station#index"
  post "/find-polling-station", to: "polling_station#find"
  get "/find-polling-station/:postcode", to: "polling_station#result", as: 'polling_station_details'
  get "/polling-station-not-found", to: "polling_station#not_found", as: 'polling_station_not_found'
  # Done pages
  constraints FormatRoutingConstraint.new('completed_transaction') do
    get "*slug", slug: %r{done/.+}, to: "completed_transaction#show"
  end

  # Simple Smart Answer pages
  get ":slug/y(/*responses)" => "simple_smart_answers#flow", :as => :smart_answer_flow
  constraints FormatRoutingConstraint.new('simple_smart_answer') do
    get ":slug", to: "simple_smart_answers#show", as: "simple_smart_answer"
    get ":slug/:part", to: redirect('/%{slug}') # Support for simple smart answers that were once a format with parts
  end

  # Transaction pages
  constraints FormatRoutingConstraint.new('transaction') do
    get ":slug", slug: %r{(jobsearch|chwilio-am-swydd)}, to: "transaction#jobsearch"
    get ":slug", to: "transaction#show"
  end

  # Local Transaction pages
  constraints FormatRoutingConstraint.new('local_transaction') do
    get ":slug", to: "local_transaction#search", as: 'local_transaction_search'
    post ":slug", to: "local_transaction#search"
    get ":slug/:local_authority_slug", to: "local_transaction#results", as: 'local_transaction_results'
  end

  # Place pages
  constraints FormatRoutingConstraint.new('place') do
    get ":slug", to: "place#show"
    post ":slug", to: "place#show" # Support for postcode submission which we treat as confidential data
    get ":slug/:part", to: redirect('/%{slug}') # Support for places that were once a format with parts
  end

  # Licence pages
  constraints FormatRoutingConstraint.new('licence') do
    get ":slug", to: "licence#start", as: "licence"
    post ":slug", to: "licence#start" # Support for postcode submission which we treat as confidential data
    get ":slug/:authority_slug(/:interaction)", to: "licence#authority", as: "licence_authority"
  end

  # route API errors to the error handler
  constraints ApiErrorRoutingConstraint.new do
    get "*any", to: "error#handler"
  end

  root to: 'homepage#index', via: :get
end
