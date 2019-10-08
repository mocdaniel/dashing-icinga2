#/******************************************************************************
# * Icinga 2 Dashing Job Library                                               *
# * Copyright (C) 2016-2017 Icinga Development Team (https://www.icinga.com)   *
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
  attr_reader :icingaweb2_url

  # general stats
  attr_reader :avg_latency
  attr_reader :avg_execution_time
  attr_reader :host_active_checks_1min
  attr_reader :host_passive_checks_1min
  attr_reader :service_active_checks_1min
  attr_reader :service_passive_checks_1min

  attr_reader :service_problems_severity

  # host stats
  attr_reader :host_count_all
  attr_reader :host_count_problems
  attr_reader :host_count_problems_down
  attr_reader :host_count_up
  attr_reader :host_count_down
  attr_reader :host_count_in_downtime
  attr_reader :host_count_acknowledged

  # service stats
  attr_reader :service_count_all
  attr_reader :service_count_problems
  attr_reader :service_count_problems_warning
  attr_reader :service_count_problems_critical
  attr_reader :service_count_problems_unknown
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

  def initialize(configFile)
    # add logger
    file = File.open('/tmp/dashing-icinga2.log', File::WRONLY | File::APPEND | File::CREAT)
    @log = Logger.new(file, 'daily', 1024000)
    @log.level = Logger::INFO
    @log.datetime_format = "%Y-%m-%d %H:%M:%S"
    @log.formatter = proc do |severity, datetime, progname, msg|
      "[#{datetime.strftime(@log.datetime_format)}] #{severity.ljust(5)} : #{msg}\n"
    end

    # get configuration settings
    begin
      puts "First trying to read environment variables"
      getConfEnv()
    rescue
      puts "Environment variables not found, falling back to configuration file " + configFile
      getConfFile(configFile)
    end

    @apiVersion = "v1" # TODO: allow user to configure version?
    @apiUrlBase = sprintf('https://%s:%d/%s', @host, @port, @apiVersion)

    @hasCert = false
    checkCert()

    @headers = {
      "Content-Type" => "application/json",
      "Accept" => "application/json"
    }
  end

  def getConfEnv()
    # prefer environment variables over the configuration file
    @host = ENV['ICINGA2_API_HOST']
    @port = ENV['ICINGA2_API_PORT']
    @user = ENV['ICINGA2_API_USERNAME']
    @password = ENV['ICINGA2_API_PASSWORD']
    @pkiPath = ENV['ICINGA2_API_CERT_PATH']
    @nodeName = ENV['ICINGA2_API_NODENAME']

    # external attribute
    @icingaweb2_url = ENV['ICINGAWEB2_URL']

    @showOnlyHardStateProblems = ENV['DASHBOARD_SHOW_ONLY_HARD_STATE_PROBLEMS']

    # check for the least required variables, the rest is read later on
    if [@host, @port].all? {|value| value.nil? or value == ""}
      raise ArgumentError.new('Required environment variables not found!')
    end

    puts "Using environment variable configuration on '" + @host + ":" + @port + "'."
  end

  def getConfFile(configFile)
    configFile = File.expand_path(configFile)
    @log.debug(sprintf( '  config file   : %s', configFile))

    # Allow to use 'icinga2.local.json' or any other '.local.json' defined in jobs
    configFileLocal = File.dirname(configFile) + "/" + File.basename(configFile,File.extname(configFile)) + ".local" + File.extname(configFile)

    puts "Detecting local config file '" + configFileLocal + "'."

    if (File.exist?(configFileLocal))
      realConfigFile = configFileLocal
    else
      realConfigFile = configFile
    end

    @log.info(sprintf('Using config file \'%s\'', realConfigFile))
    puts "Using config file '" + realConfigFile + "'."

    begin
      if (File.exist?(realConfigFile))
        file = File.read(realConfigFile)
        @config = JSON.parse(file)

        if @config.key? 'icinga2'
          config_icinga2 = @config['icinga2']

          if config_icinga2.key? 'api'
            @host = @config["icinga2"]["api"]["host"]
            @port = @config["icinga2"]["api"]["port"]
            @user = @config["icinga2"]["api"]["user"]
            @password = @config["icinga2"]["api"]["password"]
            @pkiPath = @config["icinga2"]["api"]["pki_path"]
            @nodeName = @config['icinga2']['api']['node_name']
            @showOnlyHardStateProblems = @config['dashboard']['show_only_hard_state_problems']
          end
        end

        puts "Reading config" + @config.to_s
        if @config.key? 'icingaweb2'
          # external attribute
          @icingaweb2_url = @config['icingaweb2']['url']
        end
      else
        @log.warn(sprintf('Config file %s not found! Using default config.', configFile))
        @host = "localhost"
        @port = 5665
        @user = "dashing"
        @password = "icinga2ondashingr0xx"
        @pkiPath = "pki/"
        @nodeName = nil
        @showOnlyHardStateProblems = false

        # external attribute
        @icingaweb2_url = 'http://localhost/icingaweb2'
      end

    rescue JSON::ParserError => e
      @log.error('wrong result (no json)')
      @log.error(e)
    end
  end

  def checkCert()
    unless @nodeName
      begin
        @nodeName = Socket.gethostbyname(Socket.gethostname).first
        @log.debug(sprintf('node name: %s', @nodeName))
      rescue SocketError => error
        @log.error(error)
      end
    end

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

  def getApiData(apiUrl, requestBody = nil)
    restClient = RestClient::Resource.new(URI.encode(apiUrl), @options)

    maxRetries = 30
    retried = 0

    begin
      if requestBody
        @headers["X-HTTP-Method-Override"] = "GET"
        payload = JSON.generate(requestBody)
        res = restClient.post(payload, @headers)
      else
        res = restClient.get(@headers)
      end
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e
      if (retried < maxRetries)
        retried += 1
        $stderr.puts(format("Cannot execute request against '%s': '%s' (retry %d / %d)", apiUrl, e, retried, maxRetries))
        sleep(2)
        retry
      else
        $stderr.puts("Maximum retries (%d) against '%s' reached. Giving up ...", maxRetries, apiUrl)
        return nil
      end
    end

    body = res.body
    data = JSON.parse(body)

    return data
  end

  def getIcingaApplicationData()
    apiUrl = sprintf('%s/status/IcingaApplication', @apiUrlBase)
    data = getApiData(apiUrl)

    if not data or not data.has_key?('results') or data['results'].empty? or not data['results'][0].has_key?('status')
      return nil
    end

    return data['results'][0]['status'] #there's only one row
  end

  def getCIBData()
    apiUrl = sprintf('%s/status/CIB', @apiUrlBase)
    data = getApiData(apiUrl)

    if not data or not data.has_key?('results') or data['results'].empty? or not data['results'][0].has_key?('status')
      return nil
    end

    return data['results'][0]['status'] #there's only one row
  end

  def getStatusData()
    apiUrl = sprintf('%s/status', @apiUrlBase)
    data = getApiData(apiUrl)

    if not data or not data.has_key?('results')
      return nil
    end

    return data['results']
  end

  def getHostObjects(attrs = nil, filter = nil, joins = nil)
    apiUrl = sprintf('%s/objects/hosts', @apiUrlBase)

    requestBody = {}

    if (attrs)
      requestBody["attrs"] = attrs
    end

    if (filter)
      requestBody["filter"] = filter
    end

    if (joins)
      requestBody["joins"] = joins
    end

    # fetch data with requestBody (which means X-HTTP-Method-Override: GET)
    data = getApiData(apiUrl, requestBody)

    if not data or not data.has_key?('results')
      return nil
    end

    return data['results']
  end

  def getServiceObjects(attrs = nil, filter = nil, joins = nil)
    apiUrl = sprintf('%s/objects/services', @apiUrlBase)

    requestBody = {}

    if (attrs)
      requestBody["attrs"] = attrs
    end

    if (filter)
      requestBody["filter"] = filter
    end

    tmpJoin = [ "host" ]

    if (joins)
      requestBody["joins"] = joins
    end

    #puts "request body: " + requestBody.to_s

    # fetch data with requestBody (which means X-HTTP-Method-Override: GET)
    data = getApiData(apiUrl, requestBody)

    if not data or not data.has_key?('results')
      return nil
    end

    return data['results']
  end

  def formatService(name)
    service_map = name.split('!', 2)
    return service_map[0].to_s + " - " + service_map[1].to_s
  end

  def stateFromString(stateStr)
    if (stateStr == "Down" or stateStr == "Warning")
      return 1
    elif (stateStr == "Up" or stateStr == "OK")
      return 0
    elif (stateStr == "Critical")
      return 2
    elif (stateStr == "Unknown")
      return 3
    end

    return "Undefined state. Programming error."
  end

  def stateToString(state, is_host = false)
    if (is_host && state >= 1)
      return "Down"
    elsif (is_host && state == 0)
      return "Up"
    elsif (state == 0)
      return "OK"
    elsif (state == 1)
      return "Warning"
    elsif (state == 2)
      return "Critical"
    elsif (state == 3)
      return "Unknown"
    end

    return "Undefined state. Programming error."
  end

  def stateToColor(state, is_host = false)
    if (is_host && state >= 1)
      return "red"
    elsif (is_host && state == 0)
      return "green"
    elsif (state == 0)
      return "green"
    elsif (state == 1)
      return "yellow"
    elsif (state == 2)
      return "red"
    elsif (state == 3)
      return "purple"
    end

    return "Undefined state. Programming error."
  end

  def countProblems(objects, states = nil)
    problems = 0

    compStates = []

    if not states
      compStates = [ 1, 2, 3]
    end

    if states.is_a?(Integer)
      compStates.push(states)
    end

    objects.each do |item|
      item.each do |k, d|
        if (k != "attrs")
          next
        end

        if @showOnlyHardStateProblems
          if (compStates.include?(d["state"]) && d["downtime_depth"] == 0 && d["acknowledgement"] == 0 && d['last_hard_state'] != 0.0)
            problems = problems + 1
          end
        else
          if (compStates.include?(d["state"]) && d["downtime_depth"] == 0 && d["acknowledgement"] == 0)
            problems = problems + 1
          end
        end
      end
    end

    return problems
  end

  # use last_check here, takes less traffic than the entire check result
  def getObjectHasBeenChecked(object)
    return object["attrs"]["last_check"] > 0
  end

  # stolen from Icinga Web 2, ./modules/monitoring/library/Monitoring/Backend/Ido/Query/ServicestatusQuery.php
  def getHostSeverity(host)
    attrs = host["attrs"]

    severity = 0

    if (attrs["state"] == 0)
      if (getObjectHasBeenChecked(host))
        severity += 16
      end

      if (attrs["acknowledgement"] != 0)
        severity += 2
      elsif (attrs["downtime_depth"] > 0)
        severity += 1
      else
        severity += 4
      end
    else
      if (getObjectHasBeenChecked(host))
        severity += 16
      elsif (attrs["state"] == 1)
        severity += 32
      elsif (attrs["state"] == 2)
        severity += 64
      else
        severity += 256
      end

      if (attrs["acknowledgement"] != 0)
        severity += 2
      elsif (attrs["downtime_depth"] > 0)
        severity += 1
      else
        severity += 4
      end
    end

    return severity
  end

  # stolen from Icinga Web 2, ./modules/monitoring/library/Monitoring/Backend/Ido/Query/ServicestatusQuery.php
  def getServiceSeverity(service)
    attrs = service["attrs"]

    severity = 0

    if (attrs["state"] == 0)
      if (getObjectHasBeenChecked(service))
        severity += 16
      end

      if (attrs["acknowledgement"] != 0)
        severity += 2
      elsif (attrs["downtime_depth"] > 0)
        severity += 1
      else
        severity += 4
      end
    else
      if (getObjectHasBeenChecked(service))
        severity += 16
      elsif (attrs["state"] == 1)
        severity += 32
      elsif (attrs["state"] == 2)
        severity += 128
      elsif (attrs["state"] == 3)
        severity += 64
      else
        severity += 256
      end

      # requires joins
      host_attrs = service["joins"]["host"]

      if (host_attrs["state"] > 0)
        severity += 1024
      elsif (attrs["acknowledgement"])
        severity += 512
      elsif (attrs["downtime_depth"] > 0)
        severity += 256
      else
        severity += 2048
      end
    end

    return severity
  end

  def getProblemServices(all_services_data, max_items = 20)
    service_problems = {}

    all_services_data.each do |service|
      #puts "Severity for " + service["name"] + ": " + getServiceSeverity(service).to_s
      if (service["attrs"]["state"] == 0) or
        (service["attrs"]["downtime_depth"] > 0) or
        (service["attrs"]["acknowledgement"] > 0)
        next
      end

      if @showOnlyHardStateProblems and (service["attrs"]["last_hard_state"] == 0.0)
        next
      end

      service_problems[service] = getServiceSeverity(service)
    end

    count = 0
    service_problems_severity = {}

    # debug
    #@service_problems.sort_by {|k, v| v}.reverse.each do |obj, severity|
    #  puts obj["name"] + ": " + severity.to_s
    #end

    service_problems.sort_by {|k, v| v}.reverse.each do |obj, severity|
      if (count >= max_items)
        break
      end

      name = obj["name"]
      service_problems_severity[name] = obj["attrs"]["state"]

      count += 1
    end

    return service_problems, service_problems_severity
  end

  def getWQStats()
    results = getStatusData()

    stats = {}

    results.each do |r|
      status = r["status"]

      keyList = [ "work_queue_item_rate", "query_queue_item_rate" ]

      # structure is "type" - "name"
      # api - json_rpc
      # idomysqlconnection - ido-mysql
      status.each do |type, typeval|
        if not typeval.is_a?(Hash)
          next
        end

        typeval.each do |attr, val|
          #puts attr + " " + val.to_s

          if not val.is_a?(Hash)
            next
          end

          keyList.each do |key|
            if val.has_key? key
              attrName = attr + " queue rate"
              stats[attrName] = val[key]
            end
          end

        end
      end
    end

    return stats
  end

  def fetchVersion(version)
    #version = "v2.4.10-504-gab4ba18"
    #version = "v2.4.10"
    version_map = version.split('-', 2)
    version_str = version_map[0]
    # strip v2.4.10 (default) and r2.4.10 (Debian)
    version_str = version_str.scan(/^[vr]?(.*)/).last.first

    if version_map.size() > 1
      @version_revision = version_map[1]
    else
      @version_revision = "release"
    end

    @version = version_str
  end

  def initializeAttributes()
    @version = "Not running"
    @version_revision = ""
    @node_name = ""
    @app_starttime = 0
    @uptime = 0

    @avg_latency = 0
    @avg_execution_time = 0
    @host_active_checks_1min = 0
    @host_passive_checks_1min = 0
    @service_active_checks_1min = 0
    @service_passive_checks_1min = 0

    @service_problems_severity = 0

    @host_count_all = 0
    @host_count_problems = 0
    @host_count_problems_down = 0
    @host_count_up = 0
    @host_count_down = 0
    @host_count_in_downtime = 0
    @host_count_acknowledged = 0

    @service_count_all = 0
    @service_count_problems = 0
    @service_count_problems_warning = 0
    @service_count_problems_critical = 0
    @service_count_problems_unknown = 0
    @service_count_ok = 0
    @service_count_warning = 0
    @service_count_critical = 0
    @service_count_unknown = 0
    @service_count_unknown = 0
    @service_count_in_downtime = 0
    @service_count_acknowledged = 0

    @app_data = nil
    @cib_data = nil
    @all_hosts_data = nil
    @all_services_data = nil
  end

  def run
    # initialize attributes to provide some semi-useful data
    initializeAttributes()

    ## App data
    @app_data = getIcingaApplicationData()

    unless(@app_data.nil?)
      fetchVersion(@app_data['icingaapplication']['app']['version'])
      @node_name = @app_data['icingaapplication']['app']['node_name']
      @app_starttime = Time.at(@app_data['icingaapplication']['app']['program_start'].to_f)
    end

    ## CIB data
    @cib_data = getCIBData() #exported

    unless(@cib_data.nil?)
      uptimeTmp = cib_data["uptime"].round(2)
      @uptime = Time.at(uptimeTmp).utc.strftime("%H:%M:%S")

      @avg_latency = cib_data["avg_latency"].round(2)
      @avg_execution_time = cib_data["avg_execution_time"].round(2)

      @host_count_up = cib_data["num_hosts_up"].to_int
      @host_count_down = cib_data["num_hosts_down"].to_int
      @host_count_in_downtime = cib_data["num_hosts_in_downtime"].to_int
      @host_count_acknowledged = cib_data["num_hosts_acknowledged"].to_int

      @service_count_ok = cib_data["num_services_ok"].to_int
      @service_count_warning = cib_data["num_services_warning"].to_int
      @service_count_critical = cib_data["num_services_critical"].to_int
      @service_count_unknown = cib_data["num_services_unknown"].to_int
      @service_count_in_downtime = cib_data["num_services_in_downtime"].to_int
      @service_count_acknowledged = cib_data["num_services_acknowledged"].to_int

      # check stats
      @host_active_checks_1min = cib_data["active_host_checks_1min"]
      @host_passive_checks_1min = cib_data["passive_host_checks_1min"]
      @service_active_checks_1min = cib_data["active_service_checks_1min"]
      @service_passive_checks_1min = cib_data["passive_service_checks_1min"]
    end

    ## Objects data
    # fetch the minimal attributes for problem calculation
    all_hosts_data = nil
    all_services_data = nil

    if @showOnlyHardStateProblems
      all_hosts_data = getHostObjects([ "name", "state", "acknowledgement", "downtime_depth", "last_check", "last_hard_state" ], nil, nil)
      all_services_data = getServiceObjects([ "name", "state", "acknowledgement", "downtime_depth", "last_check", "last_hard_state" ], nil, [ "host.name", "host.state", "host.acknowledgement", "host.downtime_depth", "host.last_check" ])
    else
      all_hosts_data = getHostObjects([ "name", "state", "acknowledgement", "downtime_depth", "last_check" ], nil, nil)
      all_services_data = getServiceObjects([ "name", "state", "acknowledgement", "downtime_depth", "last_check" ], nil, [ "host.name", "host.state", "host.acknowledgement", "host.downtime_depth", "host.last_check" ])
    end

    unless(all_hosts_data.nil?)
      @host_count_all = all_hosts_data.size
      @host_count_problems = countProblems(all_hosts_data)
      @host_count_problems_down = countProblems(all_hosts_data, 1)
    end

    unless(all_services_data.nil?)
      @service_count_all = all_services_data.size
      @service_count_problems = countProblems(all_services_data)
      @service_count_problems_warning = countProblems(all_services_data, 1)
      @service_count_problems_critical = countProblems(all_services_data, 2)
      @service_count_problems_unknown = countProblems(all_services_data, 3)

      # severity
      @service_problems, @service_problems_severity = getProblemServices(all_services_data)
    end

  end
end
