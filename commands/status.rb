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
	host = config['puppetdbhost']
	pdb = Net::HTTP.new(host, 8080)
	#pdb.use_ssl = true
	#pdb.verify_mode = OpenSSL::SSL::VERIFY_NONE
        #privkeyraw = File.read(config['hostprivkey'])
        #certraw = File.read(config['hostpubkey'])
	#pdb.cert = OpenSSL::X509::Certificate.new(certraw)
	#pdb.key = OpenSSL::PKey::RSA.new(privkeyraw)
	request = Net::HTTP::Get.new("/pdb/query/v4/nodes/#{match[:expression]}")
	response = pdb.request(request)
	if response.code == '200'
	  host = JSON.parse(response.body)
          report_timestamp = host['report_timestamp']
          latest_report_status = host['latest_report_status']
          latest_report_hash = host['latest_report_hash']
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
	else
	  client.say(channel: data.channel, text: "Node wasn't found in PuppetDB")
	end
      end
    end
  end
end
