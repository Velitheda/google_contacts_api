require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

describe GoogleContactsApi::ContactsAccessor do
    let(:api) { double("api") }
    let(:test_class) {
      Class.new do
        include GoogleContactsApi::ContactsAccessor
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