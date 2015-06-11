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
    # For get, post, put, delete, always use JSON, it's simpler
    # and lets us use Hashie::Mash. Note that in the JSON conversion from XML,
    # ":" is replaced with $, element content is keyed with $t
    # Raise UnauthorizedError if not authorized.
    def get(link, params = {}, headers = {})
      puts "getting something"
      merged_params = params_with_defaults(params)
      begin
        result = @oauth.get("#{BASE_URL}#{link}?#{merged_params.to_query}", headers)
      rescue => e
        # TODO: OAuth 2.0 will raise a real error
        raise UnauthorizedError if defined?(e.response) && self.class.parse_response_code(e.response) == 401
        raise e
      end

      # OAuth 1.0 uses Net::HTTP internally
      raise UnauthorizedError if result.is_a?(Net::HTTPUnauthorized)
      result
    end

    # these two methods will replace my previous two, but they aren't wired up to
    # the rest of the code yet
    # Post request to specified link, with query params
    def post_v2(link, params = {}, headers = {})
      merged_params = params_with_defaults(params)
      uri = "#{BASE_URL}#{link}?#{merged_params.to_query}"
      begin
        response = @oauth.post(uri, headers)
      rescue => e
        raise UnauthorizedError if defined?(e.response) && self.class.parse_response_code(e.response) == 401
        raise e
      end
    end

    # Put request to specified link, with query params
    def put_v2(link, params = {}, headers = {})
      # Doesn't handle id yet
      merged_params = params_with_defaults(params)
      uri = "#{BASE_URL}#{link}?#{merged_params.to_query}"
      begin
        response = @oauth.put(uri, headers)
      rescue => e
        raise UnauthorizedError if defined?(e.response) && self.class.parse_response_code(e.response) == 401
        raise e
      end
    end

    def post(contact)
      options ={
        headers: {
          'Content-type' => 'application/json'
          },
        body: contact.entry_json
      }
      merged_params = params_with_defaults(options)
      uri = URI.parse("https://www.google.com/m8/feeds/contacts/default/full/")

      response = @oauth.post(uri, merged_params)
    end

    # Put request to specified link, with query params
    def put(contact)
      options ={
        headers: {
          'Content-type' => 'application/json',
          'If-Match' => '*'
          },
        body: contact.entry_json
      }
      merged_params = params_with_defaults(options)

      uri = URI.parse(contact.edit_link)
      begin
        response = @oauth.put(uri, merged_params)
      rescue => e
        GoogleContactsApi::Api.parse_response_code(e.response)
      end
    end

    def post_group(group)
      options ={
        headers: {
          'Content-type' => 'application/json'
          },
        body: group.entry_json
      }
      merged_params = params_with_defaults(options)
      uri = URI.parse("https://www.google.com/m8/feeds/groups/default/full/")

      response = @oauth.post(uri, merged_params)
    end

    def put_group(group)
      options ={
        headers: {
          'Content-type' => 'application/json',
          'If-Match' => '*'
          },
        body: group.entry_json
      }
      merged_params = params_with_defaults(options)

      uri = URI.parse(group.edit_link)
      begin
        response = @oauth.put(uri, merged_params)
        GoogleContactsApi::Api.parse_response_code(response)
      rescue => e
        GoogleContactsApi::Api.parse_response_code(e.response)
      end
    end

    # Delete request to specified link, with query params
    # Not tried yet
    def delete(link, params = {}, headers = {})
      raise NotImplementedError
      params["alt"] = "json"
      @oauth.delete("#{BASE_URL}#{link}?#{params.to_query}", headers)
    end

    # Parse the response code
    # Needed because of difference between oauth and oauth2 gems
    def self.parse_response_code(response)
      (defined?(response.code) ? response.code : response.status).to_i
    end

    private

    def params_with_defaults(params)
      p = params.merge({
        "alt" => "json"
      })
      p['v'] = '3' unless p['v']
      p
    end
  end
end