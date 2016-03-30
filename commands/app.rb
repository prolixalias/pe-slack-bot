module PESlackBot
  module Commands
    class App < SlackRubyBot::Commands::Base
      match(/^(?<bot>\w*)\sapp\s(?<verb>\w*)$/) do |client, data, match|
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
          case match[:verb]
            when 'show'
              request = Net::HTTP::Get.new("/orchestrator/v1/environments/production/instances")
              request.add_field("X-Authentication", token)
              response = orch.request(request)
              instances = JSON.parse(response.body)
              arguments = Array.new
              for instance in instances["items"]
                components = Array.new
                for component in instance["components"]
                  components.push("*Title*:_#{component['title']}_\n*Type*:_#{component['type']}_\n*Produces*:_#{component['produces']}_\n*Consumes*:_#{component['consumes']}_\n*Nodes*:_#{component['node']}_\n")
                end
              arguments.push(
                fallback: "#{instance['type']}['#{instance['title']}']",
                title: "#{instance['type']}['#{instance['title']}']",
                text: components.join,
                color: '#36A64F',
                mrkdwn_in: ["text", "pretext"],
              )
              end
            client.web_client.chat_postMessage(
              channel: data.channel,
              as_user: true,
              attachments: arguments,
            )
          else
            client.say(channel: data.channel, text: "Argument Missing. Try running puppet app show")
          end
        else
          client.say(channel: data.channel, text: "I don't have credentials to access the orchestration service")
        end
      end
    end
  end
end
