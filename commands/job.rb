module PESlackBot
  module Commands
    class Job < SlackRubyBot::Commands::Base
      command 'job' do |client, data, _match|
        client.say(channel: data.channel, text: 'This will trigger an orchestrator job')
      end
    end
  end
end
