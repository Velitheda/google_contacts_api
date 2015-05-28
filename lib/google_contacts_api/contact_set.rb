module GoogleContactsApi
  # Represents a set of contacts.
  require 'google_contacts_api/result_set'
  require 'google_contacts_api/result'
  require 'google_contacts_api/contact'
  class ContactSet < GoogleContactsApi::ResultSet

    attr_reader :results
    # Initialize a ContactSet from an API response body that contains contacts data
    def initialize(response_body, api = nil)
      super
      @results = []

      @entries.each do |e|
        # puts e
        contact = GoogleContactsApi::Contact.new(e, nil, api)
        @results.push(contact)
        # p "full_name: #{contact.full_name}"
        # p "first_name: #{contact.given_name}"
        # p "family_name: #{contact.family_name}"
        # p "email: #{contact.primary_email}"
        # contact.emails.each { |email| p email }
        # contact.phone_numbers.each { |number| p number }
        # p "company_name: #{contact.organization}"
        # p "job_title: #{contact.job_title}"
        # p "spouse: #{contact.spouse}"
        # p "addresses: #{contact.addresses}"
        # p "avatar: #{contact.photo_link}"
        # p "mobile: #{contact.mobile_number}"
        # p "phone: #{contact.phone_number}"
        # p "website: #{contact.website}"
        # p "nickname: #{contact.nickname}"
      end
      @results
    end
  end
end