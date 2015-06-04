module GoogleContactsApi
  # Represents a single group.
  class Group < GoogleContactsApi::Result
    include GoogleContactsApi::Contacts

    attr_reader :json, :group_name, :member_details, :contact_count, :id

    def initialize(source_hash = nil, default = nil, api = nil, &blk)
      # def initialize(original_group, contacts)
      @json = original_group
      @original_group = original_group

      @group_name = original_group["title"]["$t"]

      @member_details = Array.new

      contacts.each do |contact|
        @member_details.push({ name: "#{contact.full_name}", email: "#{contact.primary_email}" })
      end

      @contact_count = @member_details.size

      @id = original_group["id"]["$t"]
    end


    # Return true if this is a system group.
    def system_group?
      !self["gContact$systemGroup"].nil?
    end

    # Return the contacts in this group and cache them.
    def contacts(params = {})
      # contacts in this group
      @contacts ||= get_contacts({"group" => self.id}.merge(params))
    end

    # Return the contacts in this group, retrieving them again from the server.
    def contacts!(params = {})
      # contacts in this group
      @contacts = nil
      contacts
    end

    # Returns the array of links, as link is an array for Hashie.
    def links
      self["link"].map { |l| l.href }
    end

    def self_link
      _link = self["link"].find { |l| l.rel == "self" }
      _link ? _link.href : nil
    end

    def edit_link
      _link = self["link"].find { |l| l.rel == "edit" }
      _link ? _link.href : nil
    end
  end
end