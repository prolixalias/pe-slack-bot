require 'slack-ruby-bot'
require 'puppet'
require 'puppetdb'
require '../pe-slack-bot/commands/calculate'
require '../pe-slack-bot/commands/version'
require '../pe-slack-bot/bot'

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
