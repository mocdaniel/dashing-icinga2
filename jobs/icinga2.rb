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

SCHEDULER.every '10s', :first_in => 0 do |job|
  # run data provider
  icinga.run

  puts "App Info: " + icinga.app_data.to_s + " Version: " + icinga.version
  #puts "CIB Info: " + icinga.cib_data.to_s

  # meter widget
  # we'll update the patched meter widget with absolute values (set max dynamically)
  host_meter = icinga.host_count_problems.to_f
  host_meter_max = icinga.host_count_all
  service_meter = icinga.service_count_problems.to_f
  service_meter_max = icinga.service_count_all

  puts "Meter widget: Hosts " + host_meter.to_s + "/" + host_meter_max.to_s + " Services " + service_meter.to_s + "/" + service_meter_max.to_s

  # icinga stats
  icinga_stats = [
    {"label" => "Host checks/min", "value" => icinga.host_active_checks_1min},
    {"label" => "Service checks/min", "value" => icinga.service_active_checks_1min},
  ]

  wqStats, clusterStats = icinga.getIcingaStats()

  wqStats.each do |name, value|
    icinga_stats.push( { "label" => name, "value" => "%0.2f" % value } )
  end
  #clusterStats.each do |name, value|
  #  icinga_stats.push( { "label" => name, "value" => "%0.2f" % value } )
  #end

  puts "Stats: " + icinga_stats.to_s

  ### Events

  send_event('icinga-stats', {
   title: icinga.version,
   items: icinga_stats,
   moreinfo: "Avg latency: " + icinga.avg_latency.to_s + "s",
   color: 'blue' })

  #### Dougnuts
  send_event('doughnut-pie-hosts', {
    type: "doughnut",
    header: "Hosts",
    labels: [ "UP", "Down" ],
    datasets: [ icinga.host_count_up, icinga.host_count_problems_down],
  })

  send_event('doughnut-pie-services', {
    type: "doughnut",
    header: "Services",
    labels: [ "OK", "Warning", "Critical", "Unknown" ],
    datasets: [ icinga.service_count_ok, icinga.service_count_problems_warning, icinga.service_count_problems_critical, icinga.service_count_problems_unknown],
  })
  send_event('bar-chart-endpoints', {
    header: "Endpoints",
    labels: [ "Connected", "Not Connected" ],
    datasets: [ clusterStats["num_conn_endpoints"], clusterStats["num_not_conn_endpoints"]],
  })

  #### Bar Charts
  send_event('bar-chart-checks', {
    #type: "horizontalBar",
    type: "bar",
    header: "Active Checks",
    labels: [ "Hosts/min", "Services/min" ],
    datasets: [ icinga.host_active_checks_1min, icinga.service_active_checks_1min],
  })
  send_event('bar-chart-downtimes', {
    #type: "horizontalBar",
    type: "bar",
    header: "Downtimes",
    labels: [ "Hosts", "Services" ],
    datasets: [ icinga.host_count_in_downtime, icinga.service_count_in_downtime],
  })
  send_event('bar-chart-acks', {
    #type: "horizontalBar",
    type: "bar",
    header: "Acknowledgements",
    labels: [ "Hosts", "Services" ],
    datasets: [ icinga.host_count_acknowledged, icinga.service_count_acknowledged],
  })

#  send_event('icinga-host-meter', {
#   value: host_meter,
#   max:   host_meter_max,
#   moreinfo: "Total hosts: " + host_meter_max.to_s,
#   color: 'blue' })
#
#  send_event('icinga-service-meter', {
#   value: service_meter,
#   max:   service_meter_max,
#   moreinfo: "Total services: " + service_meter_max.to_s,
#   color: 'blue' })

  # handled stats
#  handled_stats = [
#    {"label" => "Acknowledgements", "color" => "blue"},
#    {"label" => "Hosts", "value" => icinga.host_count_acknowledged},
#    {"label" => "Services", "value" => icinga.service_count_acknowledged},
#    {"label" => "Downtimes", "color" => "blue"},
#    {"label" => "Hosts", "value" => icinga.host_count_in_downtime},
#    {"label" => "Services", "value" => icinga.service_count_in_downtime},
#  ]
#
#  send_event('handled-stats', {
#   items: handled_stats,
#   color: 'blue' })

  # problem services
  severity_stats = []
  icinga.service_problems_severity.each do |name, state|
    severity_stats.push({
      "label" => icinga.formatService(name),
      "color" => icinga.stateToColor(state.to_int, false),
      "state" => state.to_int
    })
  end

  order = [ 2,1,3 ]
  result = severity_stats.sort do |a, b|
    order.index(a['state']) <=> order.index(b['state'])
  end

  puts "Severity: " + result.to_s

  send_event('icinga-severity', {
   items: result,
   color: 'blue' })

  # Combined view of unhandled host problems (only if there are some)
  unhandled_host_problems = []

  if (icinga.host_count_problems_down > 0)
    unhandled_host_problems.push(
      { "color" => icinga.stateToColor(1, true), "value" => icinga.host_count_problems_down },
    )
  end

  send_event('icinga-host-problems', {
    items: unhandled_host_problems,
    moreinfo: "All Problems: " + icinga.host_count_problems_down.to_s
  })

  # Combined view of unhandled service problems (only if there are some)
  unhandled_service_problems = []

  if (icinga.service_count_problems_critical > 0)
    unhandled_service_problems.push(
      { "color" => icinga.stateToColor(2, false), "value" => icinga.service_count_problems_critical },
    )
  end
  if (icinga.service_count_problems_warning > 0)
    unhandled_service_problems.push(
      { "color" => icinga.stateToColor(1, false), "value" => icinga.service_count_problems_warning },
    )
  end
  if (icinga.service_count_problems_unknown > 0)
    unhandled_service_problems.push(
      { "color" => icinga.stateToColor(3, false), "value" => icinga.service_count_problems_unknown }
    )
  end

  send_event('icinga-service-problems', {
    items: unhandled_service_problems,
    moreinfo: "All Problems: " + (icinga.service_count_problems_critical + icinga.service_count_problems_warning + icinga.service_count_problems_unknown).to_s
  })
end

