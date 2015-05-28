module GoogleContactsApi
  require 'google_contacts_api/result_set'
  require 'google_contacts_api/result'
  require 'google_contacts_api/group'

  # Initialize a GroupSet from an API response body that contains groups data
  class GroupSet < GoogleContactsApi::ResultSet
    attr_reader :results
    def initialize(response_body, api = nil)
      super
      @results = []

      @entries.each do |e|
        group = GoogleContactsApi::Group.new(e, nil, api)
        @results.push(group)
      end
      @results
    end
  end
end
