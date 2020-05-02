require "./spec_helper"

describe Net::NNTP do
  # TODO: Write tests

  it "can connect" do
    nntp = Net::NNTP.new(ENV["USENET_HOST"], ENV["USENET_PORT"].to_i)
    nntp.start(ENV["USENET_USER"], ENV["USENET_PASS"], nil)
  end
end
