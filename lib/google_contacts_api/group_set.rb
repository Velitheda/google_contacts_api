module GoogleContactsApi
  class GroupSet < GoogleContactsApi::ResultSet
    # Initialize a GroupSet from an API response body that contains groups data
    def initialize(response_body, api = nil)
      super
      puts "setting results"
      @results = @parsed.feed.entry.map { |e| GoogleContactsApi::Group.new(e, nil, api) }
      puts "results: #{@results.as_json}"
      @results.each do |result|
        puts result.as_json
      end
      @results
    end
  end
end