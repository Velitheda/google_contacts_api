# require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

# class MockOAuth2Error < StandardError
# end

describe "Api" do
    before(:each) do
      @oauth = double("oauth")
      allow(@oauth).to receive(:get).and_return("get response")
      allow(@oauth).to receive(:post).and_return("post response")
      allow(@oauth).to receive(:put).and_return("put response")
      @api = GoogleContactsApi::Api.new(@oauth)
    end

    describe ".get" do
      it "should perform a get request using oauth returning json with version 3" do
        # expectation should come before execution
        expect(@oauth).to receive(:get).with(
          GoogleContactsApi::Api::BASE_URL + "any_url?alt=json&param=param&v=3", {"header" => "header"})
        expect(@api.get("any_url",
          {"param" => "param"},
          {"header" => "header"})).to eq("get response")
      end

      it "should perform a get request using oauth with the version specified" do
        expect(@oauth).to receive(:get).with(
          GoogleContactsApi::Api::BASE_URL + "any_url?alt=json&param=param&v=2", {"header" => "header"})
        expect(@api.get("any_url",
          {"param" => "param", "v" => "2"},
          {"header" => "header"})).to eq("get response")
      end
    end

    describe ".post_v2" do
      it "should perform a post request using oauth" do
        expect(@oauth).to receive(:post).with(
           GoogleContactsApi::Api::BASE_URL + "any_url?alt=json&param=param&v=3", {"header" => "header"})
        expect(@api.post_v2("any_url",
          {"param" => "param"},
          {"header" => "header"})).to eq("post response")
      end
    end

    describe ".put_v2" do
      it "should perform a put request using oauth" do
        expect(@oauth).to receive(:put).with(
           "any_url?alt=json&param=param&v=3", {"header" => "header"})
        expect(@api.put_v2("any_url",
          {"param" => "param"},
          {"header" => "header"})).to eq("put response")
      end
    end

    pending "should perform a delete request using oauth"
    # Not sure how to test, you'd need a revoked token.
    it "should raise UnauthorizedError if OAuth 1.0 returns unauthorized" do
      oauth = double("oauth")
      error_html = load_file(File.join('errors', 'auth_sub_401.html'))
      allow(oauth).to receive(:get).and_return(Net::HTTPUnauthorized.new("1.1", 401, error_html))
      api = GoogleContactsApi::Api.new(oauth)
      expect { api.get("any url",
        {"param" => "param"},
        {"header" => "header"}) }.to raise_error(GoogleContactsApi::UnauthorizedError)
    end

    it "should raise UnauthorizedError if OAuth 2.0 returns unauthorized" do
      oauth = double("oauth2")
      oauth2_response = Struct.new(:status)
      allow(oauth).to receive(:get).and_raise(MockOAuth2Error.new(oauth2_response.new(401)))
      api = GoogleContactsApi::Api.new(oauth)
      expect { api.get("any url",
        {"param" => "param"},
        {"header" => "header"}) }.to raise_error(GoogleContactsApi::UnauthorizedError)
    end

    describe "parsing response code" do
      before(:all) do
        @Oauth = Struct.new(:code)
        @Oauth2 = Struct.new(:status)
      end
      it "should parse something that looks like an oauth gem response" do
        expect(GoogleContactsApi::Api.parse_response_code(@Oauth.new("401"))).to eq(401)
      end

      it "should parse something that looks like an oauth2 gem response" do
        expect(GoogleContactsApi::Api.parse_response_code(@Oauth2.new(401))).to eq(401)
      end
    end
  end