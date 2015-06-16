require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

describe GoogleContactsApi::ContactsAccessor do
    before(:all) do
      @contact_json_hash = contact_json_hash
      @contact = GoogleContactsApi::Contact.new(@contact_json_hash)
    end

    let(:api) { double("api") }
    let(:stubbed_contacts_accessor_class) {
      Class.new do
        include GoogleContactsApi::ContactsAccessor
        def initialize(api)
          @api = api
        end
      end
    }
    describe ".get_contacts" do
      it "should get the contacts using the internal @api object" do
        expect(api).to receive(:get).with(
          "contacts/default/full",
          kind_of(Hash)
        ).and_return(Hashie::Mash.new({
          "body" => "some response",
          "code" => 200
        }))
        allow(GoogleContactsApi::ContactSet).to receive(:new).and_return(
          "contact set"
        )
        expect(stubbed_contacts_accessor_class.new(api).get_contacts).to eq(
          "contact set"
        )
      end
    end

    # they actually return different succeess codes I can validate on them too
    describe ".put_or_post_contact" do
      it "should put the contact when it exists" do
        stubbed_contacts_accessor = stubbed_contacts_accessor_class.new(@api)
        expect(stubbed_contacts_accessor).to receive(:put_contact).with(
          @contact
        ).and_return(200)
        expect(stubbed_contacts_accessor.put_or_post_contact(@contact))
        #.to #eq(200)
      end

      it "should post the contact when it doesn't exist" do
        stubbed_contacts_accessor = stubbed_contacts_accessor_class.new(@api)
        expect(stubbed_contacts_accessor).to receive(:put_contact).with(
          @contact).and_return(404)
        expect(stubbed_contacts_accessor).to receive(:post_contact).with(
          @contact).and_return(201)
        expect(stubbed_contacts_accessor.put_or_post_contact(
          @contact)).to eq(201)
      end
    end

    describe ".post_contact" do
      it "should post the contact using the internal @api object" do
        expect(api).to receive(:post_v2).with(
          "contacts/default/full",
          kind_of(Hash),
          kind_of(Hash)
        ).and_return(Hashie::Mash.new({
          "body" => "some response",
          "code" => 201
        }))
        expect(stubbed_contacts_accessor_class.new(api).post_contact(
          @contact)).to eq(201)
      end
    end

    describe ".put_contact" do
      it "should put the contact using the internal @api object" do
        expect(api).to receive(:put_v2).with(
          "https://www.google.com/m8/feeds/contacts/example%40gmail.com/full/0",
           kind_of(Hash), kind_of(Hash)).and_return(Hashie::Mash.new({
          "body" => "some response",
          "code" => 200
        }))
        expect(stubbed_contacts_accessor_class.new(api).put_contact(
          @contact)).to eq(200)
      end
    end

  end