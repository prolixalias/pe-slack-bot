module PESlackBot
  module Commands
    class Job < SlackRubyBot::Commands::Base
      match(/^(?<bot>\w*)\sjob\s(?<verb>\w*)(\s|$)(?<noun>\w*)(\s|$)(?<argument>\w*)(\s|$)(?<mode>\w*)$/) do |client, data, match|
        if (Puppet.settings[:confdir]) then
          configfile = File.join([File.dirname(Puppet.settings[:confdir]), "peslackbot.yaml"])
        else
          configfile = "/etc/puppetlabs/puppet/peslackbot.yaml"
        end
        raise(ParseError, "PeSlackBot config file #{configfile} not readable") unless File.exist?(configfile)
        config = YAML.load_file(configfile)
        host = config['puppetdbhost']
        tokenfile = "#{ENV['HOME']}/.puppetlabs/token"
        raise(ParseError, "No orchestrator token found on #{tokenfile}") unless File.exist?(tokenfile)
        if token=File.read(tokenfile)
          #do whatever orchestration voodoo
          case match[:verb]
            when 'list'
              client.web_client.chat_postMessage(
                channel: data.channel,
                as_user: true,
                attachments: [
                  {
                  fallback: "List couldn't be displayed",
                  title: "Job 1 by Joe",
                  text: "completed on production on timestamp",
                  color: '#82C045',
                  },
                  {
                  fallback: "List couldn't be displayed",
                  title: "Job 2 by Joe",
                  text: "failed on production on timestamp",
                  color: '#AD2927',
                  },
                ]
              )
              #list jobs
            when 'run'
              #run a particular job. Requires at least environment as noun and an optional application as argument and noop flag as mode 
            when 'show'
              #show the status of a particular job, list nodes, their status(es) and shit
          else
            client.say(channel: data.channel, text: "Can't say I know how to do that")
          end
        else
          client.say(channel: data.channel, text: "I don't have credentials to access the orchestration service")
        end
      end
    end
  end
end
