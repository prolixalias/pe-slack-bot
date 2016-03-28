module PESlackBot
  module Commands
    class Status < SlackRubyBot::Commands::Base
	match(/^status (?<node>\w*)\?$/i) do |client, data, match|
	response = puppetdb.request('nodes',['=', 'certname', match[:node]])
	client.say(channel: data.channel, text: "Last run for node #{match[:node]} was on #{response[:report_timestamp]}. Status was #{response[:latest_report_status]}. Report available <https://#{Puppet.settings[:ca_server]}/#/cm/report/#{response[:latest_report_hash]}/events|here>")
      end
    end
  end
end
