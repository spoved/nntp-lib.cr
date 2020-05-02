require "./spec_helper"
require "json"
describe Net::NNTP do
  # TODO: Write tests

  it "can connect" do
    nntp = Net::NNTP.new(ENV["USENET_HOST"], ENV["USENET_PORT"].to_i)
    nntp.start(ENV["USENET_USER"], ENV["USENET_PASS"], :original) do |client|
      resp = client.help

      resp.status.should eq "100"
      resp.msg.should eq "Legal Command"
      resp.text.should_not be_empty

      puts resp.to_pretty_json
    end
  end
end
