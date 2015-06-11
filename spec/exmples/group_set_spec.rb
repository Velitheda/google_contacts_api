describe "GroupSet" do
    before(:all) do
      @group_set_json = group_set_json
      @group_set = GoogleContactsApi::GroupSet.new(@group_set_json)
    end

    it "should return the right starting index" do
      expect(@group_set.start_index).to eq(1)
    end
    it "should return the right number of results per page" do
      expect(@group_set.items_per_page).to eq(25)
    end
    it "should return the right number of total results" do
      expect(@group_set.total_results).to eq(5)
    end
    it "should tell me if there are more results" do
      # yeah this is an awkward assertion and matcher
      expect(@group_set).not_to be_has_more
      expect(@group_set.has_more?).to eq(false)
    end
    it "should parse results into Groups" do
      expect(@group_set.to_a.first).to be_instance_of(GoogleContactsApi::Group)
    end
  end