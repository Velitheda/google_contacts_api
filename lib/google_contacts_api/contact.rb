module GoogleContactsApi
  # Represents a single contact.
  # Methods we could implement:
  # :categories, (:content again), :links, (:title again), :email
  # :extended_properties, :deleted, :im, :name,
  # :organizations, :phone_numbers, :structured_postal_addresses, :where
  class Contact < GoogleContactsApi::Result
    # Returns the array of links, as link is an array for Hashie.
    def links
      @links = node_attribute("link", "href")
    end

    # Returns link to get this contact
    def self_link
      @self_link = @node.xpath(".//link[@rel='self']/@href").text
    end

    # I haven't seen an example of this in my output

    # Returns alternative, possibly off-Google home page link
    def alternate_link
      @alternate_link = @node.xpath(".//link[@rel='alternate']/@href").text
    end

    # Returns link for photo
    # (still need authentication to get the photo data, though)
    def photo_link
      @photo_link = @node.xpath(".//link[@type='image/*']/@href").text
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

    # haven't seen this in the output either

    # Returns link to add/replace the photo
    def edit_photo_link
      _link = self["link"].find { |l| l.rel == "http://schemas.google.com/contacts/2008/rel#edit_photo" }
      _link ? _link.href : nil
    end

    # Returns link to edit the contact
    def edit_link
      @edit_link = @node.xpath(".//link[@rel='edit']/@href").text
    end

    # Returns all phone numbers for the contact
    def phone_numbers
      @phone_numbers = something("phoneNumber")
    end

    def mobile_number
      numbers = phone_numbers
      @mobile_number = ""
      numbers.each do |number|
        if number["type"].eql?("mobile")
          @mobile_number = number["value"]
        end
      end
      @mobile_number
    end

    def phone_number
      numbers = phone_numbers
      @phone_number = ""
      numbers.each do |number|
        unless number["type"].eql?("mobile")
          @phone_number = number["value"]
          return @phone_number
        end
      end
      @phone_number
    end

    # Returns all email addresses for the contact
    def emails
      @emails = attribute_array("email", "address")
    end

    # Returns primary email for the contact
    def primary_email
      @primary_email = @node.xpath(".//email[@primary='true']/@address").text
    end

    # Returns all instant messaging addresses for the contact.
    # Doesn't yet distinguish protocols
    def ims
      @im = nodeAttribute("im", "address")
      # self["gd$im"] ? self["gd$im"].map { |i| i.address } : []
    end

    def given_name
      @first_name = node_value("givenName")
    end
    def family_name
      @family_name = node_value("familyName")
    end
    def full_name
      @full_name = node_value("fullName")
    end
    def additional_name
      @additional_name = node_value("additionalName")
    end
    def name_prefix
      @name_prefix = node_value("namePrefix")
    end
    def name_suffix
      @name_suffix = node_value("nameSuffix")
    end
    def nickname
      @nickname = node_value("nickname")
    end

    def organization
      @organization = node_value("orgName")
    end

    def job_title
      @job_title = node_value("orgTitle")
    end

    def relations
      @relations = node_value("relation")
    end

    # Returns the spouse of the contact. (Assumes there's only one.)
    def spouse
      @spouse = @node.xpath(".//relation[@rel='spouse']").text
    end

    def website
      @website = {}
      site_type = node_attribute("website", "rel").text
      site = node_attribute("website", "href").text
      @website["type"] = site_type
      @website["value"] = site
    end

    def addresses
      @addresses = value_array("structuredPostalAddress", "formattedAddress")
    end

    def primary_address
      if addresses.first
        @primary_address = addresses.first["value"]
      end
    end

  end
end