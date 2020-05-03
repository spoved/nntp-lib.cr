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

  # 4.1.  Example 1 - relative access with NEXT
  #
  #    S:      (listens at TCP port 119)
  #
  #    C:      (requests connection on TCP port 119)
  #    S:      200 wombatvax news server ready - posting ok
  #
  #    (client asks for a current newsgroup list)
  #    C:      LIST
  #    S:      215 list of newsgroups follows
  #    S:      net.wombats 00543 00501 y
  #    S:      net.unix-wizards 10125 10011 y
  #            (more information here)
  #    S:      net.idiots 00100 00001 n
  #    S:      .
  #
  #    (client selects a newsgroup)
  #    C:      GROUP net.unix-wizards
  #    S:      211 104 10011 10125 net.unix-wizards group selected
  #            (there are 104 articles on file, from 10011 to 10125)
  #
  #    (client selects an article to read)
  #    C:      STAT 10110
  #    S:      223 10110 <23445@sdcsvax.ARPA> article retrieved - statistics
  #            only (article 10110 selected, its message-id is
  #            <23445@sdcsvax.ARPA>)
  #
  #    (client examines the header)
  #    C:      HEAD
  #    S:      221 10110 <23445@sdcsvax.ARPA> article retrieved - head
  #            follows (text of the header appears here)
  #    S:      .
  #
  #    (client wants to see the text body of the article)
  #    C:      BODY
  #    S:      222 10110 <23445@sdcsvax.ARPA> article retrieved - body
  #            follows (body text here)
  #    S:      .
  #
  #    (client selects next article in group)
  #    C:      NEXT
  #    S:      223 10113 <21495@nudebch.uucp> article retrieved - statistics
  #            only (article 10113 was next in group)
  #
  #    (client finishes session)
  #    C:      QUIT
  #    S:      205 goodbye.
  it "relative access with NEXT" do
    with_client do |client|
      # client asks for a current newsgroup list
      resp = client.list
      resp.status.should eq "215"
      resp.text.should_not be_empty
      newsgroup = resp.text.sample

      # client selects a newsgroup
      resp = client.group "alt.binaries.ebook"
      resp.status.should eq "211"
      ginfo = resp.msg.split /\s+/
      ginfo.size.should eq 4
      # puts ginfo.to_json

      art_num = 33665041

      # client selects an article to read
      resp = client.stat art_num
      resp.status.should eq "223"
      resp.msg.should match(/^#{art_num}/)
      ainfo = resp.msg.split /\s+/
      ainfo.size.should eq 2

      # parse the message id
      art_message_id = ainfo[1].gsub(/[\<\>]/, "")

      # client examines the header
      resp = client.head art_num
      resp.status.should eq "221"
      resp.msg.should contain(art_message_id)

      # client wants to see the text body of the article
      resp = client.body art_num
      resp.status.should eq "222"
      resp.msg.should contain(art_message_id)

      if ginfo[0].to_i > 1
        # client selects next article in group
        resp = client.next
        # next_info = resp.msg.split /\s+/
        resp.status.should eq "223"

        # parse article num
        next_art_num = ginfo[0].to_i
        next_art_num.should be > art_num
      end
    end
  end
end
