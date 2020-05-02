require "./errors"
require "base64"

module Net::NNTP::Auth
  abstract def socket : Net::NNTP::Socket
  abstract def shortcmd(fmt, *args) : Net::NNTP::Response
  abstract def critical(&block)

  {% begin %}
    {% auth_methods = %w(original simple generic plain starttls external cram_md5 digest_md5 gassapi) %}

    AUTH_METHODS = [
      {% for m in auth_methods %}
      :{{m.id}},
      {% end %}
    ]

    def authenticate(user, secret, method = :original)
        Log.info { "auth.start: [user: #{user}, method: #{method}]" }
        case method
        {% for m in auth_methods %}
        when :{{m.id}}
          auth_{{m.id}}(user, secret)
        {% end %}
        else
          Log.error { "Unsupported auth method: #{method}" }
          raise NNTP::Error::AuthenticationError.new "Unsupported auth method: #{method}"
        end
    end

    {% for m in auth_methods %}
      private def auth_{{m.id}}(user, secret)
        raise NotImplementedError.new(%<Auth for method "{{m.id}}" has not been implimented>)
      end
    {% end %}
  {% end %}

  # AUTHINFO USER username
  # AUTHINFO PASS password
  private def auth_original(user, secret)
    resp = critical {
      shortcmd("AUTHINFO USER %s", user).check!(true)
      shortcmd("AUTHINFO PASS %s", secret).check!(true)
    }
    raise NNTP::Error::AuthenticationError.new(resp.to_s) unless /\A2../ === resp.status
  end

  # AUTHINFO SIMPLE
  # username password
  private def auth_simple(user, secret)
    resp = critical {
      shortcmd("AUTHINFO SIMPLE").check!(true)
      shortcmd("%s %s", user, secret).check!(true)
    }
    raise NNTP::Error::AuthenticationError.new(resp.to_s) unless /\A2../ === resp.status
  end

  # AUTHINFO GENERIC authenticator arguments ...
  #
  # The authentication protocols are not inculeded in RFC2980,
  # see [RFC1731] (http://www.ietf.org/rfc/rfc1731.txt).
  private def auth_generic(fmt, *args)
    resp = critical {
      cmd = "AUTHINFO GENERIC " + sprintf(fmt, *args)
      shortcmd(cmd).check!(true)
    }
    raise NNTP::Error::AuthenticationError.new(resp.to_s) unless /\A2../ === resp.status
  end

  # AUTHINFO SASL PLAIN
  private def auth_plain(user, secret)
    resp = critical {
      shortcmd("AUTHINFO SASL PLAIN %s",
        Base64.encode("\0#{user}\0#{secret}")).check!(true)
    }
    raise NNTP::Error::AuthenticationError.new(resp.to_s) unless /\A2../ === resp.status
  end
end
