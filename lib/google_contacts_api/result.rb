require 'hashie'

module GoogleContactsApi
  # Base class for Group and Contact.
  # In the JSON responses, ":" from the equivalent XML response is replaced
  # with a "$", while element content is instead keyed with "$t".
  class Result < Hashie::Mash
    attr_reader :api, :json
    # Initialize a Result from a single result's Hash/Hashie
    def initialize(source_hash = nil, default = nil, api = nil, &blk)
      @api = api if api
      @json = source_hash
      super(source_hash, default, &blk)
    end

    def entry_json
      # wrap in entry
      hash = {}
      hash["entry"] = @json
      entry_json = JSON.pretty_generate(hash)
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

    # TODO: Conditional retrieval? There might not be an etag in the
    # JSON representation, there is in the XML representation
    def etag
    end

    def id
      _id = self["id"]
      _id ? _id["$t"] : nil
    end

    def links
      self["link"].map { |l| l.href }
    end

    # Returns link to get this result
    def self_link
      _link = self["link"].find { |l| l.rel == "self" }
      _link ? _link.href : nil
    end

    # Returns link to edit the result
    def edit_link
      _link = self["link"].find { |l| l.rel == "edit" }
      _link ? _link.href : nil
    end

    # For Contacts, returns the (full) name.
    # For Groups, returns the name of the group.
    def title
      _title = self["title"]
      _title ? _title["$t"] : nil
    end

    def content
      _content = self["content"]
      _content ? _content["$t"] : nil
    end

    def updated
      _updated = self["updated"]
      _updated ? DateTime.parse(_updated["$t"]) : nil
    end

    # Returns the array of categories, as category is an array for Hashie.
    # There is a scheme and a term.
    def categories
      category
    end

    def deleted?
      raise NotImplementedError
    end

    def inspect
      "<#{self.class}: #{title}>"
    end
  end
end