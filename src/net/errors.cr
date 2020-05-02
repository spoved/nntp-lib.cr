# :nodoc:
module Net
  # Module mixed in to all NNTP error classes
  class NNTP::Error < Exception
  end

  # Represents an NNTP authentication error.
  class NNTP::AuthenticationError < NNTP::Error; end

  # Represents NNTP error code 420 or 450, a temporary error.
  class NNTP::ServerBusy < NNTP::Error; end

  # Represents NNTP error code 440, posting not permitted.
  class NNTP::PostingNotAllowed < NNTP::Error; end

  # Represents an NNTP command syntax error (error code 500)
  class NNTP::SyntaxError < NNTP::Error; end

  # Represents a fatal NNTP error (error code 5xx, except for 500)
  class NNTP::FatalError < NNTP::Error; end

  # Unexpected reply code returned from server.
  class NNTP::UnknownError < NNTP::Error; end

  # Error in NNTP response data.
  class NNTP::DataError < NNTP::Error; end
end
