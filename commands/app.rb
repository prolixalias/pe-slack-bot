module PESlackBot
  module Commands
    class App < SlackRubyBot::Commands::Base
      command 'app' do |client, data, _match|
        client.say(channel: data.channel, text: 'This will show an orchestrator app')
      end
    end
  end
end
