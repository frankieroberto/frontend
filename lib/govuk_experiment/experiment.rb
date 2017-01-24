module GovukExperiment
  class Experiment
    attr_reader :experiment_name, :request

    # @param experiment_name [String] Lowercase experiment name, like `example`
    # @param request [ApplicationController::Request] the `request` in the
    # controller. Optional.
    def initialize(experiment_name, request = nil)
      @experiment_name = experiment_name
      @request = request
    end

    # Get the bucket this user is in
    #
    # @return [String] the current variant, "A" or "B"
    def variant_name
      raise(ArgumentError, "You need to provide a `request` object to fetch the variant") unless request
      request.headers[request_header] == "B" ? "B" : "A"
    end

    # HTML meta tag used to track the results of your experiment
    #
    # @return [String]
    def analytics_meta_tag
      '<meta name="govuk:ab-test:' + cookie_name + ':current-bucket" content="' + variant_name + '">'
    end

    # Internal name of the header
    def request_header
      "HTTP_GOVUK_ABTEST_#{experiment_name.upcase}"
    end

    def response_header
      "GOVUK-ABTest-#{cookie_name}"
    end

    # `example` -> `Example`
    def cookie_name
      experiment_name.capitalize
    end
  end
end
