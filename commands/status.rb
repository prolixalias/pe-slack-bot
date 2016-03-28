module PESlackBot
  module Commands
    class Status < SlackRubyBot::Commands::Base
      match(/^(?<bot>\w*)\sstatus\s(?<expression>.*)$/) do |client, data, match|
        if (Puppet.settings[:confdir]) then
          configfile = File.join([File.dirname(Puppet.settings[:confdir]), "peslackbot.yaml"])
        else
          configfile = "/etc/puppetlabs/puppet/peslackbot.yaml"
        end
        raise(ParseError, "PeSlackBot config file #{configfile} not readable") unless File.exist?(configfile)
        config = YAML.load_file(configfile)
        puppetdb = PuppetDB::Client.new({
          :server => "https://#{config['puppetdbhost']}:8081/pdb/query",
          :pem    => {
            'key'     => config['hostprivkey'],
            'cert'    => config['hostpubkey'],
            'ca_file' => config['cakey']
          }}, 4)
        response = puppetdb.request('nodes',['=', 'certname', match[:expression]])
        report_timestamp = response.data[0]['report_timestamp']
        latest_report_status = response.data[0]['latest_report_status']
        latest_report_hash = response.data[0]['latest_report_hash']
        case latest_report_status
          when 'changed'
            color = '#4683A6'
          when 'unchanged'
            color = '#82C045'
          when 'failed'
            color = '#AD2927'
          else
            color = '#FFFFFF'
          end
        #client.say(channel: data.channel, text: "Last run for node #{match[:expression]} was on #{report_timestamp}. Status was #{latest_report_status}. Report available in https://#{config['puppetdbhost']}/#/cm/report/#{latest_report_hash}/events")
        client.web_client.chat_postMessage(
          channel: data.channel,
          as_user: true,
          attachments: [
            {
              fallback: "Last run for node #{match[:expression]} was on #{report_timestamp}. Status was #{latest_report_status}. Report available in https://#{config['puppetdbhost']}/#/cm/report/#{latest_report_hash}/events",
              title: "#{match[:expression]} (#{latest_report_status})",
              text: "Last run for node #{match[:expression]} was on #{report_timestamp}. Status was #{latest_report_status}. Report available in https://#{config['puppetdbhost']}/#/cm/report/#{latest_report_hash}/events",
              color: color
            }
          ]
        )
      end
    end
  end
end
