module PESlackBot
  module Commands
    class Help < SlackRubyBot::Commands::Base
      command 'help' do |client, data, _match|
	help = "Why don't you try something like:
	  puppet status $certname
	  puppet job list <limit> <number>
	  puppet job show $showid
	  puppet app list
	  puppet job run <environment> <app> <noop>
	  "
	  
        client.say(channel: data.channel, text: help)
      end
    end
  end
end
