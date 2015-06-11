module GoogleContactsApi
  # Represents a single group.
  class Group < GoogleContactsApi::Result
    include GoogleContactsApi::ContactsAccessor

    attr_accessor :contacts

    # Return true if this is a system group.
    def system_group?
      !self["gContact$systemGroup"].nil?
    end

    # Return the contacts in this group and cache them.
    def contacts(params = {})
      # puts "api: #{@api}"
      # puts "user: #{@user}"
      # contacts in this group
      @contacts ||= get_contacts({"group" => self.id}.merge(params))
    end

    # Return the contacts in this group, retrieving them again from the server.
    def contacts!(params = {})
      # contacts in this group
      @contacts = nil
      contacts
    end

  end
end