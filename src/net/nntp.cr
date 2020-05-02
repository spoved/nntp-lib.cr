require "log"

class Net::NNTP
  Log = ::Log.for(self)
end

require "./nntp/*"

# = Net::NNTP
#
# == What is This Library?
#
# This library provides functionality to retrieve and, or post Usenet news
# articles via NNTP, the Network News Transfer Protocol. The Usenet is a
# world-wide distributed discussion system. It consists of a set of
# "newsgroups" with names that are classified hierarchically by topic.
# "articles" or "messages" are "posted" to these newsgroups by people on
# computers with the appropriate software -- these articles are then
# broadcast to other interconnected NNTP servers via a wide variety of
# networks. For details of NNTP itself, see [RFC977]
# (http://www.ietf.org/rfc/rfc977.txt).
#
# == What is This Library NOT?
#
# This library does NOT provide functions to compose Usenet news. You
# must create and, or format them yourself as per guidelines per
# Standard for Interchange of Usenet messages, see [RFC850], [RFC2047]
# and a fews other RFC's (http://www.ietf.org/rfc/rfc850.txt),
# (http://www.ietf.org/rfc/rfc2047.txt).
#
# FYI: the official documentation on Usenet news extentions is: [RFC2980]
# (http://www.ietf.org/rfc/rfc2980.txt).
class Net::NNTP
  CRLF = "\x0d\x0a"
  EOT  = ".#{CRLF}"

  # The default NNTP port, port 119.
  DEFAULT_PORT = 119

  # The default NNTP port, port 119.
  def self.default_port
    DEFAULT_PORT
  end

  include Net::NNTP::Commands
  include Net::NNTP::Auth

  # The address of the NNTP server to connect to.
  getter address : String

  # The port number of the NNTP server to connect to.
  getter port : Int32

  property started : Bool = false
  property error_occured : Bool = false
  property socket : Net::NNTP::Socket

  property debug_output : Nil = nil

  # Creates a new Net::NNTP object.
  #
  # +address+ is the hostname or ip address of your NNTP server. +port+ is
  # the port to connect to; it defaults to port 119.
  #
  # This method does not opens any TCP connection. You can use NNTP.start
  # instead of NNTP.new if you want to do everything at once.  Otherwise,
  # follow NNTP.new with optional changes to +:open_timeout+,
  # +:read_timeout+ and, or +NNTP#set_debug_output+ and then NNTP#start.
  #
  def initialize(@address, port : Int32? = nil, @use_ssl = true)
    @port = port.nil? ? NNTP.default_port : port
    @socket = Net::NNTP::Socket.new(address, port)
  end

  # Opens a TCP connection and starts the NNTP session.
  #
  # === Parameters
  #
  # If both of +user+ and +secret+ are given, NNTP authentication  will be
  # attempted using the AUTH command. The +method+ specifies  the type of
  # authentication to attempt; it must be one of :original, :simple,
  # :generic, :plain, :starttls, :external, :cram_md5, :digest_md5 and, or
  # :gassapi may be used.  See the discussion of NNTP Authentication in the
  # overview notes.
  def start(user, secret, method)
    _do_start(user, secret, method)
  end

  def _do_start(user, secret, method = :original)
    raise IO::Error.new("NNTP session already started") if started
    check_auth_args(user, secret, method) if user || secret
    socket.open

    resp = recv_response
    check_response(resp)
    Log.debug { "Received initial response: #{resp}" }

    start_reader_mode(user, secret, method)
  ensure
    socket.close
  end

  def start_reader_mode(user, secret, method)
    mode_reader_success = false
    tried_authenticating = false
    until mode_reader_success
      begin
        resp = mode_reader
        mode_reader_success = /\A201/ === resp
      rescue ex : NNTP::Error::AuthenticationError
        raise ex if tried_authenticating
        # Try authenticating now
        authenticate(user, secret, method)
        tried_authenticating = true
      rescue ex
        Log.error(exception: ex) { "Failed to authenticate" }
        raise ex
      end
    end
  end

  def critical(&block)
    return "200 dummy reply code" if error_occured
    begin
      return yield
    rescue ex
      @error_occured = true
      raise ex
    end
  end

  def check_auth_args(user, secret, method)
    raise ArgumentError.new("both user and secret are required") if user.nil? || secret.nil?
    # authmeth = "auth_#{method || 'original'}"
    # raise ArgumentError.new( "wrong auth type #{method}")\
    #   unless respond_to?(authmeth, true)
  end

  def recv_response
    socket.gets(chomp: true)
  end

  getter response_text_buffer : Array(String) = Array(String).new(1)

  def recv_response_text
    response_text_buffer.clear
    eot = false
    while !eot
      line = self.socket.gets(chomp: false)
      unless line.nil?
        response_text_buffer << line.chomp
        eot = (line == EOT)
      end
    end
    response_text_buffer.dup
  end

  def check_response(stat, allow_continue = false)
    return stat if /\A1/ === stat                      # 1xx info msg
    return stat if /\A2/ === stat                      # 2xx cmd k
    return stat if allow_continue && /\A[35]/ === stat # 3xx cmd k, snd rst
    exception = case stat
                when /\A440/ then NNTP::Error::PostingNotAllowed # 4xx cmd k, bt nt prfmd
                when /\A48/  then NNTP::Error::AuthenticationError
                when /\A4/   then NNTP::Error::ServerBusy
                when /\A50/  then NNTP::Error::SyntaxError # 5xx cmd ncrrct
                when /\A55/  then NNTP::Error::FatalError
                else
                  NNTP::Error::UnknownError
                end
    raise exception.new stat
  end
end
