module Net
  # Module mixed in to all NNTP error classes
  class NNTP::Error < Exception
    # Represents an NNTP authentication error.
    class AuthenticationError < NNTP::Error; end

    # Represents NNTP error code 420 or 450, a temporary error.
    class ServerBusy < NNTP::Error; end

    # Represents NNTP error code 440, posting not permitted.
    class PostingNotAllowed < NNTP::Error; end

    # Represents an NNTP command syntax error (error code 500)
    class SyntaxError < NNTP::Error; end

    # Represents a fatal NNTP error (error code 5xx, except for 500)
    class FatalError < NNTP::Error; end

    # Unexpected reply code returned from server.
    class UnknownError < NNTP::Error; end

    # Error in NNTP response data.
    class DataError < NNTP::Error; end

    # Time limit reached
    class TimeLimit < NNTP::Error; end
  end
end
