require "net/https"
require "uri"
require "json"
tokenfile = "#{ENV['HOME']}/.puppetlabs/token"
if token=File.read(tokenfile)
  orch = Net::HTTP.new("master.inf.puppetlabs.demo", 8143)
  orch.use_ssl = true
  orch.verify_mode = OpenSSL::SSL::VERIFY_NONE
  request = Net::HTTP::Get.new("/orchestrator/v1/jobs?limit=5")
  request.add_field("X-Authentication", token)
  response = orch.request(request)
  jobs = JSON.parse(response.body)
  for job in jobs["items"] do
    print "ID: #{job['name']}\n"
    print "Timestamp: #{job['timestamp']}\n"
    print "Environment: #{job['environment']['name']}\n"
    print "Owner: #{job['owner']['login']}\n"
    print "State: #{job['state']}\n"
  end
else
  print "can't open file"
end
