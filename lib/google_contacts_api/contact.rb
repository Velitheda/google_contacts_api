module GoogleContactsApi
  # Represents a single contact.
  class Contact < GoogleContactsApi::Result
    attr_reader :json, :original_contact

        def initialize(source_hash = nil, default = nil, api = nil, &blk)
          super
          @json = source_hash
          @original_contact = source_hash
          # initialize_numbers
        end

        def initialize_numbers
          numbers = phone_numbers_full
          numbers_hash = Hash.new

          numbers.each do | number |
            numbers_hash[ number[:rel] ] = number[:number]
          end

          @mobile_number = numbers_hash["mobile"]
          numbers_hash.delete("mobile")

          if numbers_hash.any?
            @phone_number = numbers_hash.first[1]
          end
        end

        def entry_json
          # wrap in entry
          hash = {}
          hash["entry"] = @original_contact
          entry_json = JSON.pretty_generate(hash)
        end

        #this selects the first address in list we have
        def primary_address
          value = first_value_for_key_in_collection(@json["gd$structuredPostalAddress"], "gd$formattedAddress")
          value_at_dollar_t(value)
        end

        def website
          first_value_for_key_in_collection(@json["gContact$website"], "href")
        end

        def organization
          value = first_value_for_key_in_collection(@json["gd$organization"], "gd$orgName")
          value_at_dollar_t(value)
        end

        def job_title
          value = first_value_for_key_in_collection(@json["gd$organization"], "gd$orgTitle")
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
          value_at_dollar_t(@json["id"])
        end

        def mobile_number
          @mobile_number
        end

        def phone_number
          @phone_number
        end

    def links
      @json["link"].map { |l| l.href }
    end

    # Returns link to get this contact
    def self_link
      _link = self["link"].find { |l| l.rel == "self" }
      _link ? _link.href : nil
    end

    # Returns alternative, possibly off-Google home page link
    def alternate_link
      _link = @json["link"].find { |l| l.rel == "alternate" }
      _link ? _link.href : nil
    end

    # Returns link for photo
    # (still need authentication to get the photo data, though)
    def photo_link
      _link = @json["link"].find { |l| l.rel == "http://schemas.google.com/contacts/2008/rel#photo" }
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
      _link = @json["link"].find { |l| l.rel == "http://schemas.google.com/contacts/2008/rel#edit_photo" }
      _link ? _link.href : nil
    end

    # Returns link to edit the contact
    def edit_link
      _link = @json["link"].find { |l| l.rel == "edit" }
      _link ? _link.href : nil
    end

    # Returns all phone numbers for the contact
    def phone_numbers
      @json["gd$phoneNumber"] ? @json["gd$phoneNumber"].map { |e| e['$t'] } : []
    end

    # Returns all email addresses for the contact
    def emails
      @json["gd$email"] ? @json["gd$email"].map { |e| e.address } : []
    end

    # Returns primary email for the contact
    def primary_email
      if @json["gd$email"]
        _email = @json["gd$email"].find { |e| e.primary == "true" }
        _email ? _email.address : nil
      else
        nil # no emails at all
      end
    end

    # Returns all instant messaging addresses for the contact.
    # Doesn't yet distinguish protocols
    def ims
      @json["gd$im"] ? @json["gd$im"].map { |i| i.address } : []
    end

    # Convenience method to return a nested $t field.
    # If the field doesn't exist, return nil
    def nested_t_field_or_nil(level1, level2)
      if @json[level1]
        @json[level1][level2] ? @json[level1][level2]['$t']: nil
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
      @json['gContact$relation'] ? @json['gContact$relation'] : []
    end

    # Returns the spouse of the contact. (Assumes there's only one.)
    def spouse
      spouse_rel = relations.find {|r| r.rel = 'spouse'}
      spouse_rel['$t'] if spouse_rel
    end

    # Return an Array of Hashes representing addresses with formatted metadata.
    def addresses
      @json['gd$structuredPostalAddress'] ? @json['gd$structuredPostalAddress'].map(&method(:format_address)) : []
    end

    # Return an Array of Hashes representing phone numbers with formatted metadata.
    def phone_numbers_full
      @json["gd$phoneNumber"] ? @json["gd$phoneNumber"].map(&method(:format_phone_number)) : []
    end

    # Return an Array of Hashes representing emails with formatted metadata.
    def emails_full
      @json["gd$email"] ? @json["gd$email"].map(&method(:format_email)) : []
    end

  private
    def format_address(unformatted)
      formatted = {}
      formatted[:rel] = unformatted['rel'] ? unformatted['rel'].gsub('http://schemas.google.com/g/2005#', '') : 'work'
      unformatted.delete 'rel'
      unformatted.each do |key, value|
        formatted[key.sub('gd$', '').underscore.to_sym] = value['$t']
      end
      formatted
    end

    def format_email_or_phone(unformatted)
      formatted = {}
      unformatted.each do |key, value|
        formatted[key.underscore.to_sym] = value ? value.gsub('http://schemas.google.com/g/2005#', '') : value
      end
      formatted[:primary] = unformatted['primary'] ? unformatted['primary'] == 'true' : false
      formatted
    end

    def format_phone_number(unformatted)
      unformatted[:number] = unformatted['$t']
      unformatted.delete '$t'
      format_email_or_phone unformatted
    end
    def format_email(unformatted)
      format_email_or_phone unformatted
    end
  end
end