require 'nokogiri'

module GoogleContactsApi
  # Base class for GroupSet and ContactSet that generically represents
  # a set of results.
  class XmlResultSet
    include Enumerable
    attr_reader :api
    attr_accessor :total_results, :start_index, :items_per_page, :parsed

    # Initialize a new ResultSet from the response, with the given
    # GoogleContacts::Api object if specified.
    def initialize(response_body, api = nil)
      @api = api
      parse(response_body)
      @results = []
    end

    def parse(response_body)
      @xml = Nokogiri::XML(response_body)
      @xml.remove_namespaces!

      @entries = @xml.xpath("//entry")
      @entries
    end

  end
end