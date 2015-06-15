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

    # Return the groups for this user, retrieving them again from the server.
    def groups!(params = {})
      @groups = nil
      groups(params)
    end

    def save_contact(json)
      contact = Contact.new(json, nil, @api)
      put_or_post_contact(contact)
    end

    def save_group(json)
      group = Group.new(json["original_group"], nil, @api)
      put_or_post_group(group)
    end

  end
end
