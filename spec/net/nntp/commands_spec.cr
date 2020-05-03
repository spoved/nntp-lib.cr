require "../../spec_helper"

describe Net::NNTP::Commands do
  describe "it can send command" do
    newsgroup = "alt.binaries.cbt"

    # {
    #   "status": "100",
    #   "msg": "Legal Commands",
    #   "text": [
    #     "  help",
    #     "  date",
    #     "  xfeature useragent <client identifier>",
    #     "  authinfo type value",
    #     "  mode reader",
    #     "  post",
    #     "  list [active wildmat|active.times|counts wildmat]",
    #     "  list [overview.fmt|newsgroups wildmat]",
    #     "  listgroup newsgroup",
    #     "  group newsgroup",
    #     "  stat [<messageid>|number]",
    #     "  article [<messageid>|number]",
    #     "  head [<messageid>|number]",
    #     "  body [<messageid>|number]",
    #     "  next",
    #     "  last",
    #     "  xhdr field [range]",
    #     "  xover [range]",
    #     "  xfeature compress gzip [terminator]",
    #     "  xzver [range]",
    #     "  xzhdr field [range]",
    #     "  quit"
    #   ]
    # }
    it "#help" do
      resp = with_client &.help
      resp.status.should eq "100"
      resp.msg.should eq "Legal Commands"
      # puts resp.to_pretty_json
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
        num_resp.status.should eq "220"

        id_resp = client.article("nkdtopWMXkIqWnuDoljqJRJUPKQsWQMk@news.usenet.farm")
        id_resp.status.should eq "220"

        num_resp.to_json.should eq id_resp.to_json
      end
    end

    # NUM request
    # {
    #   "status": "221",
    #   "msg": "0 <nkdtopWMXkIqWnuDoljqJRJUPKQsWQMk@news.usenet.farm>",
    #   "text": [
    #     "Newsgroups: alt.binaries.cbt",
    #     "Subject: iPhone SUPER 80% discounts",
    #     "X-Ufhash: swQpuUeqEk6Gg1ICvM%2FSzNWhxnVwF1JDnsoczVCO59okDvewGpsFp3xh%2B2AKy3j2d6rBHzn49k0lOrZlYbpL6mgApqM69KgsdJvLM2n6od%2Bs2LkEdWkK5kHKi4UUp%2B89nwIr%2BfQ%2FYIxsAj49c2RMzhYsOdKA6LrsjT1XWMpXdYkhvQoK6uz3qpDpzvpy64h6qZXkvGlrQ8ezMYjV9xH1RdjFhWDaxT4x%2BYKO2SfUb0AgN4ttSDdpQisiMG%2BZL4%2Bv",
    #     "Message-Id: <nkdtopWMXkIqWnuDoljqJRJUPKQsWQMk@news.usenet.farm>",
    #     "Date: Sun, 19 Apr 20 00:55:07 UTC",
    #     "Path: not-for-mail",
    #     "Organization: Usenet.Farm",
    #     "From: discounts@iphone.bell.com",
    #     "X-Received-Bytes: 949",
    #     "X-Received-Body-CRC: 3862205996"
    #   ]
    # }
    #
    # Message-ID request
    # {
    #   "status": "221",
    #   "msg": "0 <nkdtopWMXkIqWnuDoljqJRJUPKQsWQMk@news.usenet.farm>",
    #   "text": [
    #     "Newsgroups: alt.binaries.cbt",
    #     "Subject: iPhone SUPER 80% discounts",
    #     "X-Ufhash: swQpuUeqEk6Gg1ICvM%2FSzNWhxnVwF1JDnsoczVCO59okDvewGpsFp3xh%2B2AKy3j2d6rBHzn49k0lOrZlYbpL6mgApqM69KgsdJvLM2n6od%2Bs2LkEdWkK5kHKi4UUp%2B89nwIr%2BfQ%2FYIxsAj49c2RMzhYsOdKA6LrsjT1XWMpXdYkhvQoK6uz3qpDpzvpy64h6qZXkvGlrQ8ezMYjV9xH1RdjFhWDaxT4x%2BYKO2SfUb0AgN4ttSDdpQisiMG%2BZL4%2Bv",
    #     "Message-Id: <nkdtopWMXkIqWnuDoljqJRJUPKQsWQMk@news.usenet.farm>",
    #     "Date: Sun, 19 Apr 20 00:55:07 UTC",
    #     "Path: not-for-mail",
    #     "Organization: Usenet.Farm",
    #     "From: discounts@iphone.bell.com",
    #     "X-Received-Bytes: 949",
    #     "X-Received-Body-CRC: 3862205996"
    #   ]
    # }
    it "#head" do
      with_client do |client|
        gresp = client.group(newsgroup)
        num_resp = client.head 56910052
        num_resp.status.should eq "221"
        num_resp.msg.should eq "0 <nkdtopWMXkIqWnuDoljqJRJUPKQsWQMk@news.usenet.farm>"

        id_resp = client.head("nkdtopWMXkIqWnuDoljqJRJUPKQsWQMk@news.usenet.farm")
        id_resp.status.should eq "221"
        id_resp.msg.should eq "0 <nkdtopWMXkIqWnuDoljqJRJUPKQsWQMk@news.usenet.farm>"

        num_resp.text.should eq id_resp.text
      end
    end

    it "#body" do
      with_client do |client|
        gresp = client.group(newsgroup)
        num_resp = client.body 56910052
        num_resp.status.should eq "222"
        num_resp.msg.should eq "56910052 <nkdtopWMXkIqWnuDoljqJRJUPKQsWQMk@news.usenet.farm>"

        id_resp = client.body("nkdtopWMXkIqWnuDoljqJRJUPKQsWQMk@news.usenet.farm")
        id_resp.status.should eq "222"
        id_resp.msg.should eq "0 <nkdtopWMXkIqWnuDoljqJRJUPKQsWQMk@news.usenet.farm>"

        num_resp.text.should eq id_resp.text

        # num_resp.to_json.should eq id_resp.to_json
      end
    end

    # NUM request
    # {
    #   "status": "223",
    #   "msg": "56910052 <nkdtopWMXkIqWnuDoljqJRJUPKQsWQMk@news.usenet.farm>",
    #   "text": []
    # }
    #
    # Message-ID request
    # {
    #   "status": "223",
    #   "msg": "0 <nkdtopWMXkIqWnuDoljqJRJUPKQsWQMk@news.usenet.farm>",
    #   "text": []
    # }
    it "#stat" do
      with_client do |client|
        gresp = client.group(newsgroup)

        num_resp = client.stat 56910052
        num_resp.status.should eq "223"
        num_resp.msg.should eq "56910052 <nkdtopWMXkIqWnuDoljqJRJUPKQsWQMk@news.usenet.farm>"

        id_resp = client.stat("nkdtopWMXkIqWnuDoljqJRJUPKQsWQMk@news.usenet.farm")
        id_resp.status.should eq "223"
        id_resp.msg.should eq "0 <nkdtopWMXkIqWnuDoljqJRJUPKQsWQMk@news.usenet.farm>"

        num_resp.text.should eq id_resp.text
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
      resp = with_client &.new_groups("100101", "000000", "GMT", ["alt"])
      resp.status.should eq "231"
      # puts resp.to_pretty_json
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
      # puts resp.to_pretty_json
    end

    # TODO: Usenetserver does not support this
    # it "#slave" do
    #   resp = with_client &.slave
    #   resp.status.should eq "202"
    #   puts resp.to_pretty_json
    # end
  end
end
