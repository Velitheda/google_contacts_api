require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

class MockOAuth2Error < StandardError
  attr_accessor :response

  def initialize(response)
    @response = response
  end
end