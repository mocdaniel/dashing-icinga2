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

require './lib/icinga2'

# initialize data provider
icinga = Icinga2.new('config/icinga2.json') # fixed path

SCHEDULER.every '5s', :first_in => 0 do |job|
  # run data provider
  icinga.run

  puts "App Info: " + icinga.app_data.to_s
  puts "CIB Info: " + icinga.cib_data.to_s

  # meter widget
  # we'll update the patched meter widget with absolute values (set max dynamically)
  host_meter = icinga.host_count_problems.to_f
  host_meter_max = icinga.host_count_all
  service_meter = icinga.service_count_problems.to_f
  service_meter_max = icinga.service_count_all

  puts "Meter widget: Hosts " + host_meter.to_s + "/" + host_meter_max.to_s + " Services " + service_meter.to_s + "/" + service_meter_max.to_s

  # calculate host problems adjusted by handled problems
  # count togther handled host problems
  host_handled_problems = icinga.host_count_handled_warning_problems + icinga.host_count_handled_critical_problems + icinga.host_count_handled_unknown_problems
  host_down_adjusted = icinga.host_count_down - host_handled_problems

  # calculate service problems adjusted by handled problems
  service_warning_adjusted = icinga.service_count_warning - icinga.service_count_handled_warning_problems
  service_critical_adjusted = icinga.service_count_critical - icinga.service_count_handled_critical_problems
  service_unknown_adjusted = icinga.service_count_unknown - icinga.service_count_handled_unknown_problems

  # check stats
  check_stats = [
    {"label" => "Host (active)", "value" => icinga.host_active_checks_1min},
    #{"label" => "Host (passive)", "value" => icinga.host_passive_checks_1min},
    {"label" => "Service (active)", "value" => icinga.service_active_checks_1min},
    #{"label" => "Service (passive)", "value" => icinga.service_passive_checks_1min},
  ]
  puts "Checks: " + check_stats.to_s

  # severity list
  severity_stats = []
  icinga.service_problems_severity.each do |name, state|
    #severity_stats.push({ "label" => icinga.formatService(name), "color" => icinga.stateToColor(state.to_int, false)})
    severity_stats.push({ "label" => icinga.formatService(name) })
  end
  puts "Severity: " + severity_stats.to_s

  ### Events
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

  send_event('icinga-checks', {
   items: check_stats,
   moreinfo: "Avg latency: " + icinga.avg_latency.to_s + "s",
   color: 'blue' })

  send_event('icinga-severity', {
   items: severity_stats,
   color: 'blue' })

  # down, critical, warning, unknown
  send_event('icinga-host-down', {
   value: host_down_adjusted.to_s,
   color: 'red' })

  send_event('icinga-service-critical', {
   value: service_critical_adjusted.to_s,
   color: 'red' })

  send_event('icinga-service-warning', {
   value: service_warning_adjusted.to_s,
   color: 'yellow' })

  send_event('icinga-service-unknown', {
   value: service_unknown_adjusted.to_s,
   color: 'purple' })

  # ack, downtime
  send_event('icinga-service-ack', {
   value: icinga.service_count_acknowledged.to_s,
   color: 'blue' })

  send_event('icinga-host-ack', {
   value: icinga.host_count_acknowledged.to_s,
   color: 'blue' })

  send_event('icinga-service-downtime', {
   value: icinga.service_count_in_downtime.to_s,
   color: 'orange' })

  send_event('icinga-host-downtime', {
   value: icinga.host_count_in_downtime.to_s,
   color: 'orange' })
end

