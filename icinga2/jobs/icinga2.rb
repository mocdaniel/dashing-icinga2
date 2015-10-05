require 'rest_client'

# TODO make this a global configuration
# TODO add basic auth support
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

def get_app()
  api_url = $api_url_base + "/status/IcingaApplication"
  rest_client = prepare_rest_client(api_url)
  headers = {"Content-Type" => "application/json", "Accept" => "application/json"}

  return rest_client.get(headers)
end


SCHEDULER.every '1s' do

  total_critical = 0
  total_warning = 0
  total_ack = 0
  total = 0

  app = get_app()
  result = JSON.parse(app.body)
  icingaapplication = result["results"][0] # there's only one row
  app_info = icingaapplication["status"]

  puts "App Info: " + app_info.to_s

  version = app_info["icingaapplication"]["app"]["version"]

  res = get_stats()
  result = JSON.parse(res.body)
  cib = result["results"][0] # there's only one row
  status = cib["status"]

  puts "Status: " + status.to_s

  uptime = status["uptime"].round(2)
  avg_latency = status["avg_latency"].round(2)
  avg_execution_time = status["avg_execution_time"].round(2)

  services_ok = status["num_services_ok"].to_int
  services_warning = status["num_services_warning"].to_int
  services_critical = status["num_services_critical"].to_int
  services_unknown = status["num_services_unknown"].to_int
  services_ack = status["num_services_acknowledged"].to_int
  services_downtime = status["num_services_in_downtime"].to_int

  hosts_up = status["num_hosts_up"].to_int
  hosts_down = status["num_hosts_down"].to_int
  hosts_ack = status["num_hosts_acknowledged"].to_int
  hosts_downtime = status["num_hosts_in_downtime"].to_int

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

  # events
  send_event('icinga-overview', {
   value: value,
   color: color })

  send_event('icinga-version', {
   value: version.to_s,
   color: 'blue' })

  send_event('icinga-uptime', {
   value: uptime.to_s + "s",
   color: 'blue' })

  send_event('icinga-latency', {
   value: avg_latency.to_s + "s",
   color: 'blue' })

  send_event('icinga-execution-time', {
   value: avg_execution_time.to_s + "s",
   color: 'blue' })

  # down, critical, warning
  send_event('icinga-host-down', {
   value: hosts_down.to_s,
   color: 'red' })

  send_event('icinga-service-critical', {
   value: services_critical.to_s,
   color: 'red' })

  send_event('icinga-service-warning', {
   value: services_warning.to_s,
   color: 'yellow' })

  # ack, downtime
  send_event('icinga-service-ack', {
   value: services_ack.to_s,
   color: 'blue' })

  send_event('icinga-host-ack', {
   value: hosts_ack.to_s,
   color: 'blue' })

  send_event('icinga-service-downtime', {
   value: services_downtime.to_s,
   color: 'orange' })

  send_event('icinga-host-downtime', {
   value: hosts_downtime.to_s,
   color: 'orange' })
end

