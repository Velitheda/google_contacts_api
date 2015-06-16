  describe "Result" do

    before(:all) do
      @contact_json_hash = contact_json_hash
      @contact = GoogleContactsApi::Contact.new(@contact_json_hash)
    end

  end