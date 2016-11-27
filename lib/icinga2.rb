#/******************************************************************************
# * Icinga 2 Dashing Job Library                                               *
# * Copyright (C) 2016 Icinga Development Team (https://www.icinga.org)        *
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

require 'json'
require 'rest-client'
require 'openssl'
require 'logger'
require 'time'

class Icinga2
  # general info
  attr_reader :version
  attr_reader :version_revision
  attr_reader :node_name
  attr_reader :app_starttime
  attr_reader :uptime

  # general stats
  attr_reader :avg_latency
  attr_reader :avg_execution_time

  # host stats
  attr_reader :host_count_all
  attr_reader :host_count_problems
  attr_reader :host_count_up
  attr_reader :host_count_down
  attr_reader :host_count_in_downtime
  attr_reader :host_count_acknowledged

  # service stats
  attr_reader :service_count_all
  attr_reader :service_count_problems
  attr_reader :service_count_ok
  attr_reader :service_count_warning
  attr_reader :service_count_critical
  attr_reader :service_count_unknown
  attr_reader :service_count_in_downtime
  attr_reader :service_count_acknowledged

  # data providers
  attr_reader :app_data
  attr_reader :cib_data
  attr_reader :all_hosts_data
  attr_reader :all_services_data

  # internal
  @@log
  @@config
  @@host
  @@port
  @@user
  @@password
  @@pkiPath
  @@apiUrlBase
  @@apiVersion
  @@nodeName
  @@hasCert
  @@headers
  @@options


  def initialize(configFile)
    # add logger
    file = File.open('/tmp/dashing-icinga2.log', File::WRONLY | File::APPEND | File::CREAT)
    @log = Logger.new(file, 'weekly', 1024000)
    @log.level = Logger::DEBUG
    @log.datetime_format = "%Y-%m-%d %H:%M:%S"
    @log.formatter = proc do |severity, datetime, progname, msg|
      "[#{datetime.strftime(@log.datetime_format)}] #{severity.ljust(5)} : #{msg}\n"
    end

    # parse config
    @log.debug(sprintf( '  config file   : %s', configFile))
    configFile = File.expand_path(configFile)
    @log.debug(sprintf( '  config file   : %s', configFile))

    begin
      if (File.exist?(configFile))
        file = File.read(configFile)
        @config = JSON.parse(file)
        @host = @config["icinga2"]["api"]["host"]
        @port = @config["icinga2"]["api"]["port"]
        @user = @config["icinga2"]["api"]["user"]
        @password = @config["icinga2"]["api"]["password"]
        @pkiPath = @config["icinga2"]["api"]["pki_path"]
      else
        @log.warn(sprintf('Config file %s not found! Using default config.', configFile))
        @host = "localhost"
        @port = 5665
        @user = "dashing"
        @password = "icinga2ondashingr0xx"
        @pkiPath = "pki/"
      end

      @apiVersion = "v1" # TODO: allow user to configure version?

      @apiUrlBase = sprintf('https://%s:%d/%s', @host, @port, @apiVersion)

      @nodeName    = Socket.gethostbyname(Socket.gethostname).first

      @log.debug(sprintf('  host         : %s', @host))
      @log.debug(sprintf('  port         : %s', @port))
      @log.debug(sprintf('  api url      : %s', @apiUrlBase))
      @log.debug(sprintf('  api user     : %s', @user))
      @log.debug(sprintf('  api password : %s', 'XXXX'))
      @log.debug(sprintf('  node name    : %s', @nodeName))

    rescue JSON::ParserError => e
      @log.error('wrong result (no json)')
      @log.error(e)
    end

    @hasCert = false
    checkCert()

    @headers = {
      "Content-Type" => "application/json",
      "Accept" => "application/json"
    }
  end

  def checkCert()
    if File.file?(sprintf('%s/%s.crt', @pkiPath, @nodeName))
      @log.debug("PKI found, using client certificates for connection to Icinga 2 API")
      certFile = File.read(sprintf('%s/%s.crt', @pkiPath, @nodeName))
      keyFile = File.read(sprintf('%s/%s.key', @pkiPath, @nodeName))
      caFile = File.read(sprintf('%s/ca.crt', @pkiPath))

      cert = OpenSSL::X509::Certificate.new(certFile)
      key = OpenSSL::PKey::RSA.new(keyFile)

      @options = {
        :ssl_client_cert => cert,
        :ssl_client_key => key,
        :ssl_ca_file => caFile,
        :verify_ssl => OpenSSL::SSL::VERIFY_NONE # FIXME
      }

      @hasCert = true
    else
      @log.debug("PKI not found, using basic auth for connection to Icinga 2 API")

      @options = {
        :user => @user,
        :password => @password,
        :verify_ssl => OpenSSL::SSL::VERIFY_NONE # FIXME
      }

      @hasCert = false
    end
  end

  def getIcingaApplicationData()
    apiUrl = sprintf('%s/status/IcingaApplication', @apiUrlBase)
    restClient = RestClient::Resource.new(URI.encode(apiUrl), @options)
    data = JSON.parse(restClient.get(@headers).body)
    result = data['results'][0]['status'] #there's only one row

    return result
  end

  def getCIBData()
    apiUrl = sprintf('%s/status/CIB', @apiUrlBase)
    restClient = RestClient::Resource.new(URI.encode(apiUrl), @options)
    data = JSON.parse(restClient.get(@headers).body)
    result = data['results'][0]['status'] #there's only one row

    return result
  end

  def getHostObjects(attrs = nil, filter = nil, joins = nil)
    apiUrl = sprintf('%s/objects/hosts', @apiUrlBase)
    # TODO change to X-HTTP-Method-Override: GET in @headers, use POST and send filters, joins, attrs in request bondy
    restClient = RestClient::Resource.new(URI.encode(apiUrl), @options)
    data = JSON.parse(restClient.get(@headers).body)
    result = data['results']

    return result
  end

  def getServiceObjects(attrs = nil, filter = nil, joins = nil)
    apiUrl = sprintf('%s/objects/services', @apiUrlBase)
    # TODO change to X-HTTP-Method-Override: GET in @headers, use POST and send filters, joins, attrs in request bondy
    restClient = RestClient::Resource.new(URI.encode(apiUrl), @options)
    data = JSON.parse(restClient.get(@headers).body)
    result = data['results']

    return result
  end

  def countProblems(objects)
    problems = 0

    objects.each do |item|
      item.each do |k, d|
        if (k != "attrs")
          next
        end

        if (d["state"] != 0 && d["downtime_depth"] == 0 && d["acknowledgement"] == 0)
          problems = problems + 1
        end
      end
    end

    return problems
  end

  def fetchVersion(version)
    #version = "v2.4.10-504-gab4ba18"
    #version = "v2.4.10"
    version_map = version.split('-', 2)
    version_str = version_map[0]
    # strip v2.4.10 (default) and r2.4.10 (Debian)
    version_str = version_str.scan(/^[vr]+(.*)/).last.first

    if version_map.size() > 1
      @version_revision = version_map[1]
    else
      @version_revision = "release"
    end

    @version = version_str
  end

  def run
    @app_data = getIcingaApplicationData() #exported
    fetchVersion(@app_data['icingaapplication']['app']['version'])
    @node_name = @app_data['icingaapplication']['app']['node_name']
    @app_starttime = Time.at(@app_data['icingaapplication']['app']['program_start'].to_f)

    @all_hosts_data = getHostObjects() #exported
    @all_services_data = getServiceObjects() #exported
    @cib_data = getCIBData() #exported

    uptimeTmp = cib_data["uptime"].round(2)
    @uptime = Time.at(uptimeTmp).utc.strftime("%H:%M:%S")

    @avg_latency = cib_data["avg_latency"].round(2)
    @avg_execution_time = cib_data["avg_execution_time"].round(2)

    @host_count_all = all_hosts_data.size
    @host_count_problems = countProblems(all_hosts_data)
    @host_count_up = cib_data["num_hosts_up"].to_int
    @host_count_down = cib_data["num_hosts_down"].to_int
    @host_count_in_downtime = cib_data["num_hosts_in_downtime"].to_int
    @host_count_acknowledged = cib_data["num_hosts_acknowledged"].to_int

    @service_count_all = all_services_data.size
    @service_count_problems = countProblems(all_services_data)
    @service_count_ok = cib_data["num_services_ok"].to_int
    @service_count_warning = cib_data["num_services_warning"].to_int
    @service_count_critical = cib_data["num_services_critical"].to_int
    @service_count_unknown = cib_data["num_services_unknown"].to_int
    @service_count_in_downtime = cib_data["num_services_in_downtime"].to_int
    @service_count_acknowledged = cib_data["num_services_acknowledged"].to_int

  end
end
