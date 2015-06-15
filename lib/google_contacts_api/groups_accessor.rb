# Module that implements a method to get groups for a user
module GoogleContactsApi
  module GroupsAccessor
    # Retrieve the contacts for this user or group
    def get_groups(params = {})
      params = params.with_indifferent_access
      # compose params into a string
      # See http://code.google.com/apis/contacts/docs/3.0/reference.html#Parameters
      # alt, q, max-results, start-index, updated-min,
      # orderby, showdeleted, requirealldeleted, sortorder
      params["max-results"] = 100000 unless params.key?("max-results")

      url = "groups/default/full"
      response = @api.get(url, params)

      case GoogleContactsApi::Api.parse_response_code(response)
      # TODO: Better handle 401, 403, 404
      when 401; raise
      when 403; raise
      when 404; raise
      when 400...500; raise
      when 500...600; raise
      end
      GoogleContactsApi::GroupSet.new(response.body, @api)
    end

    def post_group(group)
      params = {}
      headers = {
          'Content-type' => 'application/json'
          }
      body = group.json
      params[:body] = body
      url = "groups/default/full"
      response = @api.post_v2(url, params, headers)
      GoogleContactsApi::Api.parse_response_code(response)
    end

    def put_group(group)
      params = {}
      headers = {
          'Content-type' => 'application/json'
          }
      body = group.json
      params[:body] = body
      response = @api.put_v2(group.edit_link, params, headers)
      GoogleContactsApi::Api.parse_response_code(response)
    end

    def put_or_post(group)
      code = put_group(group)
      if code == 404
        post_group(group)
      end
    end
  end
end