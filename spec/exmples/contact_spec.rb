  describe "Contact" do
    before(:all) do
      @contact_json_hash = contact_json_hash
      @contact = GoogleContactsApi::Contact.new(@contact_json_hash)
    end
    # ok, these tests are kind of silly
    # it "returns the number at the end of the id link" do
    #   expect(@contact.id_number).to equal(0)
    # end

    it "should return the right title" do
      expect(@contact.title).to eq("Contact 1")
    end
    it "should return the right id" do
      expect(@contact.id).to eq("http://www.google.com/m8/feeds/contacts/example%40gmail.com/base/0")
    end
    it "should return the right content" do
      # TODO: Nothing in source, oops
      expect(@contact.content).to eq(nil)
    end
    it "should return the right updated time" do
      # different representation slightly
      expect(@contact.updated.to_s).to eq("2011-07-07T21:02:42+00:00")
    end
    it "should return the right self link" do
      expect(@contact.self_link).to eq("https://www.google.com/m8/feeds/contacts/example%40gmail.com/full/0")
    end
    it "should return the right photo link" do
      expect(@contact.photo_link).to eq("https://www.google.com/m8/feeds/photos/media/example%40gmail.com/0")
    end
    it "should return the right edit link" do
      expect(@contact.edit_link).to eq("https://www.google.com/m8/feeds/contacts/example%40gmail.com/full/0")
    end
    it "should return the right edit photo link" do
      # TODO: there isn't one in this contact, hahah
      expect(@contact.edit_photo_link).to eq(nil)
    end
    it "should try to fetch a photo" do
      @oauth = double("oauth")
      allow(@oauth).to receive(:get).and_return(Hashie::Mash.new({
        "body" => "some response", # could use example response here
        "code" => 200
      }))
      # @api = GoogleContactsApi::Api.new(@oauth)
      @api = double("api")
      allow(@api).to receive(:oauth).and_return(@oauth)
      @contact = GoogleContactsApi::Contact.new(@contact_json_hash, nil, @api)
      expect(@oauth).to receive("get").with(@contact.photo_link)
      @contact.photo
    end
    # TODO: there isn't any phone number in here
    pending "should return all phone numbers"
    it "should return all e-mail addresses" do
      expect(@contact.emails).to eq(["contact1@example.com"])
    end
    it "should return the right primary e-mail address" do
      expect(@contact.primary_email).to eq("contact1@example.com")
    end
    it "should return an empty array if there are no e-mail addresses" do
      @contact = GoogleContactsApi::Contact.new(contact_no_emails_json_hash)
      expect(@contact.emails).to eq([])
    end
    it "should return nil if there is no primary e-mail address" do
      @contact2 = GoogleContactsApi::Contact.new(contact_no_emails_json_hash)
      expect(@contact2.primary_email).to be_nil
      @contact3 = GoogleContactsApi::Contact.new(contact_no_primary_email_json_hash)
      expect(@contact3.primary_email).to be_nil
    end
    it "should return all instant messaging accounts" do
      expect(@contact.ims).to eq(["contact1@example.com"])
    end
    it "should return an empty array if there are no instant messaging accounts" do
      @contact = GoogleContactsApi::Contact.new(contact_no_emails_json_hash)
      expect(@contact.ims).to eq([])
    end
  end