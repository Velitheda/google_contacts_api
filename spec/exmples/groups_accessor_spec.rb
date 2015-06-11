require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

describe GoogleContactsApi::GroupsAccessor do
  let(:api) { double("api") }
  let(:test_class) {
    Class.new do
       include GoogleContactsApi::GroupsAccessor
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