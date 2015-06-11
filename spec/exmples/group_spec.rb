require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

describe GoogleContactsApi::Group do
  before(:all) do
    @group_json_hash = group_json_hash
    @group = GoogleContactsApi::Group.new(group_json_hash)
  end
  # ok, these tests are kind of silly
  it "should return the right title" do
    expect(@group.title).to eq("System Group: My Contacts")
  end
  it "should return the right id" do
    expect(@group.id).to eq("http://www.google.com/m8/feeds/groups/example%40gmail.com/base/6")
  end
  it "should return the right content" do
    # TODO: Nothing in source, oops
    expect(@group.content).to eq("System Group: My Contacts")
  end
  it "should return the right updated time" do
    # different representation slightly
    expect(@group.updated.to_s).to eq("1970-01-01T00:00:00+00:00")
  end
  it "should tell me if it's a system group" do
    expect(@group).to be_system_group
  end
  describe ".contacts" do
    before(:each) do
      @api = double("api")
      @group = GoogleContactsApi::Group.new(@contact_json_hash, nil, @api)
      allow(@group).to receive(:id).and_return("group id")
    end
    it "should be able to get contacts" do
      expect(@group).to receive(:get_contacts).with(hash_including({"group" => "group id"})).and_return("contact set")
      expect(@group.contacts).to eq("contact set")
    end
    it "should use the contact cache for subsequent access" do
      expect(@group).to receive(:get_contacts).with(hash_including({"group" => "group id"})).and_return("contact set").once
      @group.contacts
      contacts = @group.contacts
      expect(contacts).to eq("contact set")
    end
  end
  describe ".contacts!" do
    before(:each) do
      @api = double("api")
      @group = GoogleContactsApi::Group.new(@contact_json_hash, nil, @api)
      allow(@group).to receive(:id).and_return("group id")
    end
    it "should be able to get contacts" do
      expect(@group).to receive(:get_contacts).with(hash_including({"group" => "group id"})).and_return("contact set")
      expect(@group.contacts!).to eq("contact set")
    end
    it "should use the contact cache for subsequent access" do
      expect(@group).to receive(:get_contacts).with(hash_including({"group" => "group id"})).and_return("contact set").twice
      @group.contacts
      contacts = @group.contacts!
      expect(contacts).to eq("contact set")
    end
  end
end