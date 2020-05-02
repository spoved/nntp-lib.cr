require "./errors"
require "socket"
require "openssl"

class Net::NNTP::Socket
  CRLF     = "\x0d\x0a"
  EOT      = ".#{CRLF}"
  DOUBLE_P = ".."
  # The address of the NNTP server to connect to.
  getter address : String

  # The port number of the NNTP server to connect to.
  getter port : Int32

  # Seconds to wait while attempting to open a connection. If the
  # connection cannot be opened within this time, a TimeoutError is raised.
  property open_timeout : Int32

  # Seconds to wait while reading one block (by one read(2) call). If the
  # read(2) call does not complete within this time, a TimeoutError is
  # raised.
  getter read_timeout : Int32
  property use_ssl : Bool

  property tcp_socket : TCPSocket? = nil
  property ssl_socket : OpenSSL::SSL::Socket::Client? = nil
  property ssl_context : OpenSSL::SSL::Context::Client = OpenSSL::SSL::Context::Client.new

  private property closed = true

  def initialize(@address, @port = 119, @use_ssl = true,
                 @open_timeout = 30, @read_timeout = 60,
                 ssl_context : OpenSSL::SSL::Context::Client? = nil)
    @ssl_context = ssl_context unless ssl_context.nil?
  end

  def open
    Log.info { "socket.open: [address: #{address}, port: #{port} use_ssl: #{use_ssl}]" }

    sock = TCPSocket.new(address, port, connect_timeout: open_timeout)
    sock.read_timeout = read_timeout
    sock.blocking = false

    self.tcp_socket = sock
    if use_ssl
      self.ssl_socket = OpenSSL::SSL::Socket::Client.new(sock, ssl_context)
    end
    self.closed = false
    socket
  end

  def socket : TCPSocket | OpenSSL::SSL::Socket::Client
    if (use_ssl)
      raise "NNTP Socket is not open!" if @ssl_socket.nil?
      @ssl_socket.as(OpenSSL::SSL::Socket::Client)
    else
      raise "NNTP Socket is not open!" if @tcp_socket.nil?
      @tcp_socket.as(TCPSocket)
    end
  end

  def closed?
    self.closed
  end

  def close
    ssl_socket.not_nil!.close unless ssl_socket.nil?
    tcp_socket.not_nil!.close unless tcp_socket.nil?
    self.closed = true
  end

  def recv_response : Net::NNTP::Response
    stat = self.gets(chomp: true)
    raise NNTP::Error::UnknownError.new("Got nil response") if stat.nil?
    Net::NNTP::Response.new(stat[0..2], stat[4...-1])
  end

  getter response_text_buffer : Array(String) = Array(String).new(1)

  def recv_response_text(resp)
    response_text_buffer.clear
    eot = false
    while !eot
      line = self.gets(chomp: false)
      unless line.nil?
        eot = (line == EOT)
        unless eot
          if line[0...2] == DOUBLE_P
            response_text_buffer << line[1..-1].chomp
          else
            response_text_buffer << line.chomp
          end
        end
      end
    end
    resp.text.concat response_text_buffer
    response_text_buffer.clear
  end

  def send(fmt, *args)
    cmd = sprintf(fmt, *args)
    Log.verbose { "socket.send: [#{cmd}]" }
    socket << cmd
    socket << CRLF
    socket.flush
    recv_response
  end

  # Socket functions

  def gets(**args)
    socket.gets(**args)
  end

  def <<(val)
    socket << val
  end

  def flush
    socket.flush
  end
end
