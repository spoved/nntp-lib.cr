require "./errors"

module Net::NNTP::Commands
  abstract def socket : Net::NNTP::Socket

  def shortcmd(fmt, *args) : Net::NNTP::Response
    Log.verbose { "cmds.shortcmd.fmt: [#{fmt}]" }
    resp = critical { socket.send(fmt, *args) }
    Log.verbose { "cmds.shortcmd.response: [#{resp}]" }
    resp.check!
  end

  def longcmd(fmt, *args)
    Log.verbose { "cmds.longcmd.fmt: [#{fmt}]" }
    resp = critical { socket.send(fmt, *args) }
    resp.check!
    Log.verbose { "cmds.longcmd.response: [#{resp}]" }
    socket.recv_response_text(resp)
    Log.debug { "cmds.longcmd.full_response: [#{resp}]" }
    resp
  end

  def critical(&block)
    return Net::NNTP::Response.new("200", "dummy reply code") if error_occured
    begin
      yield
    rescue ex
      @error_occured = true
      raise ex
    end
  end

  # 3.1.1.  ARTICLE (selection by message-id)
  #
  #    ARTICLE <message-id>
  #
  #    Display the header, a blank line, then the body (text) of the
  #    specified article.  Message-id is the message id of an article as
  #    shown in that article's header.  It is anticipated that the client
  #    will obtain the message-id from a list provided by the NEWNEWS
  #    command, from references contained within another article, or from
  #    the message-id provided in the response to some other commands.
  #
  #    Please note that the internally-maintained "current article pointer"
  #    is NOT ALTERED by this command. This is both to facilitate the
  #    presentation of articles that may be referenced within an article
  #    being read, and because of the semantic difficulties of determining
  #    the proper sequence and membership of an article which may have been
  #    posted to more than one newsgroup.
  #
  # 3.1.3.  Responses
  #
  #    220 n <a> article retrieved - head and body follow
  #            (n = article number, <a> = message-id)
  #    221 n <a> article retrieved - head follows
  #    222 n <a> article retrieved - body follows
  #    223 n <a> article retrieved - request text separately
  #    412 no newsgroup has been selected
  #    420 no current article has been selected
  #    423 no such article number in this group
  #    430 no such article found
  #
  # @example
  # ```
  # nntp.group "alt.binaries.cbt"
  # nntp.article("nkdtopWMXkIqWnuDoljqJRJUPKQsWQMk@news.usenet.farm")
  # ```
  #
  # Response package
  # ```json
  # {
  #   "status": "220",
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
  #     "X-Received-Body-CRC: 3862205996",
  #     "",
  #     "",
  #     "",
  #     "*** iPhone SUPER-SPECIAL-DISCOUNT 80% OFF --- UNBEATABLE SUPER-PRICES !!! ***",
  #     "",
  #     "Save LOTS OF CASH on a wide collections of iPhones, 80% off",
  #     "everything must go to make place of next generation iPhone",
  #     "",
  #     "Bell Super Discounts",
  #     "http://www.grex.org/~henced/iPhones.html"
  #   ]
  # }
  # ```
  def article(message_id : String)
    longcmd("ARTICLE <%s>", message_id)
  end

  # 3.1.2.  ARTICLE (selection by number)
  #
  #  ARTICLE [nnn]
  #
  #  Displays the header, a blank line, then the body (text) of the
  #  current or specified article.  The optional parameter nnn is the
  #
  #  numeric id of an article in the current newsgroup and must be chosen
  #  from the range of articles provided when the newsgroup was selected.
  #  If it is omitted, the current article is assumed.
  #
  #  The internally-maintained "current article pointer" is set by this
  #  command if a valid article number is specified.
  #
  #  [the following applies to both forms of the article command.] A
  #  response indicating the current article number, a message-id string,
  #  and that text is to follow will be returned.
  #
  #  The message-id string returned is an identification string contained
  #  within angle brackets ("<" and ">"), which is derived from the header
  #  of the article itself.  The Message-ID header line (required by
  #  RFC850) from the article must be used to supply this information. If
  #  the message-id header line is missing from the article, a single
  #  digit "0" (zero) should be supplied within the angle brackets.
  #
  #  Since the message-id field is unique with each article, it may be
  #  used by a news reading program to skip duplicate displays of articles
  #  that have been posted more than once, or to more than one newsgroup.
  #
  # 3.1.3.  Responses
  #
  #    220 n <a> article retrieved - head and body follow
  #            (n = article number, <a> = message-id)
  #    221 n <a> article retrieved - head follows
  #    222 n <a> article retrieved - body follows
  #    223 n <a> article retrieved - request text separately
  #    412 no newsgroup has been selected
  #    420 no current article has been selected
  #    423 no such article number in this group
  #    430 no such article found
  #
  # @example
  # ```
  # nntp.group "alt.binaries.cbt"
  # nntp.article(56910052)
  # ```
  #
  # Response package
  # ```json
  # {
  #   "status": "220",
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
  #     "X-Received-Body-CRC: 3862205996",
  #     "",
  #     "",
  #     "",
  #     "*** iPhone SUPER-SPECIAL-DISCOUNT 80% OFF --- UNBEATABLE SUPER-PRICES !!! ***",
  #     "",
  #     "Save LOTS OF CASH on a wide collections of iPhones, 80% off",
  #     "everything must go to make place of next generation iPhone",
  #     "",
  #     "Bell Super Discounts",
  #     "http://www.grex.org/~henced/iPhones.html"
  #   ]
  # }
  # ```
  def article(num : Int64 | Int32 = 0)
    if num.zero?
      longcmd("ARTICLE")
    else
      longcmd("ARTICLE %d", num)
    end
  end

  # 3.2.1.  GROUP
  #
  #    GROUP ggg
  #
  #    The required parameter ggg is the name of the newsgroup to be
  #    selected (e.g. "net.news").  A list of valid newsgroups may be
  #    obtained from the LIST command.
  #
  #    The successful selection response will return the article numbers of
  #    the first and last articles in the group, and an estimate of the
  #    number of articles on file in the group.  It is not necessary that
  #    the estimate be correct, although that is helpful; it must only be
  #    equal to or larger than the actual number of articles on file.  (Some
  #    implementations will actually count the number of articles on file.
  #    Others will just subtract first article number from last to get an
  #    estimate.)
  #
  #    When a valid group is selected by means of this command, the
  #    internally maintained "current article pointer" is set to the first
  #    article in the group.  If an invalid group is specified, the
  #    previously selected group and article remain selected.  If an empty
  #    newsgroup is selected, the "current article pointer" is in an
  #    indeterminate state and should not be used.
  #
  #    Note that the name of the newsgroup is not case-dependent.  It must
  #    otherwise match a newsgroup obtained from the LIST command or an
  #    error will result.
  #
  # 3.2.2.  Responses
  #
  #    211 n f l s group selected
  #            (n = estimated number of articles in group,
  #            f = first article number in the group,
  #            l = last article number in the group,
  #            s = name of the group.)
  #    411 no such news group
  #
  # @example
  # ```
  # nntp.group("alt.binaries.cbt") # => { "status": "211", "msg": "56894721 15332 56910052 alt.binaries.cbt", "text": [] }
  # ```
  def group(name)
    shortcmd("GROUP %s", name)
  end

  # 3.3.1.  HELP
  #
  #    HELP
  #
  #    Provides a short summary of commands that are understood by this
  #    implementation of the server. The help text will be presented as a
  #    textual response, terminated by a single period on a line by itself.
  #
  #    3.3.2.  Responses
  #
  #    100 help text follows
  def help : Net::NNTP::Response
    longcmd("HELP")
  end

  # 3.5.1.  LAST
  #
  #    LAST
  #
  #    The internally maintained "current article pointer" is set to the
  #    previous article in the current newsgroup.  If already positioned at
  #    the first article of the newsgroup, an error message is returned and
  #    the current article remains selected.
  #
  #    The internally-maintained "current article pointer" is set by this
  #    command.
  #
  #    A response indicating the current article number, and a message-id
  #    string will be returned.  No text is sent in response to this
  #    command.
  #
  # 3.5.2.  Responses
  #
  #    223 n a article retrieved - request text separately
  #            (n = article number, a = unique article id)
  #    412 no newsgroup selected
  #    420 no current article has been selected
  #    422 no previous article in this group
  #
  # @example
  # ```
  # nntp.group "alt.binaries.cbt"
  # nntp.article 56910052
  # nntp.last
  # ```
  #
  # Response package
  # ```json
  # {
  #   "status": "223",
  #   "msg": "56910051 <IlzfKsEkBrqsCkASiWBkglXIoendJbgL@news.usenet.farm>",
  #   "text": []
  # }
  # ```
  def last
    shortcmd("LAST")
  end

  # 3.6.1.  LIST
  #
  #    LIST
  #
  #    Returns a list of valid newsgroups and associated information.  Each
  #    newsgroup is sent as a line of text in the following format:
  #
  #       group last first p
  #
  #    where <group> is the name of the newsgroup, <last> is the number of
  #    the last known article currently in that newsgroup, <first> is the
  #    number of the first article currently in the newsgroup, and <p> is
  #    either 'y' or 'n' indicating whether posting to this newsgroup is
  #    allowed ('y') or prohibited ('n').
  #
  #    The <first> and <last> fields will always be numeric.  They may have
  #    leading zeros.  If the <last> field evaluates to less than the
  #    <first> field, there are no articles currently on file in the
  #    newsgroup.
  #
  #    Note that posting may still be prohibited to a client even though the
  #    LIST command indicates that posting is permitted to a particular
  #    newsgroup. See the POST command for an explanation of client
  #    prohibitions.  The posting flag exists for each newsgroup because
  #    some newsgroups are moderated or are digests, and therefore cannot be
  #    posted to; that is, articles posted to them must be mailed to a
  #    moderator who will post them for the submitter.  This is independent
  #    of the posting permission granted to a client by the NNTP server.
  #
  #    Please note that an empty list (i.e., the text body returned by this
  #    command consists only of the terminating period) is a possible valid
  #    response, and indicates that there are currently no valid newsgroups.
  #
  # 3.6.2.  Responses
  #
  #    215 list of newsgroups follows
  #
  # @example
  # ```
  # nntp.list
  # ```
  #
  # Response package
  # ```json
  # {
  #   "status": "215",
  #   "msg": "NewsGroups Follow",
  #   "text": [
  #     "0 4720041 2 y",
  #     "0.akita-inu 1925 2 y",
  #     "0.alaskan-malamute 969 2 y",
  #     "0.alaskan-malamutes 890 2 y",
  #     "0.siberian-huskys 979 2 y",
  #     "0.test 1107300 2 y",
  #     "0.verizon.adsl 2378 2 y",
  #     "0.verizon.discussion-general 2953 2 y",
  #     "0.verizon.email.spam 873 2 y",
  #     "0.verizon.flame 836 2 y",
  #     "0.verizon.linux 940 2 y",
  #     "0.verizon.newsgroup.requests 1524 2 y",
  #     "0.verizon.security 871 2 y",
  #     .....
  # }
  # ```
  def list
    longcmd("LIST")
  end

  # 3.7.1.  NEWGROUPS
  #
  #    NEWGROUPS date time [GMT] [<distributions>]
  #
  #    A list of newsgroups created since <date and time> will be listed in
  #    the same format as the LIST command.
  #
  #    The date is sent as 6 digits in the format YYMMDD, where YY is the
  #    last two digits of the year, MM is the two digits of the month (with
  #    leading zero, if appropriate), and DD is the day of the month (with
  #    leading zero, if appropriate).  The closest century is assumed as
  #    part of the year (i.e., 86 specifies 1986, 30 specifies 2030, 99 is
  #    1999, 00 is 2000).
  #
  #    Time must also be specified.  It must be as 6 digits HHMMSS with HH
  #    being hours on the 24-hour clock, MM minutes 00-59, and SS seconds
  #    00-59.  The time is assumed to be in the server's timezone unless the
  #    token "GMT" appears, in which case both time and date are evaluated
  #    at the 0 meridian.
  #
  #    The optional parameter "distributions" is a list of distribution
  #    groups, enclosed in angle brackets.  If specified, the distribution
  #    portion of a new newsgroup (e.g, 'net' in 'net.wombat') will be
  #    examined for a match with the distribution categories listed, and
  #    only those new newsgroups which match will be listed.  If more than
  #    one distribution group is to be listed, they must be separated by
  #    commas within the angle brackets.
  #
  #    Please note that an empty list (i.e., the text body returned by this
  #    command consists only of the terminating period) is a possible valid
  #    response, and indicates that there are currently no new newsgroups.
  #
  # 3.7.2.  Responses
  #
  #    231 list of new newsgroups follows
  #
  # @example
  # ```
  # nntp.newgroups
  # ```
  #
  # Response package
  # ```json
  # {
  #   "status": "231",
  #   "msg": "New newsgroups follow.",
  #   "text": []
  # }
  # ```
  def new_groups
    longcmd("NEWGROUPS")
  end

  # 3.8.1.  NEWNEWS
  #
  #    NEWNEWS newsgroups date time [GMT] [<distribution>]
  #
  #    A list of message-ids of articles posted or received to the specified
  #    newsgroup since "date" will be listed. The format of the listing will
  #    be one message-id per line, as though text were being sent.  A single
  #    line consisting solely of one period followed by CR-LF will terminate
  #    the list.
  #
  #    Date and time are in the same format as the NEWGROUPS command.
  #
  #    A newsgroup name containing a "*" (an asterisk) may be specified to
  #    broaden the article search to some or all newsgroups.  The asterisk
  #    will be extended to match any part of a newsgroup name (e.g.,
  #    net.micro* will match net.micro.wombat, net.micro.apple, etc). Thus
  #    if only an asterisk is given as the newsgroup name, all newsgroups
  #    will be searched for new news.
  #
  #    (Please note that the asterisk "*" expansion is a general
  #    replacement; in particular, the specification of e.g., net.*.unix
  #    should be correctly expanded to embrace names such as net.wombat.unix
  #    and net.whocares.unix.)
  #
  #    Conversely, if no asterisk appears in a given newsgroup name, only
  #    the specified newsgroup will be searched for new articles. Newsgroup
  #    names must be chosen from those returned in the listing of available
  #    groups.  Multiple newsgroup names (including a "*") may be specified
  #    in this command, separated by a comma.  No comma shall appear after
  #    the last newsgroup in the list.  [Implementors are cautioned to keep
  #    the 512 character command length limit in mind.]
  #
  #    The exclamation point ("!") may be used to negate a match. This can
  #    be used to selectively omit certain newsgroups from an otherwise
  #    larger list.  For example, a newsgroups specification of
  #    "net.*,mod.*,!mod.map.*" would specify that all net.<anything> and
  #    all mod.<anything> EXCEPT mod.map.<anything> newsgroup names would be
  #    matched.  If used, the exclamation point must appear as the first
  #    character of the given newsgroup name or pattern.
  #
  #    The optional parameter "distributions" is a list of distribution
  #    groups, enclosed in angle brackets.  If specified, the distribution
  #    portion of an article's newsgroup (e.g, 'net' in 'net.wombat') will
  #    be examined for a match with the distribution categories listed, and
  #    only those articles which have at least one newsgroup belonging to
  #    the list of distributions will be listed.  If more than one
  #    distribution group is to be supplied, they must be separated by
  #    commas within the angle brackets.
  #
  #    The use of the IHAVE, NEWNEWS, and NEWGROUPS commands to distribute
  #    news is discussed in an earlier part of this document.
  #
  #    Please note that an empty list (i.e., the text body returned by this
  #    command consists only of the terminating period) is a possible valid
  #    response, and indicates that there is currently no new news.
  #
  # 3.8.2.  Responses
  #
  #    230 list of new articles by message-id follows
  #
  # @example
  # ```
  # nntp.new_news
  # ```
  #
  # Response package
  # ```json
  # {
  #   "status": "230",
  #   "msg": "???????",
  #   "text": []
  # }
  # ```
  def new_news
    longcmd("NEWNEWS")
  end

  # 3.9.1.  NEXT
  #
  #    NEXT
  #
  #    The internally maintained "current article pointer" is advanced to
  #    the next article in the current newsgroup.  If no more articles
  #    remain in the current group, an error message is returned and the
  #    current article remains selected.
  #
  #    The internally-maintained "current article pointer" is set by this
  #    command.
  #
  #    A response indicating the current article number, and the message-id
  #    string will be returned.  No text is sent in response to this
  #    command.
  #
  # 3.9.2.  Responses
  #
  #    223 n a article retrieved - request text separately
  #            (n = article number, a = unique article id)
  #    412 no newsgroup selected
  #    420 no current article has been selected
  #    421 no next article in this group
  #
  # @example
  # ```
  # nntp.group "alt.binaries.cbt"
  # nntp.article 56900000
  # nntp.next # => fetches 56900001
  # ```
  #
  # Response package
  # ```json
  # {
  #   "status": "223",
  #   "msg": "56900001 <XrXwSfUuLnTgGkPwFjUhPsDe-1587103045909@nyuu>",
  #   "text": []
  # }
  # ```
  def next
    shortcmd("NEXT")
  end

  # LIST [ACTIVE|NEWSGROUPS] [<Wildmat>]]:br:
  # LIST [ACTIVE.TIMES|EXTENSIONS|SUBSCRIPTIONS|OVERVIEW.FMT]
  # LISTGROUP <Newsgroup>
  # NEWGROUPS <[yy]yymmdd> <hhmmss> [GMT]
  # NEWNEWS <yymmdd> <hhmmss> [GMT]
  # NEXT
  # OVER <Range>  # e.g first[-[last]]
  # SLAVE
  # STAT [<Message-ID>|<Number>]
  # XHDR <Header> <Message-ID>|<Range>  # e.g first[-[last]]
  # XOVER <Range>  # e.g first[-[last]]

  # HEAD [<Message-ID>|<Number>]
  def head(id)
    longcmd("HEAD #{id}")
  end

  # MODE READER
  def mode_reader : Net::NNTP::Response
    shortcmd("MODE READER")
  end

  # QUIT
  def quit : Net::NNTP::Response
    shortcmd("QUIT")
  end

  # DATE
  # 20200502225525 => 2020-05-02-22:55:25
  def date : Net::NNTP::Response
    shortcmd("DATE")
  end
end
