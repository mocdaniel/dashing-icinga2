
#/******************************************************************************
# * Icinga 2 Dashing Job                                                       *
# * Copyright (C) 2015-2016 Icinga Development Team (https://www.icinga.org)   *
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

require 'rest-client'

$node_name = Socket.gethostbyname(Socket.gethostname).first
if defined? settings.icinga2_api_nodename
  node_name = settings.icinga2_api_nodename
end
#$api_url_base = "https://192.168.33.5:5665"
$api_url_base = "https://localhost:5665"
if defined? settings.icinga2_api_url
  api_url_base = settings.icinga2_api_url
end
$api_username = "dashing"
if defined? settings.icinga2_api_username
  api_username = settings.icinga2_api_username
end
$api_password = "icinga2ondashingr0xx"
if defined? settings.icinga2_api_password
  api_password = settings.icinga2_api_password
end

# prepare the rest client ssl stuff
def prepare_rest_client(api_url)
  # check whether pki files are there, otherwise use basic auth
  if File.file?("pki/" + $node_name + ".crt")
    #puts "PKI found, using client certificates for connection to Icinga 2 API"
    cert_file = File.read("pki/" + $node_name + ".crt")
    key_file = File.read("pki/" + $node_name + ".key")
    ca_file = File.read("pki/ca.crt")

    cert = OpenSSL::X509::Certificate.new(cert_file)
    key = OpenSSL::PKey::RSA.new(key_file)

    options = {:ssl_client_cert => cert, :ssl_client_key => key, :ssl_ca_file => ca_file, :verify_ssl => OpenSSL::SSL::VERIFY_NONE}
  else
    #puts "PKI not found, using basic auth for connection to Icinga 2 API"

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

#TODO: move to lib, add filter/join params
def get_hosts()
  api_url = $api_url_base + "/v1/objects/hosts"
  rest_client = prepare_rest_client(api_url)
  headers = {"Content-Type" => "application/json", "Accept" => "application/json"}

  return rest_client.get(headers)
end

def get_services()
  api_url = $api_url_base + "/v1/objects/services"
  rest_client = prepare_rest_client(api_url)
  headers = {"Content-Type" => "application/json", "Accept" => "application/json"}

  return rest_client.get(headers)
end

def count_problems(object)
  problems = 0

  object.each do |item|
    item.each do |k, d|
      if (k != "attrs")
        next
      end

      #TODO remove once 2.5 has been released
      if not d.has_key?("downtime_depth")
        d["downtime_depth"] = 0
      end

      if (d["state"] != 0 && d["downtime_depth"] == 0 && d["acknowledgement"] == 0)
        problems = problems + 1
        #puts "Key: " + key.to_s + " State: " + d["state"].to_s
      end
    end
  end

  return problems
end

SCHEDULER.every '5s' do
  app = get_app()
  result = JSON.parse(app.body)
  icingaapplication = result["results"][0] # there's only one row
  app_info = icingaapplication["status"]

  puts "App Info: " + app_info.to_s

  ### General info

  version = app_info["icingaapplication"]["app"]["version"]

  #version = "v2.4.10-504-gab4ba18"
  #version = "v2.4.10"
  version_map = version.split('-', 2)
  version_str = version_map[0]
  # strip v2.4.10 (default) and r2.4.10 (Debian)
  version_str = version_str.scan(/^[vr]+(.*)/).last.first

  if version_map.size() > 1
    version_revision = version_map[1]
  else
    version_revision = "release"
  end

  start = Time.at(app_info["icingaapplication"]["app"]["program_start"].to_f)

  res = get_stats()
  result = JSON.parse(res.body)
  cib = result["results"][0] # there's only one row
  status = cib["status"]

  puts "Status: " + status.to_s

  uptime = status["uptime"].round(2)
  uptime = Time.at(uptime).utc.strftime("%H:%M:%S")
  avg_latency = status["avg_latency"].round(2)

  ### Hosts/Services
  host_objects_fetch = get_hosts()
  result = JSON.parse(host_objects_fetch.body)

  total_hosts = result["results"].size
  all_hosts = result["results"]
  total_problem_hosts = count_problems(all_hosts)

  hosts_up = status["num_hosts_up"].to_int
  hosts_down = status["num_hosts_down"].to_int
  hosts_ack = status["num_hosts_acknowledged"].to_int
  hosts_downtime = status["num_hosts_in_downtime"].to_int

  service_objects_fetch = get_services()
  result = JSON.parse(service_objects_fetch.body)

  total_services = result["results"].size
  all_services = result["results"]
  total_problem_services = count_problems(all_services)

  services_ok = status["num_services_ok"].to_int
  services_warning = status["num_services_warning"].to_int
  services_critical = status["num_services_critical"].to_int
  services_unknown = status["num_services_unknown"].to_int
  services_ack = status["num_services_acknowledged"].to_int
  services_downtime = status["num_services_in_downtime"].to_int

  # meter widget
  #host_meter = ((total_problem_hosts.to_f / total_hosts.to_f) * 100).round(2)
  # we'll update the patched meter widget with absolute values (set max dynamically)
  host_meter = total_problem_hosts.to_f
  host_meter_max = total_hosts

  #service_meter = ((total_problem_services.to_f / total_services.to_f) * 100).round(2)
  # we'll update the patched meter widget with absolute values (set max dynamically)
  service_meter = total_problem_services.to_f
  service_meter_max = total_services

  puts "Meter widget: Hosts " + host_meter.to_s + "/" + host_meter_max.to_s + " Services " + service_meter.to_s + "/" + service_meter_max.to_s

  ### Events
  send_event('icinga-version', {
   value: version_str,
   moreinfo: 'Revision: ' + version_revision
  })

  send_event('icinga-uptime', {
   value: uptime.to_s,
   moreinfo: start
  })

  send_event('icinga-latency', {
   value: avg_latency.to_s + "s",
   color: 'blue' })

  send_event('icinga-host-meter', {
   value: host_meter,
   max:   host_meter_max,
   moreinfo: "Total hosts: " + host_meter_max.to_s,
   color: 'blue' })

  send_event('icinga-service-meter', {
   value: service_meter,
   max:   service_meter_max,
   moreinfo: "Total services: " + service_meter_max.to_s,
   color: 'blue' })

  # down, critical, warning, unknown
  send_event('icinga-host-down', {
   value: hosts_down.to_s,
   color: 'red' })

  send_event('icinga-service-critical', {
   value: services_critical.to_s,
   color: 'red' })

  send_event('icinga-service-warning', {
   value: services_warning.to_s,
   color: 'yellow' })

  send_event('icinga-service-unknown', {
   value: services_unknown.to_s,
   color: 'purple' })

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

