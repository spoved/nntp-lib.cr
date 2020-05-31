require "./errors"
require "json"

class Net::NNTP::Response
  include JSON::Serializable

  @[JSON::Field(key: "status")]
  property status : String
  @[JSON::Field(key: "msg")]
  property msg : String
  @[JSON::Field(key: "text")]
  property text : Array(String)

  def initialize(@status, @msg, @text = [] of String); end

  def valid?(allow_continue = false) : Bool
    begin
      check!(allow_continue)
    rescue
      false
    end
    true
  end

  def check!(allow_continue = false) : Net::NNTP::Response
    return self if /\A1/ === status                      # 1xx info msg
    return self if /\A2/ === status                      # 2xx cmd k
    return self if allow_continue && /\A[35]/ === status # 3xx cmd k, snd rst
    exception = case status
                when /\A440/ then NNTP::Error::PostingNotAllowed # 4xx cmd k, bt nt prfmd
                when /\A48/  then NNTP::Error::AuthenticationError
                when /\A4/
                  if /limit\s+reached/i === msg
                    NNTP::Error::TimeLimit
                  else
                    NNTP::Error::ServerBusy
                  end
                when /\A50/ then NNTP::Error::SyntaxError # 5xx cmd ncrrct
                when /\A55/ then NNTP::Error::FatalError
                else
                  NNTP::Error::UnknownError
                end

    raise exception.new(self.to_s)
  end

  # :nodoc:
  def to_s
    to_json
  end

  # :nodoc:
  def to_s(io)
    io << to_json
  end
end
