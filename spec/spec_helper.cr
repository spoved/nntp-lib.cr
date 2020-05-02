require "dotenv"
Dotenv.load if File.exists?(".env")
Log.builder.bind "*", :debug, Log::IOBackend.new

require "spec"
require "../src/nntp-lib"

def with_client
  nntp = Net::NNTP.new(ENV["USENET_HOST"], ENV["USENET_PORT"].to_i)
  nntp.start(ENV["USENET_USER"], ENV["USENET_PASS"], :original) do |client|
    yield client
  end
end
