module GoogleContactsApi
  # Represents a single group.
  require 'google_contacts_api/contacts'
  class Group < GoogleContactsApi::Result
    include GoogleContactsApi::Contacts

    # Return true if this is a system group.
    def system_group?
      !nodeValue("systemGroup").nil?
    end

    # Return the contacts in this group and cache them.
    def contacts(params = {})
      # contacts in this group
      @contacts ||= get_contacts({"group" => id}.merge(params))
    end

    # Return the contacts in this group, retrieving them again from the server.
    def contacts!(params = {})
      # contacts in this group
      @contacts = nil
      contacts
    end

    # Returns the array of links, as link is an array for Hashie.
    def links
      @links = nodeAttribute("link", "href")
    end

    def self_link
      @self_link = @node.xpath(".//link[@rel='self']/@href").text
    end

    def edit_link
      @self_link = @node.xpath(".//link[@rel='edit']/@href").text
    end

    def group_name
      @group_name = title
    end

    def as_json(options={})
      options[:except] ||= ["api", "node", "contacts"]
      super(options)
    end

  end
end