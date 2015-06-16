require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

describe GoogleContactsApi::GroupsAccessor do

  before(:all) do
    @group_json_hash = group_json_hash
    @group = GoogleContactsApi::Group.new(group_json_hash)
  end

  let(:api) { double("api") }
  let(:stubbed_contacts_accessor_class) {
    Class.new do
       include GoogleContactsApi::GroupsAccessor
      def initialize(api)
        @api = api
      end
    end
  }
  describe ".get_groups" do
    it "should get the groups using the internal @api object" do
      expect(api).to receive(:get).with(
        "groups/default/full",
        kind_of(Hash)
      ).and_return(Hashie::Mash.new({
        "body" => "some response", # could use example response here
        "code" => 200
      }))
      allow(GoogleContactsApi::GroupSet).to receive(:new).and_return(
        "group set")
      expect(stubbed_contacts_accessor_class.new(api).get_groups).to eq(
        "group set")
    end
  end

  describe ".post_group" do
      it "should post the group using the internal @api object" do
        expect(api).to receive(:post_v2).with(
          "groups/default/full",
          kind_of(Hash),
          kind_of(Hash)
        ).and_return(Hashie::Mash.new({
          "body" => "some response",
          "code" => 201
        }))
        expect(stubbed_contacts_accessor_class.new(api).post_group(
          @group)).to eq(201)
      end
    end

    describe ".put_group" do
      it "should put the group using the internal @api object" do
        expect(api).to receive(:put_v2).with(
          "https://www.google.com/m8/feeds/groups/example%40gmail.com/full/6",
          kind_of(Hash),
          kind_of(Hash)
        ).and_return(Hashie::Mash.new({
          "body" => "some response",
          "code" => 201
        }))
        expect(stubbed_contacts_accessor_class.new(api).put_group(
          @group)).to eq(201)
      end
    end

    describe ".put_or_post" do
      it "should put the group when it exists" do
        stubbed_contacts_accessor = stubbed_contacts_accessor_class.new(@api)
        expect(stubbed_contacts_accessor).to receive(:put_group).with(
          @group).and_return(201)
        expect(stubbed_contacts_accessor.put_or_post(@group))
      end

      it "should post the group when it doesn't exist" do
        stubbed_contacts_accessor = stubbed_contacts_accessor_class.new(@api)
        expect(stubbed_contacts_accessor).to receive(:put_group).with(
          @group).and_return(404)
        expect(stubbed_contacts_accessor).to receive(:post_group).with(
          @group).and_return(201)
        expect(stubbed_contacts_accessor.put_or_post(@group))
      end
    end

end