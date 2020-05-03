require "log"

class Net::NNTP
  Log = ::Log.for(self)
end

require "./nntp/*"
require "./nntp/commands/extensions"

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
  # The default NNTP port, port 119.
  DEFAULT_PORT = 119

  # The default NNTP port, port 119.
  def self.default_port
    DEFAULT_PORT
  end

  include Net::NNTP::Commands
  include Net::NNTP::Commands::Extensions
  include Net::NNTP::Auth

  # The address of the NNTP server to connect to.
  getter address : String

  # The port number of the NNTP server to connect to.
  getter port : Int32

  private property started : Bool = false

  def started?
    self.started
  end

  private property error_occured : Bool = false
  private property socket : Net::NNTP::Socket

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
  #
  # === Block Usage
  #
  # When this methods is called with a block, the newly-started NNTP object
  # is yielded to the block, and automatically closed after the block call
  # finishes.  Otherwise, it is the caller's  responsibility to close the
  # session when finished.
  #
  # === Example
  #
  # This is very similar to the class method NNTP.start.
  #
  #     require 'net/nntp'
  #     nntp = Net::NNTP.new('nntp.news.server', 119)
  #     nntp.start(account, password, method) do |nntp|
  #       nntp.post msgstr
  #     end
  #
  # The primary use of this method (as opposed to NNTP.start) is probably
  # to set debugging (#set_debug_output), which must be done before the
  # session is started.
  #
  # === Errors
  #
  # If session has already been started, an IO::Error will be raised.
  #
  # This method may raise:
  #
  # * Net::NNTP::Error::AuthenticationError
  # * Net::NNTP::Error::FatalError
  # * Net::NNTP::Error::ServerBusy
  # * Net::NNTP::Error::SyntaxError
  # * Net::NNTP::Error::UnknownError
  # * IO::Error
  # * IO::TimeoutError
  #
  def start(user, secret, method)
    _do_start(user, secret, method)
  end

  def finish
    _do_finish
  end

  def start(user, secret, method, &block)
    _do_start(user, secret, method)
    yield self
  ensure
    finish
  end

  private def _do_start(user, secret, method = :original)
    raise IO::Error.new("NNTP session already started") if started
    check_auth_args(user, secret, method) if user || secret
    socket.open

    resp = socket.recv_response
    resp.check!
    Log.verbose { "do_start.init.response: [#{resp.to_json}]" }

    start_reader_mode(user, secret, method)

    self.started = true
  end

  private def _do_finish
    quit unless self.socket.closed?
  ensure
    self.started = false
    self.error_occured = false
    self.socket.close unless self.socket.closed?
  end

  private def start_reader_mode(user, secret, method)
    mode_reader_success = false
    tried_authenticating = false
    until mode_reader_success
      begin
        resp = mode_reader
        mode_reader_success = /\A201/ === resp.status
      rescue ex : NNTP::Error::AuthenticationError
        raise ex if tried_authenticating
        # Try authenticating now
        authenticate(user, secret, method)
        tried_authenticating = true
      rescue ex
        Log.error(exception: ex) { "start_reader_mode: [Failed to authenticate]" }
        raise ex
      end
    end

    authenticate(user, secret, method) unless tried_authenticating
  end

  private def check_auth_args(user, secret, method)
    raise ArgumentError.new("both user and secret are required") if user.nil? || secret.nil?
    # authmeth = "auth_#{method || 'original'}"
    # raise ArgumentError.new( "wrong auth type #{method}")\
    #   unless respond_to?(authmeth, true)
  end
end
