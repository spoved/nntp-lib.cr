# This module contains command extensions such as described in [RFC2980](https://www.ietf.org/rfc/rfc2980.txt)
module Net::NNTP::Commands::Extensions
  abstract def shortcmd(fmt, *args) : Net::NNTP::Response
  abstract def longcmd(fmt, *args) : Net::NNTP::Response

  # [RFC2980]
  # 1.2.1  The MODE STREAM command
  #
  #    MODE STREAM
  #
  #    MODE STREAM is used by a peer to indicate to the server that it would
  #    like to suspend the lock step conversational nature of NNTP and send
  #    commands in streams.  This command should be used before TAKETHIS and
  #    CHECK.  See the section on the commands TAKETHIS and CHECK for more
  #    details.
  #
  # 1.2.2.  Responses
  #
  #       203 Streaming is OK
  #       500 Command not understood
  #
  # @example
  # ```
  # nntp.quit
  # ```
  #
  # Response package
  # ```json
  # {
  #   "status": "203",
  #   "msg": "Streaming is OK",
  #   "text": []
  # }
  # ```
  def mode_stream : Net::NNTP::Response
    shortcmd("MODE STREAM")
  end

  # [RFC2980]
  # 2.3 MODE READER
  #
  #    MODE READER is used by the client to indicate to the server that it
  #    is a news reading client.  Some implementations make use of this
  #    information to reconfigure themselves for better performance in
  #    responding to news reader commands.  This command can be contrasted
  #    with the SLAVE command in RFC 977, which was not widely implemented.
  #    MODE READER was first available in INN.
  #
  # 2.3.1 Responses
  #
  #       200 Hello, you can post
  #       201 Hello, you can't post
  #
  # @example
  # ```
  # nntp.mode_reader
  # ```
  #
  # Response package
  # ```json
  # {
  #   "status": "201",
  #   "msg": "Hello, you can't post",
  #   "text": []
  # }
  # ```
  def mode_reader : Net::NNTP::Response
    shortcmd("MODE READER")
  end

  # DATE
  # 20200502225525 => 2020-05-02-22:55:25
  def date : Net::NNTP::Response
    shortcmd("DATE")
  end

  # "  xhdr field [range]",
  # "  xover [range]",
  # "  xfeature compress gzip [terminator]",
  # "  xzver [range]",
  # "  xzhdr field [range]",

  # LIST [ACTIVE|NEWSGROUPS] [<Wildmat>]]:br:
  # LIST [ACTIVE.TIMES|EXTENSIONS|SUBSCRIPTIONS|OVERVIEW.FMT]
  # LISTGROUP <Newsgroup>

  # OVER <Range>  # e.g first[-[last]]

  # XHDR <Header> <Message-ID>|<Range>  # e.g first[-[last]]
  # XOVER <Range>  # e.g first[-[last]]

end
