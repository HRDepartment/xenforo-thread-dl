# file: all_my_cli.cr
require "option_parser"
require "./src/xenforo_thread_dl"

thread_url = ""

option_parser = OptionParser.parse do |parser|
  parser.banner = "Usage: xenforo-thread-dl [url]"

  parser.on "-v", "--version", "Show version" do
    puts "version #{XenforoThreadDL.version}"
    exit
  end
  parser.on "-h", "--help", "Show help" do
    puts parser
    exit
  end
  parser.missing_option do |option_flag|
    STDERR.puts "ERROR: #{option_flag} is missing something."
    STDERR.puts ""
    STDERR.puts parser
    exit(1)
  end
  parser.invalid_option do |option_flag|
    STDERR.puts "ERROR: #{option_flag} is not a valid option."
    STDERR.puts parser
    exit(1)
  end
  parser.unknown_args do |unknown_args|
    thread_url = unknown_args.join(" ")
  end
end

xftdl = XenforoThreadDL::Downloader.new thread_url: thread_url

# Register handlers for manifest saving
at_exit { xftdl.save_manifest }
Signal::INT.trap do
  # Trap this signal so our at_exit runs
  exit
end

puts "Directory: #{xftdl.directory}"
downloads = xftdl.download
puts "Downloaded #{downloads} file(s)."
