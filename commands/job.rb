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
          orch = Net::HTTP.new(host, 8143)
          orch.use_ssl = true
          orch.verify_mode = OpenSSL::SSL::VERIFY_NONE
          #do whatever orchestration voodoo
          case match[:verb]
            when 'list'
              attachments = Array.new
              request = Net::HTTP::Get.new("/orchestrator/v1/jobs?limit=5")
              request.add_field("X-Authentication", token)
              response = orch.request(request)
              jobs = JSON.parse(response.body)
              for job in jobs["items"] do
                case job['state']
                  when 'running'
                    color = '#4683A6'
                  when 'stopped'
                    color = '#FFD801'
                  when 'finished'
                    color = '#82C045'
                  when 'failed'
                    color = '#AD2927'
                  else
                    color = '#FFFFFF'
                  end
                  if job['options']['noop']=='true'
                    mode='in noop mode'
                  end
                  attachments.push(
                    fallback: "Job #{job['name']} #{job['state']} on #{job['timestamp']} in #{job['environment']['name']} by #{job['owner']['login']} #{mode}",
                    title: "Job #{job['name']} by #{job['owner']['login']}",
                    text: "#{job['state']} on #{job['timestamp']} in #{job['environment']['name']} #{mode}",
                    color: color
              )
                client.web_client.chat_postMessage(
                  channel: data.channel,
                  as_user: true,
                  attachments: attachments
              )
              end
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
