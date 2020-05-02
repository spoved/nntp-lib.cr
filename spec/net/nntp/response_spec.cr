require "../../spec_helper"
describe Net::NNTP::Response do
  describe "#check!" do
    it "does not throw error on good response" do
      resp = Net::NNTP::Response.new("204", "Goodbye")
      resp.check!.should be resp
    end

    it "supresses 3XX execptions when asked" do
      resp = Net::NNTP::Response.new("381", "PASS required")
      expect_raises(Net::NNTP::Error::UnknownError) do
        resp.check!.should be resp
      end

      resp.check!(true).should be resp
    end

    it "throws error on bad response" do
      resp = Net::NNTP::Response.new("440", "No posting!")
      expect_raises(Net::NNTP::Error::PostingNotAllowed) do
        resp.check!.should be resp
      end
    end
  end
end
