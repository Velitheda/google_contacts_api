require 'active_support'
require 'active_support/core_ext'

module GoogleContactsApi
  class ApiError < StandardError; end
  class UnauthorizedError < ApiError; end

  class Api
    # keep separate in case of new auth method
    BASE_URL = "https://www.google.com/m8/feeds/"

    attr_reader :oauth
    def initialize(oauth)
      # TODO: Later, accept ClientLogin
      @oauth = oauth
    end

    # Get request to specified link, with query params
    # Raise UnauthorizedError if not authorized.
    def get(link, params = {}, headers = {})
      merged_params = params_with_defaults(params)
      p "params: #{params.inspect}"
      begin
        result = @oauth.get("#{BASE_URL}#{link}?#{merged_params.to_query}", headers)
      rescue => e
        puts "get error"
        # TODO: OAuth 2.0 will raise a real error
        raise UnauthorizedError if defined?(e.response) && self.class.parse_response_code(e.response) == 401
        raise e
      end

      # OAuth 1.0 uses Net::HTTP internally
      raise UnauthorizedError if result.is_a?(Net::HTTPUnauthorized)
      result
    end

    # Post request to specified link, with query params
    # Not tried yet, might be issues with params
    def post(link, params = {}, headers = {})
      @oauth.post("#{BASE_URL}#{link}?#{params.to_query}", headers)
    end

    # Put request to specified link, with query params
    # Not tried yet
    def put(link, params = {}, headers = {})
      @oauth.put("#{BASE_URL}#{link}?#{params.to_query}", headers)
    end

    # Delete request to specified link, with query params
    # Not tried yet
    def delete(link, params = {}, headers = {})
      raise NotImplementedError
      @oauth.delete("#{BASE_URL}#{link}?#{params.to_query}", headers)
    end

    # Parse the response code
    # Needed because of difference between oauth and oauth2 gems
    def self.parse_response_code(response)
      (defined?(response.code) ? response.code : response.status).to_i
    end

    private

    def params_with_defaults(params)
      p = params
      p['v'] = '3' unless p['v']
      p
    end
  end
end