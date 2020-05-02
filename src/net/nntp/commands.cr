require "./errors"

module Net::NNTP::Commands
  abstract def socket : Net::NNTP::Socket

  def shortcmd(fmt, *args) : Net::NNTP::Response
    cmd = sprintf(fmt, *args)
    Log.debug { "Sent short command: [#{cmd}]" }
    resp = critical {
      socket << cmd
      socket.send
      socket.recv_response
    }

    Log.debug { "Short command response: [#{resp}]" }
    resp.check!
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

  def mode_reader : Net::NNTP::Response
    shortcmd("MODE READER")
  end

  # QUIT
  def quit : Net::NNTP::Response
    shortcmd("QUIT")
  end

  def help : Net::NNTP::Response
    resp = shortcmd("HELP")
    socket.recv_response_text(resp)
    resp
  end

  def date : Net::NNTP::Response
    shortcmd("DATE")
  end
end
