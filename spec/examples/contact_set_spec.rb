describe "ContactSet" do
    describe "with entries" do
      before(:all) do
        @contact_set_json = contact_set_json
        @contact_set = GoogleContactsApi::ContactSet.new(@contact_set_json)
      end

      it "should return the right starting index" do
        expect(@contact_set.start_index).to eq(1)
      end
      it "should return the right number of results per page" do
        expect(@contact_set.items_per_page).to eq(25)
      end
      it "should return the right number of total results" do
        expect(@contact_set.total_results).to eq(500)
      end
      it "should tell me if there are more results" do
        # yeah this is an awkward assertion and matcher
        expect(@contact_set).to be_has_more
        expect(@contact_set.has_more?).to eq(true)
      end
      it "should parse results into Contacts" do
        expect(@contact_set.to_a.first).to be_instance_of(
          GoogleContactsApi::Contact)
      end
    end
    it "should parse nil results into an empty array" do
      @empty_contact_set_json = empty_contact_set_json
      @empty_contact_set = GoogleContactsApi::ContactSet.new(
        @empty_contact_set_json)
      expect(@empty_contact_set.total_results).to eq(0)
      expect(@empty_contact_set.instance_variable_get("@results")).to eq([])
    end
  end