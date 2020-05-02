require "./errors"

module Net::NNTP::Commands
  abstract def socket : Net::NNTP::Socket
  abstract def check_response(stat, allow_continue)
  abstract def critical(&block)
  abstract def recv_response
  abstract def recv_response_text

  def shortcmd(fmt, *args)
    cmd = sprintf(fmt, *args)
    Log.debug { "Sent short cmd: #{cmd}" }
    stat = critical {
      socket << cmd
      socket << CRLF
      socket.flush
      recv_response
    }
    check_response(stat)
  end

  def mode_reader
    stat = shortcmd("MODE READER")
    Log.debug { "Response: #{stat}" }
    return stat
    # return stat[0..2], stat[4..-1].chop
  end

  def print_help
    puts shortcmd("HELP")
    puts recv_response_text.join("\n")
  end
end
