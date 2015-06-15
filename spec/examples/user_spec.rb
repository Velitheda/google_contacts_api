require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

describe GoogleContactsApi::User do
    let(:oauth) { double ("oauth") }
    let(:api) { double("api") }
    let(:user) { GoogleContactsApi::User.new(@oauth) }

    # Should hit the right URLs and return the right stuff
    describe ".groups!" do
      it "should be able to get groups including system groups" do
        expect(user).to receive(:get_groups).and_return("group set")
        expect(user.groups!).to eq("group set")
      end
    end
    describe ".groups" do
      it "should be able to get groups" do
        expect(user).to receive(:get_groups).and_return("group set")
        expect(user.groups).to eq("group set")
      end
      it "should pass query params along to get_groups" do
        expect(user).to receive(:get_groups).with("something" => "important").and_return("group set")
        expect(user.groups("something" => "important")).to eq("group set")
      end
      it "should reload the groups" do
        expect(user).to receive(:get_groups).and_return("group set").twice
        user.groups
        groups = user.groups
        expect(groups).to eq("group set")
      end
    end
    describe ".contacts!" do
      it "should be able to get contacts" do
        expect(user).to receive(:get_contacts).and_return("contact set")
        expect(user.contacts!).to eq("contact set")
      end
      it "should use the contact cache for subsequent access" do
        expect(user).to receive(:get_contacts).and_return("contact set").once
        user.contacts!
        contacts = user.contacts!
        expect(contacts).to eq("contact set")
      end
    end
    describe ".contacts" do
      it "should be able to get contacts" do
        expect(user).to receive(:get_contacts).and_return("contact set")
        expect(user.contacts).to eq("contact set")
      end
      it "should pass query params along to get_contacts" do
        expect(user).to receive(:get_contacts).with("something" => "important").and_return("contact set")
        expect(user.contacts("something" => "important")).to eq("contact set")
      end
      it "should reload the contacts" do
        expect(user).to receive(:get_contacts).and_return("contact set").twice
        user.contacts
        contacts = user.contacts
        expect(contacts).to eq("contact set")
      end
    end

    describe ".save_contact" do
      it "should save the contact" do
        expect(user).to receive(:put_or_post_contact).and_return("success")
        expect(user.save_contact(contact_json_hash)).to eq("success")
      end
    end

    describe ".save_group" do
      it "should save the group" do
        expect(user).to receive(:put_or_post_group).and_return("success")
        expect(user.save_group(group_json_hash)).to eq("success")
      end
    end

  end