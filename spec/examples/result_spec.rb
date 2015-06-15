  describe "Result" do

    before(:all) do
      @contact_json_hash = contact_json_hash
      @contact = GoogleContactsApi::Contact.new(@contact_json_hash)
    end

#should I test with a group too?  Or should I put this in each of their specs?
    # describe ".id_number" do
    #   it "returns the number at the end of the id link" do
    #     expect(@contact.id).to equal(0)
    #   end

    # end

  end