# This module contains command extensions such as described in [RFC2980](https://www.ietf.org/rfc/rfc2980.txt)(https://www.ietf.org/rfc/rfc2980.txt)
module Net::NNTP::Commands::Extensions
  protected abstract def shortcmd(fmt, *args) : Net::NNTP::Response
  protected abstract def longcmd(fmt, *args) : Net::NNTP::Response

  # [RFC2980](https://www.ietf.org/rfc/rfc2980.txt)
  # `1.2.1 MODE STREAM`
  #
  # ### 1.2.1 MODE STREAM
  # ```text
  #    MODE STREAM
  # ```
  #    MODE STREAM is used by a peer to indicate to the server that it would
  #    like to suspend the lock step conversational nature of NNTP and send
  #    commands in streams.  This command should be used before TAKETHIS and
  #    CHECK.  See the section on the commands TAKETHIS and CHECK for more
  #    details.
  #
  # 1.2.2.  Responses
  # ```text
  #       203 Streaming is OK
  #       500 Command not understood
  # ```
  # ### Example
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

  # [RFC2980](https://www.ietf.org/rfc/rfc2980.txt)
  # `2.3 MODE READER`
  #
  # ### 2.3 MODE READER
  #
  #    MODE READER is used by the client to indicate to the server that it
  #    is a news reading client.  Some implementations make use of this
  #    information to reconfigure themselves for better performance in
  #    responding to news reader commands.  This command can be contrasted
  #    with the SLAVE command in RFC 977, which was not widely implemented.
  #    MODE READER was first available in INN.
  #
  # ### 2.3.1 Responses
  # ```text
  #       200 Hello, you can post
  #       201 Hello, you can't post
  # ```
  # ### Example
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

  # [RFC2980](https://www.ietf.org/rfc/rfc2980.txt)
  # `2.6 XHDR`
  #
  # ### 2.6 XHDR
  # ```text
  #    XHDR header [range|<message-id>]
  # ```
  #    The XHDR command is used to retrieve specific headers from specific
  #    articles.
  #
  #    The required parameter is the name of a header line (e.g.  "subject")
  #    in a news group article.  See RFC 1036 for a list of valid header
  #    lines.  The optional range argument may be any of the following:
  #
  #                an article number
  #                an article number followed by a dash to indicate
  #                   all following
  #                an article number followed by a dash followed by
  #                   another article number
  #
  #    The optional message-id argument indicates a specific article.  The
  #    range and message-id arguments are mutually exclusive.  If no
  #    argument is specified, then information from the current article is
  #    displayed.  Successful responses start with a 221 response followed
  #    by a the matched headers from all matched messages.  Each line
  #    containing matched headers returned by the server has an article
  #    number (or message ID, if a message ID was specified in the command),
  #    then one or more spaces, then the value of the requested header in
  #    that article.  Once the output is complete, a period is sent on a
  #    line by itself.  If the optional argument is a message-id and no such
  #    article exists, the 430 error response is returned.  If a range is
  #    specified, a news group must have been selected earlier, else a 412
  #    error response is returned.  If no articles are in the range
  #    specified, a 420 error response is returned by the server.  A 502
  #    response will be returned if the client only has permission to
  #    transfer articles.
  #
  #    Some implementations will return "(none)" followed by a period on a
  #    line by itself if no headers match in any of the articles searched.
  #    Others return the 221 response code followed by a period on a line by
  #    itself.
  #
  #    The XHDR command has been available in the UNIX reference
  #    implementation from its first release.  However, until now, it has
  #    been documented only in the source for the server.
  #
  # ### 2.6.1 Responses
  # ```text
  #       221 Header follows
  #       412 No news group current selected
  #       420 No current article selected
  #       430 no such article
  #       502 no permission
  # ```
  # ### Example
  # ```
  # nntp.xdhr("subject", "XrXwSfUuLnTgGkPwFjUhPsDe-1587103045909@nyuu")
  # ```
  #
  # Response package
  # ```json
  # {
  #   "status": "221",
  #   "msg": "subject fields follow",
  #   "text": [
  #     "56900000 [146/170] - \"2CDrmrC36H47j0n1f.part137.rar\" yEnc (206/419) 300000000"
  #   ]
  # }
  # ```
  # def xdhr(header, message_id : String? = nil)
  #   if message_id.nil?
  #     longcmd("XHDR %s", header)
  #   else
  #     longcmd("XHDR %s %s", header, message_id)
  #   end
  # end

  # [RFC2980](https://www.ietf.org/rfc/rfc2980.txt)
  # `2.6 XHDR`
  #
  # ### 2.6 XHDR
  #  See `xdhr(header, message_id : String)`
  # ### Example
  # ```
  # nntp.xdhr("subject", 56900000)
  # nntp.xdhr("subject", 56900000, all: true)
  # nntp.xdhr("subject", 56900000, 56900010)
  # ```
  #
  # Response package
  # ```json
  # {
  #   "status": "221",
  #   "msg": "subject fields follow",
  #   "text": [
  #     "56900000 [146/170] - \"2CDrmrC36H47j0n1f.part137.rar\" yEnc (206/419) 300000000",
  #     "56900001 [146/170] - \"2CDrmrC36H47j0n1f.part137.rar\" yEnc (197/419) 300000000",
  #     "56900002 [146/170] - \"2CDrmrC36H47j0n1f.part137.rar\" yEnc (210/419) 300000000",
  #     "56900003 [146/170] - \"2CDrmrC36H47j0n1f.part137.rar\" yEnc (213/419) 300000000",
  #     "56900004 [146/170] - \"2CDrmrC36H47j0n1f.part137.rar\" yEnc (234/419) 300000000",
  #     "56900005 [146/170] - \"2CDrmrC36H47j0n1f.part137.rar\" yEnc (245/419) 300000000",
  #     "56900006 [146/170] - \"2CDrmrC36H47j0n1f.part137.rar\" yEnc (232/419) 300000000",
  #     "56900007 [146/170] - \"2CDrmrC36H47j0n1f.part137.rar\" yEnc (230/419) 300000000",
  #     "56900008 [146/170] - \"2CDrmrC36H47j0n1f.part137.rar\" yEnc (203/419) 300000000",
  #     "56900009 [146/170] - \"2CDrmrC36H47j0n1f.part137.rar\" yEnc (217/419) 300000000",
  #     "56900010 [146/170] - \"2CDrmrC36H47j0n1f.part137.rar\" yEnc (195/419) 300000000"
  #   ]
  # }
  # ```
  def xdhr(header, num : Int64 | Int32, end_num : Int64 | Int32 | Nil = nil, all : Bool = false)
    if all
      longcmd("XHDR %s %d-", header, num)
    elsif !end_num.nil?
      longcmd("XHDR %s %d-%d", header, num, end_num)
    else
      longcmd("XHDR %s %d", header, num)
    end
  end

  # [RFC2980](https://www.ietf.org/rfc/rfc2980.txt)
  # `2.8 XOVER`
  #
  # ### 2.8 XOVER
  # ```text
  #    XOVER [range]
  # ```
  #    The XOVER command returns information from the overview database for
  #    the article(s) specified.  This command was originally suggested as
  #    part of the OVERVIEW work described in "The Design of a Common
  #    Newsgroup Overview Database for Newsreaders" by Geoff Collyer.  This
  #    document is distributed in the Cnews distribution.  The optional
  #    range argument may be any of the following:
  # ```text
  #                an article number
  #                an article number followed by a dash to indicate
  #                   all following
  #                an article number followed by a dash followed by
  #                   another article number
  # ```
  #    If no argument is specified, then information from the current
  #    article is displayed.  Successful responses start with a 224 response
  #    followed by the overview information for all matched messages.  Once
  #    the output is complete, a period is sent on a line by itself.  If no
  #    argument is specified, the information for the current article is
  #    returned.  A news group must have been selected earlier, else a 412
  #    error response is returned.  If no articles are in the range
  #    specified, a 420 error response is returned by the server.  A 502
  #    response will be returned if the client only has permission to
  #    transfer articles.
  #
  #    Each line of output will be formatted with the article number,
  #    followed by each of the headers in the overview database or the
  #    article itself (when the data is not available in the overview
  #    database) for that article separated by a tab character.  The
  #    sequence of fields must be in this order: subject, author, date,
  #    message-id, references, byte count, and line count.  Other optional
  #    fields may follow line count.  Other optional fields may follow line
  #    count.  These fields are specified by examining the response to the
  #    LIST OVERVIEW.FMT command.  Where no data exists, a null field must
  #    be provided (i.e. the output will have two tab characters adjacent to
  #    each other).  Servers should not output fields for articles that have
  #    been removed since the XOVER database was created.
  #
  #    The LIST OVERVIEW.FMT command should be implemented if XOVER is
  #    implemented.  A client can use LIST OVERVIEW.FMT to determine what
  #    optional fields  and in which order all fields will be supplied by
  #    the XOVER command.  See Section 2.1.7 for more details about the LIST
  #    OVERVIEW.FMT command.
  #
  #    Note that any tab and end-of-line characters in any header data that
  #    is returned will be converted to a space character.
  #
  # ### 2.8.1 Responses
  # ```text
  #       224 Overview information follows
  #       412 No news group current selected
  #       420 No article(s) selected
  #       502 no permission
  # ```
  # ### Example
  # ```
  # nntp.xover(56900000)
  # nntp.xover(56900000, all: true)
  # nntp.xover(56900000, 56900010)
  # ```
  #
  # Response package
  # ```json
  # {
  #   "status": "224",
  #   "msg": "Overview Information Follows",
  #   "text": [
  #     "56900000\t[146/170] - \"2CDrmrC36H47j0n1f.part137.rar\" yEnc (206/419) 300000000\t3vq60fEnli <AEdwj0ie5p@kgiqA10.com>\tFri, 17 Apr 20 05:57:26 UTC\t<PeOtUwWkGeIbPpEuJpCwZsXw-1587103045989@nyuu>\t\t740530\t\tXref: news.usenetserver.com alt.binaries.bungalow:97417009 alt.binaries.downunder:54061184 alt.binaries.flowed:1407145623 alt.binaries.cbt:56900000 alt.binaries.test:3612538484 alt.binaries.boneless:33856151008 alt.binaries.iso:65482835",
  #     "56900001\t[146/170] - \"2CDrmrC36H47j0n1f.part137.rar\" yEnc (197/419) 300000000\t3vq60fEnli <AEdwj0ie5p@kgiqA10.com>\tFri, 17 Apr 20 05:57:26 UTC\t<XrXwSfUuLnTgGkPwFjUhPsDe-1587103045909@nyuu>\t\t740559\t\tXref: news.usenetserver.com alt.binaries.bungalow:97417010 alt.binaries.downunder:54061185 alt.binaries.flowed:1407145624 alt.binaries.cbt:56900001 alt.binaries.test:3612538485 alt.binaries.boneless:33856151009 alt.binaries.iso:65482836",
  #     "56900002\t[146/170] - \"2CDrmrC36H47j0n1f.part137.rar\" yEnc (210/419) 300000000\t3vq60fEnli <AEdwj0ie5p@kgiqA10.com>\tFri, 17 Apr 20 05:57:26 UTC\t<VkApYfRvQwYuLfDzPiCbDbCh-1587103045996@nyuu>\t\t740570\t\tXref: news.usenetserver.com alt.binaries.bungalow:97417011 alt.binaries.downunder:54061186 alt.binaries.flowed:1407145625 alt.binaries.cbt:56900002 alt.binaries.test:3612538486 alt.binaries.boneless:33856151010 alt.binaries.iso:65482837",
  #     "56900003\t[146/170] - \"2CDrmrC36H47j0n1f.part137.rar\" yEnc (213/419) 300000000\t3vq60fEnli <AEdwj0ie5p@kgiqA10.com>\tFri, 17 Apr 20 05:57:26 UTC\t<FsTuVgQeFtOmFcVjCoNbDyHm-1587103046023@nyuu>\t\t740394\t\tXref: news.usenetserver.com alt.binaries.bungalow:97417012 alt.binaries.downunder:54061187 alt.binaries.flowed:1407145626 alt.binaries.cbt:56900003 alt.binaries.test:3612538487 alt.binaries.boneless:33856151013 alt.binaries.iso:65482838",
  #     "56900004\t[146/170] - \"2CDrmrC36H47j0n1f.part137.rar\" yEnc (234/419) 300000000\t3vq60fEnli <AEdwj0ie5p@kgiqA10.com>\tFri, 17 Apr 20 05:57:26 UTC\t<JnQsVfSvAxRgWiPwUfGqHvPx-1587103046154@nyuu>\t\t740481\t\tXref: news.usenetserver.com alt.binaries.bungalow:97417013 alt.binaries.downunder:54061188 alt.binaries.flowed:1407145627 alt.binaries.cbt:56900004 alt.binaries.test:3612538488 alt.binaries.boneless:33856151017 alt.binaries.iso:65482839",
  #     "56900005\t[146/170] - \"2CDrmrC36H47j0n1f.part137.rar\" yEnc (245/419) 300000000\t3vq60fEnli <AEdwj0ie5p@kgiqA10.com>\tFri, 17 Apr 20 05:57:26 UTC\t<BvJkWsZuSbBiAcBwNgYwPgDn-1587103046226@nyuu>\t\t740591\t\tXref: news.usenetserver.com alt.binaries.bungalow:97417014 alt.binaries.downunder:54061189 alt.binaries.flowed:1407145628 alt.binaries.cbt:56900005 alt.binaries.test:3612538489 alt.binaries.boneless:33856151024 alt.binaries.iso:65482840",
  #     "56900006\t[146/170] - \"2CDrmrC36H47j0n1f.part137.rar\" yEnc (232/419) 300000000\t3vq60fEnli <AEdwj0ie5p@kgiqA10.com>\tFri, 17 Apr 20 05:57:26 UTC\t<IiWkWgOsZxMkLsSyOqZnUnQu-1587103046137@nyuu>\t\t740474\t\tXref: news.usenetserver.com alt.binaries.bungalow:97417015 alt.binaries.downunder:54061190 alt.binaries.flowed:1407145629 alt.binaries.cbt:56900006 alt.binaries.test:3612538490 alt.binaries.boneless:33856151027 alt.binaries.iso:65482841",
  #     "56900007\t[146/170] - \"2CDrmrC36H47j0n1f.part137.rar\" yEnc (230/419) 300000000\t3vq60fEnli <AEdwj0ie5p@kgiqA10.com>\tFri, 17 Apr 20 05:57:26 UTC\t<HpVeIjQyIeVoYvLxKpCzAtWp-1587103046121@nyuu>\t\t740543\t\tXref: news.usenetserver.com alt.binaries.bungalow:97417016 alt.binaries.downunder:54061191 alt.binaries.flowed:1407145630 alt.binaries.cbt:56900007 alt.binaries.test:3612538491 alt.binaries.boneless:33856151030 alt.binaries.iso:65482842",
  #     "56900008\t[146/170] - \"2CDrmrC36H47j0n1f.part137.rar\" yEnc (203/419) 300000000\t3vq60fEnli <AEdwj0ie5p@kgiqA10.com>\tFri, 17 Apr 20 05:57:26 UTC\t<WpSjFbYyPlGsFuMuPhDfJsDy-1587103045963@nyuu>\t\t740562\t\tXref: news.usenetserver.com alt.binaries.bungalow:97417017 alt.binaries.downunder:54061192 alt.binaries.flowed:1407145631 alt.binaries.cbt:56900008 alt.binaries.test:3612538492 alt.binaries.boneless:33856151032 alt.binaries.iso:65482843",
  #     "56900009\t[146/170] - \"2CDrmrC36H47j0n1f.part137.rar\" yEnc (217/419) 300000000\t3vq60fEnli <AEdwj0ie5p@kgiqA10.com>\tFri, 17 Apr 20 05:57:26 UTC\t<JxViAbQdOvFvYnZiDnZyInMw-1587103046035@nyuu>\t\t740527\t\tXref: news.usenetserver.com alt.binaries.bungalow:97417018 alt.binaries.downunder:54061193 alt.binaries.flowed:1407145632 alt.binaries.cbt:56900009 alt.binaries.test:3612538493 alt.binaries.boneless:33856151035 alt.binaries.iso:65482844",
  #     "56900010\t[146/170] - \"2CDrmrC36H47j0n1f.part137.rar\" yEnc (195/419) 300000000\t3vq60fEnli <AEdwj0ie5p@kgiqA10.com>\tFri, 17 Apr 20 05:57:26 UTC\t<WrDlVyFtWpJpPwTzIkEiOrUy-1587103045906@nyuu>\t\t740545\t\tXref: news.usenetserver.com alt.binaries.bungalow:97417019 alt.binaries.downunder:54061194 alt.binaries.flowed:1407145633 alt.binaries.cbt:56900010 alt.binaries.test:3612538494 alt.binaries.boneless:33856151039 alt.binaries.iso:65482845"
  #   ]
  # }
  # ```
  def xover(num : Int64 | Int32, end_num : Int64 | Int32 | Nil = nil, all : Bool = false)
    if all
      longcmd("XOVER %d-", num)
    elsif !end_num.nil?
      longcmd("XOVER %d-%d", num, end_num)
    else
      longcmd("XOVER %d", num)
    end
  end

  # [RFC2980](https://www.ietf.org/rfc/rfc2980.txt)
  # `3.2 DATE`
  #
  # ### 3.2 DATE
  # ```text
  #    DATE
  # ```
  #    The first NNTP working group discussed and proposed a syntax for this
  #    command to help clients find out the current time from the server's
  #    perspective.  At the time this command was discussed (1991-1992), the
  #    Network Time Protocol [9] (NTP) was not yet in wide use and there was
  #    also some concern that small systems may not be able to make
  #    effective use of NTP.
  #
  #    This command returns a one-line response code of 111 followed by the
  #    GMT date and time on the server in the form YYYYMMDDhhmmss.
  #
  # ### 3.2.1 Responses
  # ```text
  #       111 YYYYMMDDhhmmss
  # ```
  def date : Net::NNTP::Response
    shortcmd("DATE")
  end

  # [RFC2980](https://www.ietf.org/rfc/rfc2980.txt)
  # `2.1.2 LIST ACTIVE`
  #
  # ### 2.1.2 LIST ACTIVE
  # ```text
  #    LIST ACTIVE [wildmat]
  # ```
  #
  # LIST ACTIVE is exactly the same as the LIST command specified in RFC
  # 977.  The responses and the format should exactly match the LIST
  # command without arguments.  If the optional matching parameter is
  # specified, the list is limited to only the groups that match the
  # pattern.  Specifying a single group is usually very efficient for the
  # server, and multiple groups may be specified by using wildmat
  # patterns (described later in this document), not regular expressions.
  # If nothing is matched an empty list is returned, not an error.  This
  # command first appeared in the UNIX reference version.
  #
  def list_active(wildmat = "")
    longcmd("LIST ACTIVE %s", wildmat)
  end

  # [RFC2980](https://www.ietf.org/rfc/rfc2980.txt)
  # `2.1.3 LIST ACTIVE.TIMES`
  #
  # ### 2.1.3 LIST ACTIVE.TIMES
  # ```text
  #    LIST ACTIVE.TIMES
  # ```
  #
  # The active.times file is maintained by some news transports systems
  # to contain information about the when and who created a particular
  # news group.  The format of this file generally include three fields.
  # The first field is the name of the news group.  The second is the
  # time when this group was created on this news server measured in
  # seconds since January 1, 1970.  The third is the email address of the
  # entity that created the news group.  When executed, the information
  # is displayed following the 215 response.  When display is completed,
  # the server will send a period on a line by itself.  If the
  # information is not available, the server will return the 503 error
  # response.  This command first appeared in the UNIX reference version.
  #
  # ### 2.1.3.1 Responses
  # ```text
  #   215 information follows
  #   503 program error, function not performed
  # ```
  def list_active_times
    longcmd("LIST ACTIVE.TIMES")
  end

  # [RFC2980](https://www.ietf.org/rfc/rfc2980.txt)
  # `2.1.4 LIST DISTRIBUTIONS`
  #
  # ### 2.1.4 LIST DISTRIBUTIONS
  # ```text
  #    LIST DISTRIBUTIONS
  # ```
  #
  # The distributions file is maintained by some news transport systems
  # to contain information about valid values for the Distribution: line
  # in a news article header and about what the values mean.  Each line
  # contains two fields, the value and a short explanation on the meaning
  # of the value.  When executed, the information is displayed following
  # the 215 response.  When display is completed, the server will send a
  # period on a line by itself.  If the information is not available, the
  # server will return the 503 error response.  This command first
  # appeared in the UNIX reference version.
  #
  # ### 2.1.4.1 Responses
  # ```text
  #   215 information follows
  #   503 program error, function not performed
  # ```
  def list_distributions
    longcmd("LIST DISTRIBUTIONS")
  end

  # [RFC2980](https://www.ietf.org/rfc/rfc2980.txt)
  # `2.1.5 LIST DISTRIB.PATS`
  #
  # ### 2.1.5 LIST DISTRIB.PATS
  # ```text
  #    LIST DISTRIB.PATS
  # ```
  #
  # The distrib.pats file is maintained by some news transport systems to
  # contain default values for the Distribution:  line in a news article
  # header when posting to particular news groups.  This information
  # could be used to provide a default value for the Distribution: line
  # in the header when posting an article.  The information returned
  # involves three fields separated by colons.  The first column is a
  # weight.  The second is a group name or a pattern that can be used to
  # match a group name in the wildmat format.  The third is the value of
  # the Distribution:  line that should be used when the group name
  # matches and the weight value is the highest.  All this processing is
  # done by the news posting client and not by the server itself.  The
  # server just provides this information to the client for it to use or
  # ignore as it chooses.  When executed, the information is displayed
  # following the 215 response.  When display is completed, the server
  # will send a period on a line by itself.  If the information is not
  # available, the server will return the 503 error response.  This
  # command first appeared in INN.
  #
  # ### 2.1.5.1 Responses
  # ```text
  #   215 information follows
  #   503 program error, function not performed
  # ```
  def list_distrib_pats
    longcmd("LIST DISTRIB.PATS")
  end

  # [RFC2980](https://www.ietf.org/rfc/rfc2980.txt)
  # `2.1.6 LIST NEWSGROUPS`
  #
  # ### 2.1.6 LIST NEWSGROUPS
  # ```text
  #    LIST NEWSGROUPS [wildmat]
  # ```
  #
  # The newsgroups file is maintained by some news transport systems to
  # contain the name of each news group which is active on the server and
  # a short description about the purpose of each news group.  Each line
  # in the file contains two fields, the news group name and a short
  # explanation of the purpose of that news group.  When executed, the
  # information is displayed following the 215 response.  When display is
  # completed, the server will send a period on a line by itself.  If the
  # information is not available, the server will return the 503
  # response.  If the optional matching parameter is specified, the list
  # is limited to only the groups that match the pattern (no matching is
  # done on the group descriptions).  Specifying a single group is
  # usually very efficient for the server, and multiple groups may be
  # specified by using wildmat patterns (similar to file globbing), not
  # regular expressions.  If nothing is matched an empty list is
  # returned, not an error.
  #
  # When the optional parameter is specified, this command is equivalent
  # to the XGTITLE command, though the response code are different.
  #
  # ### 2.1.6.1 Responses
  # ```text
  #   215 information follows
  #   503 program error, function not performed
  # ```
  def list_newsgroups(wildmat = "")
    longcmd("LIST ACTIVE %s", wildmat)
  end

  # [RFC2980](https://www.ietf.org/rfc/rfc2980.txt)
  # `2.1.8 LIST SUBSCRIPTIONS`
  #
  # ### 2.1.8 LIST SUBSCRIPTIONS
  # ```text
  #    LIST SUBSCRIPTIONS
  # ```
  #
  # This command is used to get a default subscription list for new users
  # of this server.  The order of groups is significant.
  #
  # When this list is available, it is preceded by the 215 response and
  # followed by a period on a line by itself.  When this list is not
  # available, the server returns a 503 response code.
  #
  # ### 2.1.8.1 Responses
  # ```text
  #   215 information follows
  #   503 program error, function not performed
  # ```
  def list_subscriptions
    longcmd("LIST SUBSCRIPTIONS")
  end

  # [RFC2980](https://www.ietf.org/rfc/rfc2980.txt)
  # `2.2 LISTGROUP`
  #
  # ### 2.2 LISTGROUP
  # ```text
  #    LISTGROUP [ggg]
  # ```
  #
  # The LISTGROUP command is used to get a listing of all the article
  # numbers in a particular news group.
  #
  # The optional parameter ggg is the name of the news group to be
  # selected (e.g. "news.software.b").  A list of valid news groups may
  # be obtained from the LIST command.  If no group is specified, the
  # current group is used as the default argument.
  #
  # The successful selection response will be a list of the article
  # numbers in the group followed by a period on a line by itself.
  #
  # When a valid group is selected by means of this command, the
  # internally maintained "current article pointer" is set to the first
  # article in the group.  If an invalid group is specified, the
  # previously selected group and article remain selected.  If an empty
  # news group is selected, the "current article pointer" is in an
  # indeterminate state and should not be used.
  #
  # Note that the name of the news group is not case-dependent.  It must
  # otherwise match a news group obtained from the LIST command or an
  # error will result.
  #
  # ### 2.2.1 Responses
  # ```text
  #   211 list of article numbers follow
  #   412 Not currently in newsgroup
  #   502 no permission
  # ```
  def listgroup(group = "")
    longcmd("LISTGROUP %s", group)
  end
end
