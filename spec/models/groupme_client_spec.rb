require "spec_helper"

describe GroupmeClient do
  describe "#get" do
    it "should return an unwrapped response from groupme" do
      stub_request(:get, "#{GROUPME_API_URL}/some_resource")
        .to_return(
          body: {
            response: {
              resource: "yes"
            }
          }.to_json
        )

      client = GroupmeClient.new
      response = client.get("/some_resource")
      response.should be_success
      response.status.should == 200
      response.response[:resource].should == "yes"
    end

    it "should return errors if they exist" do
      stub_request(:get, "#{GROUPME_API_URL}/some_resource")
        .to_return(
          status: 400,
          body: {
            meta: {
              errors: ["Ya", "Burnt"]
            }
          }.to_json
        )

      client = GroupmeClient.new
      response = client.get("/some_resource")
      response.should_not be_success
      response.status.should == 400
      response.errors.should == ["Ya", "Burnt"]
    end
  end
end
