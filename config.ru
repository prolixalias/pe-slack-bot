$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'dotenv'
Dotenv.load

require 'pe-slack-bot'
require 'web'

Thread.abort_on_exception = true

SlackRubyBot::Client.logger.level = Logger::WARN

Thread.new do
  begin
    PESlackBot::Bot.run
  rescue Exception => e
    STDERR.puts "ERROR: #{e}"
    STDERR.puts e.backtrace
    raise e
  end
end

run PESlackBot::Web
