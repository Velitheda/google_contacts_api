require 'nokogiri'

module GoogleContactsApi
  # Base class for Group and Contact.
  class Result
    attr_reader :api
    # Initialize a Result from a single result's Hash/Hashie
    def initialize(source_hash = nil, default = nil, api = nil, &blk)
      @api = api if api

      @node = source_hash

      # p "id: #{id}"
      # p "title: #{title}"
      # p "etag: #{etag}"
      # p "content: #{content}"
      # p "updated: #{updated}"
      # p "category: #{categories}"
      # p "etag: #{etag}"
    end

# node value text
    def node_value(string)
      @node.xpath(".//#{string}").text
    end

# def node value
    def node_attribute(string, attribute_name)
      @node.xpath(".//#{string}/@#{attribute_name}")
    end

    def attribute(attribute_string)
      object.xpath("./@#{attribute_string}").text
    end

    def types_and_values(string, xpath_string)
      array = []
      values = @node.xpath(".//#{string}")
      values.each do |object|
        hash = {}
        key = get_key(object)
        value = object.xpath("#{xpath_string}").text
        hash["type"] = key
        hash["value"] = value
        array.push(hash)
      end
      array
    end

  #structured postal address, formatted address
    def value_array(string, value_string)
      value_string = ".//" << value_string
      types_and_values(string, value_string)
    end

    def attribute_array(string)
      types_and_values(string, ".")
    end

    def node_attribute_array(string, attribute_string)
      types_and_values(string, "./@#{attribute_string}")
    end

    def get_key(object)
      rel_key = object.xpath("./@rel").text
      rel_key = strip_schema_tag(rel_key)
      label_key = object.xpath("./@label").text
      key = nil
      if !rel_key.empty?
        key = rel_key
      else
        key = label_key
      end
    end

    def strip_schema_tag(string)
      string.sub("http://schemas.google.com/g/2005#", "")
    end

    def etag
      @etag = @node.xpath("./@etag").text
    end

    def id
      @id = node_value("id")
    end

    # For Contacts, returns the (full) name.
    # For Groups, returns the name of the group.
    def title
      @title = node_value("title")
    end

    def content
      @content = node_value("content")
    end

    def updated
      @updated = node_value("updated")
    end

    # Returns the array of categories, as category is an array for Hashie.
    # There is a scheme and a term.
    def categories
      @categories = node_attribute("category", "term")
    end

    def deleted?
      raise NotImplementedError
    end

    # def inspect
    #   "<#{self.class}: #{title}>"
    # end

    def as_json(options={})
      options[:except] ||= ["api", "node"]
      super(options)
    end

  end
end
