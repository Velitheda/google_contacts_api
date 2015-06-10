module GoogleContactsApi

  # Represents a single contact.
  class Contact < GoogleContactsApi::Result

    attr_reader :json, :original_contact

    #this selects the first address in list we have
    def primary_address
      value = first_value_for_key_in_collection(self["gd$structuredPostalAddress"], "gd$formattedAddress")
      value_at_dollar_t(value)
    end

    def website
      first_value_for_key_in_collection(self["gContact$website"], "href")
    end

    def organization
      value = first_value_for_key_in_collection(self["gd$organization"], "gd$orgName")
      value_at_dollar_t(value)
    end

    def job_title
      value = first_value_for_key_in_collection(self["gd$organization"], "gd$orgTitle")
      value_at_dollar_t(value)
    end

    def value_at_dollar_t(hash)
      hash ? hash["$t"] : ""
    end

    def first_value_for_key_in_collection(collection, key)
      value = nil
      if collection && collection.any?
        first = collection.first
        value = first[key] if first.has_key?(key)
      end
      value
    end

    def id
      value_at_dollar_t(self["id"])
    end

    def mobile_number
      @mobile_number
    end

    def phone_number
      @phone_number
    end

    # Returns alternative, possibly off-Google home page link
    def alternate_link
      _link = self["link"].find { |l| l.rel == "alternate" }
      _link ? _link.href : nil
    end

    # Returns link for photo
    # (still need authentication to get the photo data, though)
    def photo_link
      _link = self["link"].find { |l| l.rel == "http://schemas.google.com/contacts/2008/rel#photo" }
      _link ? _link.href : nil
    end

    # Returns binary data for the photo. You can probably
    # use it in a data-uri. This is in PNG format.
    def photo
      return nil unless @api && photo_link
      response = @api.oauth.get(photo_link)

      case GoogleContactsApi::Api.parse_response_code(response)
      # maybe return a placeholder instead of nil
      when 400; return nil
      when 401; return nil
      when 403; return nil
      when 404; return nil
      when 400...500; return nil
      when 500...600; return nil
      else; return response.body
      end
    end

    # Returns link to add/replace the photo
    def edit_photo_link
      _link = self["link"].find { |l| l.rel == "http://schemas.google.com/contacts/2008/rel#edit_photo" }
      _link ? _link.href : nil
    end

    # Returns all phone numbers for the contact
    def phone_numbers
      slef["gd$phoneNumber"] ? self["gd$phoneNumber"].map { |e| e['$t'] } : []
    end

    # Returns all email addresses for the contact
    def emails
      self["gd$email"] ? self["gd$email"].map { |e| e.address } : []
    end

    # Returns primary email for the contact
    def primary_email
      if self["gd$email"]
        _email = self["gd$email"].find { |e| e.primary == "true" }
        _email ? _email.address : nil
      else
        nil # no emails at all
      end
    end

    # Returns all instant messaging addresses for the contact.
    # Doesn't yet distinguish protocols
    def ims
      self["gd$im"] ? self["gd$im"].map { |i| i.address } : []
    end

    # Convenience method to return a nested $t field.
    # If the field doesn't exist, return nil
    def nested_t_field_or_nil(level1, level2)
      if self[level1]
        self[level1][level2] ? self[level1][level2]['$t']: nil
      end
    end
    def given_name
      nested_t_field_or_nil 'gd$name', 'gd$givenName'
    end
    def family_name
      nested_t_field_or_nil 'gd$name', 'gd$familyName'
    end
    def full_name
      nested_t_field_or_nil 'gd$name', 'gd$fullName'
    end
    def additional_name
      nested_t_field_or_nil 'gd$name', 'gd$additionalName'
    end
    def name_prefix
      nested_t_field_or_nil 'gd$name', 'gd$namePrefix'
    end
    def name_suffix
      nested_t_field_or_nil 'gd$name', 'gd$nameSuffix'
    end

    def relations
      self['gContact$relation'] ? self['gContact$relation'] : []
    end

    # Returns the spouse of the contact. (Assumes there's only one.)
    def spouse
      spouse_rel = relations.find {|r| r.rel = 'spouse'}
      spouse_rel['$t'] if spouse_rel
    end

    # Return an Array of Hashes representing addresses with formatted metadata.
    def addresses
      self['gd$structuredPostalAddress'] ? self['gd$structuredPostalAddress'].map(&method(:format_address)) : []
    end

    # Return an Array of Hashes representing phone numbers with formatted metadata.
    def phone_numbers_full
      self["gd$phoneNumber"] ? self["gd$phoneNumber"].map(&method(:format_number)) : []
    end

    # Return an Array of Hashes representing emails with formatted metadata.
    def emails_full
      self["gd$email"] ? self["gd$email"].map(&method(:format_email)) : []
    end

  private

    def format_email(unformatted)
      formatted = {}
      rel = unformatted[:rel]
      unformatted["primary"] ? formatted[:primary] = true : formatted[:primary] = false
      formatted[:address] = unformatted["address"]
      formatted[:rel] = rel.gsub('http://schemas.google.com/g/2005#', '')
      formatted
    end

    def format_number(unformatted)
      formatted = {}
      unformatted["primary"] ? formatted[:primary] = true : formatted[:primary] = false
      formatted[:number] = value_at_dollar_t(unformatted)
      rel = unformatted[:rel]
      formatted[:rel] = rel.gsub('http://schemas.google.com/g/2005#', '')
      formatted
    end

    def format_address(unformatted)
      formatted = {}
      rel = unformatted[:rel]
      formatted[:type] = rel.gsub('http://schemas.google.com/g/2005#', '')
      formatted[:value] = unformatted.value_at_dollar_t("gd$formattedAddress")
      formatted
    end

  end
end