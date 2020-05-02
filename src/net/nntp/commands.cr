require "./errors"

module Net::NNTP::Commands
  abstract def socket : Net::NNTP::Socket

  def shortcmd(fmt, *args) : Net::NNTP::Response
    Log.debug { "cmds.shortcmd.fmt: [#{fmt}]" }
    resp = critical { socket.send(fmt, *args) }
    Log.debug { "cmds.shortcmd.response: [#{resp}]" }
    resp.check!
  end

  def longcmd(fmt, *args)
    Log.debug { "cmds.longcmd.fmt: [#{fmt}]" }
    resp = critical { socket.send(fmt, *args) }
    resp.check!
    Log.debug { "cmds.longcmd.response: [#{resp}]" }
    socket.recv_response_text(resp)
    Log.verbose { "cmds.longcmd.full_response: [#{resp}]" }
    resp
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
    longcmd("HELP")
  end

  def date : Net::NNTP::Response
    shortcmd("DATE")
  end
end
