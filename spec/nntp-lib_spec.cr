require "./spec_helper"
require "json"
describe Net::NNTP do
  # TODO: Write tests

  it "can connect" do
    with_client do |client|
      resp = client.help
      resp.status.should eq "100"
      resp.msg.should eq "Legal Commands"
      resp.text.should_not be_empty
    end
  end

  it "can fetch date" do
    with_client do |client|
      puts client.date.to_json
    end
  end
end
