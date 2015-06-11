require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

describe GoogleContactsApi::User do
    let(:oauth) { double ("oauth") }
    let(:user) { GoogleContactsApi::User.new(@oauth) }

    # Should hit the right URLs and return the right stuff
    describe ".groups" do
      it "should be able to get groups including system groups" do
        expect(user).to receive(:get_groups).and_return("group set")
        expect(user.groups).to eq("group set")
      end
    end
    describe ".groups!" do
      it "should be able to get groups" do
        expect(user).to receive(:get_groups).and_return("group set")
        expect(user.groups!).to eq("group set")
      end
      it "should pass query params along to get_groups" do
        expect(user).to receive(:get_groups).with("something" => "important").and_return("group set")
        expect(user.groups!("something" => "important")).to eq("group set")
      end
      it "should reload the groups" do
        expect(user).to receive(:get_groups).and_return("group set").twice
        user.groups
        groups = user.groups!
        expect(groups).to eq("group set")
      end
    end
    describe ".contacts" do
      it "should be able to get contacts" do
        expect(user).to receive(:get_contacts).and_return("contact set")
        expect(user.contacts).to eq("contact set")
      end
      it "should use the contact cache for subsequent access" do
        expect(user).to receive(:get_contacts).and_return("contact set").once
        user.contacts
        contacts = user.contacts
        expect(contacts).to eq("contact set")
      end
    end
    describe ".contacts!" do
      it "should be able to get contacts" do
        expect(user).to receive(:get_contacts).and_return("contact set")
        expect(user.contacts!).to eq("contact set")
      end
      it "should pass query params along to get_contacts" do
        expect(user).to receive(:get_contacts).with("something" => "important").and_return("contact set")
        expect(user.contacts!("something" => "important")).to eq("contact set")
      end
      it "should reload the contacts" do
        expect(user).to receive(:get_contacts).and_return("contact set").twice
        user.contacts
        contacts = user.contacts!
        expect(contacts).to eq("contact set")
      end
    end

    describe ".save_contact" do
      xit "should try to put the contact if it exists" do

      end

      xit "should post the contact if it doesn't exist" do

      end
    end

    describe ".save_group" do
      xit "should try to put the group if it exists" do

      end

      xit "should post the group if it doesn't exist" do

      end
    end

  end