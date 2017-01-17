#/******************************************************************************
# * Icinga 2 Dashing Library Test                                                       *
# * Copyright (C) 2015-2017 Icinga Development Team (https://www.icinga.com)   *
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

# run data provider
icinga.run

########## tests begin
hostAttrs = [ "__name", "state" ]
hostFilter = "host.name == NodeName"
hostJoins = nil
hostObjs = icinga.getHostObjects(hostAttrs, hostFilter, hostJoins)

host_stats = []
hostObjs.each do |host|
  host_stats.push({ "label" => host["attrs"]["__name"], "value" => host["attrs"]["state"] })
end

puts "Host listing: " + host_stats.to_s

serviceAttrs = [ "__name", "state" ]
serviceFilter = "host.name == NodeName"
serviceJoins = [ "host.name", "host.state" ]
serviceObjs = icinga.getServiceObjects(serviceAttrs, serviceFilter, serviceJoins)

#puts "Host Objects: " + hostObjs.to_s
#puts "Service Object: " + serviceObjs.to_s

service_stats = []
serviceObjs.each do |service|
  service_stats.push({ "label" => icinga.formatService(service["attrs"]["__name"]), "value" => service["attrs"]["state"] })
end

puts "Service listing: " + service_stats.to_s

########## tests end

