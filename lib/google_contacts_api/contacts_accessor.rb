# Module that implements a method to get contacts for a user or group
module GoogleContactsApi
  module ContactsAccessor
    # Retrieve the contacts for this user or group

    CONTACT_RELATIVE_URL = "contacts/default/full"

    def get_contacts(params = {})
      # TODO: Should return empty ContactSet (haven't implemented one yet)
      return [] unless @api
      params = params.with_indifferent_access

      # compose params into a string
      # See http://code.google.com/apis/contacts/docs/3.0/reference.html
      #Parameters: alt, q, max-results, start-index, updated-min,
      # orderby, showdeleted, requirealldeleted, sortorder, group
      params["max-results"] = 100000 unless params.key?("max-results")
      url = CONTACT_RELATIVE_URL
      response = @api.get(url, params)

      # TODO: Define some fancy exceptions
      case GoogleContactsApi::Api.parse_response_code(response)
      when 401; raise
      when 403; raise
      when 404; raise
      when 400...500; raise
      when 500...600; raise
      end
      GoogleContactsApi::ContactSet.new(response.body, @api)
    end

    def post_contact(contact)
      params[:body] = contact.json
      headers = {
        'Content-type' => 'application/json'
      }
      url = CONTACT_RELATIVE_URL
      response = @api.post_v2(url, params, headers)
      GoogleContactsApi::Api.parse_response_code(response)
    end

    def put_contact(contact)
      params = {}
      headers = {
        'Content-type' => 'application/json',
        'If-Match' => '*'
      }
      body = contact.json
      link = CONTACT_RELATIVE_URL + contact.edit_link[/\/(([a-z]|[0-9])+)$/]
      puts "link: #{link}"
      params[:body] = body
      response = @api.put_v2(contact.edit_link, params, headers)
      GoogleContactsApi::Api.parse_response_code(response)
    end

    def put_or_post_contact(contact)
      code = put_contact(contact)
      if code == 404
        post_contact(contact)
      end
    end

  end
end
