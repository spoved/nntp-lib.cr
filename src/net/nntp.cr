class Net::NNTP; end

require "./errors"
require "socket"
require "openssl"
require "log"

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
  Log  = ::Log.for(self)
  CRLF = "\x0d\x0a"
  EOT  = ".#{CRLF}"

  AUTH_METHODS = %w(original simple generic plain starttls external cram_md5 digest_md5 gassapi)

  # The default NNTP port, port 119.
  DEFAULT_PORT = 119

  # The default NNTP port, port 119.
  def self.default_port
    DEFAULT_PORT
  end

  # The address of the NNTP server to connect to.
  getter address : String

  # The port number of the NNTP server to connect to.
  getter port : Int32

  # Seconds to wait while attempting to open a connection. If the
  # connection cannot be opened within this time, a TimeoutError is raised.
  property open_timeout : Int32 = 30

  # Seconds to wait while reading one block (by one read(2) call). If the
  # read(2) call does not complete within this time, a TimeoutError is
  # raised.
  getter read_timeout : Int32 = 20

  property use_ssl : Bool = false
  property ssl_context : OpenSSL::SSL::Context::Client = OpenSSL::SSL::Context::Client.new
  # :nodoc:
  private property started : Bool = false
  # :nodoc:
  private property error_occured : Bool = false
  # :nodoc:
  private property tcp_socket : TCPSocket? = nil
  # :nodoc:
  private property ssl_socket : OpenSSL::SSL::Socket::Client? = nil

  private def socket : TCPSocket | OpenSSL::SSL::Socket::Client
    if (use_ssl)
      raise "NNTP Socket is not open!" if @ssl_socket.nil?
      @ssl_socket.as(OpenSSL::SSL::Socket::Client)
    else
      raise "NNTP Socket is not open!" if @tcp_socket.nil?
      @tcp_socket.as(TCPSocket)
    end
  end

  # :nodoc:
  private property debug_output : Nil = nil

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

  private def open_socket
    Log.debug { "Opening socket. use_ssl: #{use_ssl}" }
    sock = TCPSocket.new(self.address, self.port, connect_timeout: open_timeout)
    sock.read_timeout = read_timeout
    sock.blocking = false

    self.tcp_socket = sock
    if use_ssl
      self.ssl_socket = OpenSSL::SSL::Socket::Client.new(sock, ssl_context)
    end
  end

  # :nodoc:
  private def _do_start(user, secret, method = :original)
    raise IO::Error.new("NNTP session already started") if started
    check_auth_args(user, secret, method) if user || secret
    open_socket

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
        mode_reader
      rescue ex : Net::NNTP::AuthenticationError
        raise ex if tried_authenticating
        # Try authenticating now
        authenticate(user, secret, method)
        tried_authenticating = true
      rescue ex
        Log.error ex
        raise ex
      end
    end
  end

  def authenticate(user, secret, method)
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

  def shortcmd(fmt, *args)
    cmd = sprintf(fmt, *args)
    Log.debug { "Sent short cmd: #{cmd}" }
    stat = critical {
      socket <<
        socket << CRLF
      socket.flush
      recv_response
    }
    check_response(stat)
  end

  private def mode_reader
    stat = shortcmd("MODE READER")
    return stat
    # return stat[0..2], stat[4..-1].chop
  end

  # :nodoc:
  private def check_auth_args(user, secret, method)
    raise ArgumentError.new("both user and secret are required") if user.nil? || secret.nil?
    # authmeth = "auth_#{method || 'original'}"
    # raise ArgumentError.new( "wrong auth type #{method}")\
    #   unless respond_to?(authmeth, true)
  end

  private getter response_text_buffer : Array(String) = Array(String).new(1)

  private def recv_response
    socket.gets(chomp: true)
  end

  private def recv_response_text
    response_text_buffer.clear
    eot = false
    while !eot
      line = self.socket.gets(chomp: false)
      unless line.nil?
        response_text_buffer << line.chomp
        eot = (line == EOT)
      end
    end
    response_buffer.dup
  end

  # private def recv_response
  #   response_buffer.clear
  #   sot = eot = false
  #   count = 0
  #   while true
  #     count += 1 if sot
  #     line = self.socket.gets(chomp: true)
  #     unless line.nil?
  #       response_buffer << line
  #       sot = (/\A[1-5]\d\d/ === line)
  #       eot = (line == EOT)
  #     end
  #     Log.debug { "Response buff: #{response_buffer.size}, sot: #{sot}, eot: #{eot}, count: #{count}" }
  #     Log.info { "last line: #{response_buffer.last}" }
  #     break if count > 50
  #     break if eot
  #   end
  #   response_buffer
  # end

  private def check_response(stat, allow_continue = false)
    return stat if /\A1/ === stat                      # 1xx info msg
    return stat if /\A2/ === stat                      # 2xx cmd k
    return stat if allow_continue && /\A[35]/ === stat # 3xx cmd k, snd rst
    exception = case stat
                when /\A440/ then NNTP::PostingNotAllowed # 4xx cmd k, bt nt prfmd
                when /\A48/  then NNTP::AuthenticationError
                when /\A4/   then NNTP::ServerBusy
                when /\A50/  then NNTP::SyntaxError # 5xx cmd ncrrct
                when /\A55/  then NNTP::FatalError
                else
                  NNTP::UnknownError
                end
    raise exception.new stat
  end
end
