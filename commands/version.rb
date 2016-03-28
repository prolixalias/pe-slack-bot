module PESlackBot
  module Commands
    class Version < SlackRubyBot::Commands::Base
      command 'version' do |client, data, _match|
	version = Gem.loaded_specs['puppet'].version.to_s
        client.say(channel: data.channel, text: version)
      end
    end
  end
end
