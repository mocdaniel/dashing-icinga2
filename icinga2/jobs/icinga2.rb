require 'rest_client'

$node_name = "mbmif.int.netways.de"
$api_url_base = "https://localhost:5665/v1"

# prepare the rest client ssl stuff
def prepare_rest_client(api_url)
  cert_file = File.read("pki/" + $node_name + ".crt")
  key_file = File.read("pki/" + $node_name + ".key")
  ca_file = File.read("pki/ca.crt")

  cert = OpenSSL::X509::Certificate.new(cert_file)
  key = OpenSSL::PKey::RSA.new(key_file)

  options = {:ssl_client_cert => cert, :ssl_client_key => key, :ssl_ca_file => ca_file, :verify_ssl => OpenSSL::SSL::VERIFY_NONE}

  res = RestClient::Resource.new(
    URI.encode(api_url),
    options)
  return res
end

def get_stats()
  api_url = $api_url_base + "/status/CIB"
  rest_client = prepare_rest_client(api_url)
  headers = {"Content-Type" => "application/json", "Accept" => "application/json"}

  return rest_client.get(headers)
end



SCHEDULER.every '1s' do

  total_critical = 0
  total_warning = 0
  total_ack = 0
  total = 0

  res = get_stats()

  puts res
  #puts "Status: " + (JSON.pretty_generate JSON.parse(res))

  result = JSON.parse(res.body)
  puts result

  cib = result["results"][0]

  puts cib
  status = cib["status"]

  puts "Status: " + status.to_s

  services_ok = status["num_services_ok"]
  services_warning = status["num_services_warning"]
  services_critical = status["num_services_critical"]
  services_unknown = status["num_services_unknown"]

  hosts_up = status["num_hosts_up"]
  hosts_down = status["num_hosts_down"]

  total_critical = services_critical + hosts_down
  total_warning = services_warning

  if total_critical > 0 then
    color = 'red'
    value = total_critical.to_s
  elsif total_warning > 0 then
    color = 'yellow'
    value = total_warning.to_s
  else
    color = 'green'
    value = total.to_s
  end

  send_event('icinga-overview', {
   value: value,
   color: color })
end

