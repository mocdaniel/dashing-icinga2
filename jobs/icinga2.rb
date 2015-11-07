
#/******************************************************************************
# * Icinga 2 Dashing Job                                                       *
# * Copyright (C) 2015 Icinga Development Team (https://www.icinga.org)        *
# *                                                                            *
# * This program is free software; you can redistribute it and/or              *
# * modify it under the terms of the GNU General Public License                *
# * as published by the Free Software Foundation; either version 2             *
# * of the License, or (at your option) any later version.                     *
# *                                                                            *
# * This program is distributed in the hope that it will be useful,            *
# * but WITHOUT ANY WARRANTY; without even the implied warranty of             *
# * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              *
# * GNU General Public License for more details.                               *
# *                                                                            *
# * You should have received a copy of the GNU General Public License          *
# * along with this program; if not, write to the Free Software Foundation     *
# * Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.             *
# ******************************************************************************/

require 'rest_client'

$node_name = Socket.gethostbyname(Socket.gethostname).first
if defined? settings.icinga2_api_nodename
  node_name = settings.icinga2_api_nodename
end
#$api_url_base = "https://192.168.99.100:4665"
$api_url_base = "https://localhost:5665"
if defined? settings.icinga2_api_url
  api_url_base = settings.icinga2_api_url
end
$api_username = "root"
if defined? settings.icinga2_api_username
  api_username = settings.icinga2_api_username
end
$api_password = "icinga"
if defined? settings.icinga2_api_password
  api_password = settings.icinga2_api_password
end

# prepare the rest client ssl stuff
def prepare_rest_client(api_url)
  # check whether pki files are there, otherwise use basic auth
  if File.file?("pki/" + $node_name + ".crt")
    puts "PKI found, using client certificates for connection to Icinga 2 API"
    cert_file = File.read("pki/" + $node_name + ".crt")
    key_file = File.read("pki/" + $node_name + ".key")
    ca_file = File.read("pki/ca.crt")

    cert = OpenSSL::X509::Certificate.new(cert_file)
    key = OpenSSL::PKey::RSA.new(key_file)

    options = {:ssl_client_cert => cert, :ssl_client_key => key, :ssl_ca_file => ca_file, :verify_ssl => OpenSSL::SSL::VERIFY_NONE}
  else
    puts "PKI not found, using basic auth for connection to Icinga 2 API"

    options = { :user => $api_username, :password => $api_password, :verify_ssl => OpenSSL::SSL::VERIFY_NONE }
  end

  res = RestClient::Resource.new(URI.encode(api_url), options)
  return res
end

def get_stats()
  api_url = $api_url_base + "/v1/status/CIB"
  rest_client = prepare_rest_client(api_url)
  headers = {"Content-Type" => "application/json", "Accept" => "application/json"}

  return rest_client.get(headers)
end

def get_app()
  api_url = $api_url_base + "/v1/status/IcingaApplication"
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

