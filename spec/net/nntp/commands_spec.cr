require "../../spec_helper"

describe Net::NNTP::Commands do
  describe "it can send command" do
    newsgroup = "alt.binaries.cbt"

    it "#help" do
      resp = with_client &.help
      resp.status.should eq "100"
      resp.msg.should eq "Legal Commands"
      puts resp.to_pretty_json
    end

    it "#group" do
      resp = with_client &.group(newsgroup)
      resp.status.should eq "211"
      resp.msg.should match(/(\d+\s){3}#{newsgroup}/)
    end

    it "#date" do
      resp = with_client &.date
      resp.status.should eq "111"
      resp.msg.should match(/\d{14}/)
    end

    it "#article" do
      with_client do |client|
        gresp = client.group(newsgroup)
        num_resp = client.article 56910052
        id_resp = client.article("nkdtopWMXkIqWnuDoljqJRJUPKQsWQMk@news.usenet.farm")
        num_resp.to_json.should eq id_resp.to_json
      end
    end

    it "#last" do
      resp = with_group &.last
      resp.status.should eq "223"
    end

    it "#list" do
      resp = with_client &.list
      resp.status.should eq "215"
    end

    it "#new_groups" do
      resp = with_client &.new_groups
      resp.status.should eq "231"
    end

    # TODO: Usenetserver does not support this
    # it "#new_news" do
    #   resp = with_client &.new_news
    #   resp.status.should eq "230"
    #
    #   puts resp.to_pretty_json
    # end

    it "#next" do
      resp = with_group &.next
      resp.status.should eq "223"

      puts resp.to_pretty_json
    end
  end
end
