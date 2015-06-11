require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

class MockOAuth2Error < StandardError
  attr_accessor :response

  def initialize(response)
    @response = response
  end
end

describe "GoogleContactsApi" do

  describe GoogleContactsApi::Contacts do
    let(:api) { double("api") }
    let(:test_class) {
      Class.new do
        include GoogleContactsApi::Contacts
        def initialize(api)
          @api = api
        end
      end
    }
    describe ".get_contacts" do
      it "should get the contacts using the internal @api object" do
        expect(api).to receive(:get).with("contacts/default/full", kind_of(Hash)).and_return(Hashie::Mash.new({
          "body" => "some response", # could use example response here
          "code" => 200
        }))
        allow(GoogleContactsApi::ContactSet).to receive(:new).and_return("contact set")
        expect(test_class.new(api).get_contacts).to eq("contact set")
      end
    end

    describe ".post_contact" do
      it "should get the contacts using the internal @api object" do
        expect(api).to receive(:get).with("contacts/default/full", kind_of(Hash)).and_return(Hashie::Mash.new({
          "body" => "some response", # could use example response here
          "code" => 200
        }))
        allow(GoogleContactsApi::ContactSet).to receive(:new).and_return("contact set")
        expect(test_class.new(api).get_contacts).to eq("contact set")
      end
    end

  end

  describe GoogleContactsApi::Groups do
    let(:api) { double("api") }
    let(:test_class) {
      Class.new do
        include GoogleContactsApi::Groups
        def initialize(api)
          @api = api
        end
      end
    }
    describe ".get_groups" do
      it "should get the groups using the internal @api object" do
        expect(api).to receive(:get).with("groups/default/full", kind_of(Hash)).and_return(Hashie::Mash.new({
          "body" => "some response", # could use example response here
          "code" => 200
        }))
        allow(GoogleContactsApi::GroupSet).to receive(:new).and_return("group set")
        expect(test_class.new(api).get_groups).to eq("group set")
      end
    end
  end

end
