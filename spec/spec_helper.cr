require "dotenv"
Dotenv.load if File.exists?(".env")
Log.builder.bind "*", :debug, Log::IOBackend.new

require "spec"
require "../src/nntp-lib"
