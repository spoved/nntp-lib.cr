require "../../../spec_helper"

describe Net::NNTP::Commands::Extensions do
  describe "it can send RFC2980 commands" do
    newsgroup = "alt.binaries.cbt"

    # it "#mode_stream" do
    #   resp = with_client &.mode_stream
    #   resp.status.should eq "203"
    # end

    it "#mode_reader" do
      resp = with_client &.mode_reader
      resp.status.should eq "201"
    end

    it "#xdhr" do
      resp = with_group &.xdhr("subject", 56900000, 56900000 + 10)
      resp.status.should eq "221"
      resp.text.size.should eq 11
      # puts resp.to_pretty_json

      resp = with_group &.xdhr("subject", "XrXwSfUuLnTgGkPwFjUhPsDe-1587103045909@nyuu")
      resp.status.should eq "221"
      resp.text.size.should eq 1
    end

    it "#xover" do
      resp = with_group &.xover(56900000, 56900000 + 10)
      resp.status.should eq "224"
      resp.text.size.should eq 11
      # puts resp.to_pretty_json
    end

    it "#date" do
      resp = with_client &.date
      resp.status.should eq "111"
      resp.msg.should match(/\d{14}/)
    end
  end
end
