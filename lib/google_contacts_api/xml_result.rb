# require 'hashie'
require 'nokogiri'

module GoogleContactsApi
  # Base class for Group and Contact.
  # In the JSON responses, ":" from the equivalent XML response is replaced
  # with a "$", while element content is instead keyed with "$t".
  class XmlResult #<Nokogiri::XML::Node
    attr_reader :api
    # Initialize a Result from a single result's Hash/Hashie
    def initialize(source_hash = nil, default = nil, api = nil, &blk)
      @api = api if api

      @node = source_hash

      p "id: #{id}"
      p "title: #{title}"
      p "etag: #{etag}"
      p "content: #{content}"
      p "updated: #{updated}"
      p "category: #{categories}"
      p "etag: #{etag}"
    end

    def nodeValue(string)
       @node.xpath(".//#{string}").text
    end

    def nodeAttribute(string, attributeName)
       @node.xpath(".//#{string}/@#{attributeName}")
    end

    def value_array(string, value_string)
      array = []
      values = @node.xpath(".//#{string}")
      values.each do |object|
        hash = {}
        key = get_key(object)
        value = object.xpath(".//#{value_string}").text
        hash["type"] = key
        hash["value"] = value
        array.push(hash)
      end
      array
    end

    def something(string)
      array = []
      values = @node.xpath(".//#{string}")
      values.each do |object|
        hash = {}
        key = get_key(object)
        value = object.xpath(".").text
        hash["type"] = key
        hash["value"] = value
        array.push(hash)
      end
      array
    end

    def attribute_array(string, attribute_string)
      array = []
      values = @node.xpath(".//#{string}")
      values.each do |object|
        hash = {}
        key = get_key(object)
        value = object.xpath("./@#{attribute_string}").text
        hash["type"] = key
        hash["value"] = value
        array.push(hash)
      end
      array
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
      @id = nodeValue("id")
    end

    # For Contacts, returns the (full) name.
    # For Groups, returns the name of the group.
    def title
      @title = nodeValue("title")
    end

    def content
      @content = nodeValue("content")
    end

    def updated
      @updated = nodeValue("updated")
    end

    # Returns the array of categories, as category is an array for Hashie.
    # There is a scheme and a term.
    def categories
      @categories = nodeAttribute("category", "term")
    end

    def deleted?
      raise NotImplementedError
    end

    def inspect
      "<#{self.class}: #{title}>"
    end
  end
end