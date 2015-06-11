module GoogleContactsApi
  class User
    include GoogleContactsApi::ContactsAccessor
    include GoogleContactsApi::GroupsAccessor

    attr_reader :api
    def initialize(oauth)
      @api = GoogleContactsApi::Api.new(oauth)
    end

    # Return the contacts for this user and cache them.
    def contacts(params = {})
      # contacts in this group
      @contacts ||= get_contacts(params)
    end

    # def get_contacts(params = {})
    #   puts "getting contacts"
    #   # TODO: Should return empty ContactSet (haven't implemented one yet)
    #   return [] unless @api
    #   params = params.with_indifferent_access

    #   # compose params into a string
    #   # See http://code.google.com/apis/contacts/docs/3.0/reference.html#Parameters
    #   # alt, q, max-results, start-index, updated-min,
    #   # orderby, showdeleted, requirealldeleted, sortorder, group
    #   params["max-results"] = 100000 unless params.key?("max-results")
    #   url = "contacts/default/full"
    #   response = @api.get(url, params)

    #   # TODO: Define some fancy exceptions
    #   case GoogleContactsApi::Api.parse_response_code(response)
    #   when 401; raise
    #   when 403; raise
    #   when 404; raise
    #   when 400...500; raise
    #   when 500...600; raise
    #   end
    #   GoogleContactsApi::ContactSet.new(response.body, @api)
    # end

    # Return the contacts for this user, retrieving them again from the server.
    def contacts!(params = {})
      # contacts in this group
      @contacts = nil
      contacts(params)
    end

    # Return the groups for this user and cache them.
    def groups(params = {})
      @groups ||= get_groups(params)
    end

    # def get_groups(params = {})
    #   puts "getting groups"
    #   params = params.with_indifferent_access
    #   # compose params into a string
    #   # See http://code.google.com/apis/contacts/docs/3.0/reference.html#Parameters
    #   # alt, q, max-results, start-index, updated-min,
    #   # orderby, showdeleted, requirealldeleted, sortorder
    #   params["max-results"] = 100000 unless params.key?("max-results")

    #   url = "groups/default/full"
    #   response = @api.get(url, params)

    #   case GoogleContactsApi::Api.parse_response_code(response)
    #   # TODO: Better handle 401, 403, 404
    #   when 401; raise
    #   when 403; raise
    #   when 404; raise
    #   when 400...500; raise
    #   when 500...600; raise
    #   end
    #   GoogleContactsApi::GroupSet.new(response.body, @api)
    # end

    # Return the groups for this user, retrieving them again from the server.
    def groups!(params = {})
      @groups = nil
      groups(params)
    end

    def save_contact(json)
      contact = Contact.new(json, nil, @api)
      code = @api.put(contact)
      if code == 404
        @api.post(contact)
      end
    end

    def save_group(json)
      group = Group.new(json["original_group"], nil, @api)
      code = @api.put_group(group)
      if code == 404
        @api.post_group(group)
      end
    end

  end
end
