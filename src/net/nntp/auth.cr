require "./errors"

module Net::NNTP::Auth
  abstract def socket : Net::NNTP::Socket
  abstract def check_response(stat, allow_continue)
  abstract def shortcmd(fmt, *args)
  abstract def critical(&block)

  {% begin %}
    {% auth_methods = %w(original simple generic plain starttls external cram_md5 digest_md5 gassapi) %}

    AUTH_METHODS = [
      {% for m in auth_methods %}
      :{{m.id}},
      {% end %}
    ]

    def authenticate(user, secret, method = :original)
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

  private def auth_original(user, secret)
    stat = critical {
      check_response(shortcmd("AUTHINFO SIMPLE"), true)
      check_response(shortcmd("%s %s", user, secret), true)
    }
    raise NNTP::Error::AuthenticationError.new(stat) unless /\A2../ === stat
  end
end
