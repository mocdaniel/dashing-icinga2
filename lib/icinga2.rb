#
#
#

require 'json'
require 'rest-client'
require 'openssl'
require 'logger'
require 'time'

class Icinga2

  attr_reader :version
  attr_reader :node_name
  attr_reader :app_starttime

  attr_reader :uptime
  attr_reader :avg_latency
  attr_reader :avg_execution_time
  attr_reader :services_ok
  attr_reader :services_pending
  attr_reader :services_critical
  attr_reader :services_warning
  attr_reader :services_unknown
  attr_reader :services_unknown
  attr_reader :services_downtime

  attr_reader :hosts_up
  attr_reader :hosts_down
  attr_reader :hosts_ack
  attr_reader :hosts_downtime

  attr_reader :status_hosts

  attr_reader :total_critical
  attr_reader :total_warning

  attr_reader :fullAppData
  attr_reader :fullStatsData
  attr_reader :fullApiData

  def initialize( config_file )

    file = File.open( '/tmp/dashing-icinga2.log', File::WRONLY | File::APPEND | File::CREAT )
    @log = Logger.new( file, 'weekly', 1024000 )
#    @log = Logger.new( STDOUT )
    @log.level = Logger::INFO
    @log.datetime_format = "%Y-%m-%d %H:%M:%S"
    @log.formatter = proc do |severity, datetime, progname, msg|
      "[#{datetime.strftime(@log.datetime_format)}] #{severity.ljust(5)} : #{msg}\n"
    end

        @log.debug( sprintf( '  cfg   : %s', config_file ) )

    config_file = File.expand_path( config_file )

        @log.debug( sprintf( '  cfg   : %s', config_file ) )

    begin

      if( File.exist?( config_file ) )

        file    = File.read( config_file )
        @config = JSON.parse( file )

        @server_name  = @config["icinga2"]["server"]["name"]
        @server_port  = @config["icinga2"]["server"]["port"]
        @api_user     = @config["icinga2"]["api"]["user"]
        @api_pass     = @config["icinga2"]["api"]["password"]

        @api_url_base = sprintf( 'https://%s:%d', @server_name, @server_port )
#         @api_username = api_user.to_s
#         @api_password = api_pass.to_s
        @node_name    = Socket.gethostbyname( Socket.gethostname ).first

        @log.debug( sprintf( '  server   : %s', @server_name ) )
        @log.debug( sprintf( '  port     : %s', @server_port ) )
        @log.debug( sprintf( '  api url  : %s', @api_url_base ) )
        @log.debug( sprintf( '  api user : %s', @api_user ) )
        @log.debug( sprintf( '  api pass : %s', @api_pass ) )
        @log.debug( sprintf( '  node name: %s', @node_name ) )

      else
        @log.error( sprintf( 'Config File %s not found!', config_file ) )
        exit 1
      end

    rescue JSON::ParserError => e

      @log.error( 'wrong result (no json)')
      @log.error( e )
      exit 1
    end

    @hasCert = false

    checkCert()

    @headers     = { "Content-Type" => "application/json", "Accept" => "application/json" }
  end

  def checkCert()

    # check whether pki files are there, otherwise use basic auth
    if File.file?( sprintf( 'pki/%s.crt', @node_name ) )

      @log.debug( "PKI found, using client certificates for connection to Icinga 2 API" )

      cert_file = File.read( sprintf( 'pki/%s.crt', @node_name ) )
      key_file  = File.read( sprintf( 'pki/%s.key', @node_name ) )
      ca_file   = File.read( 'pki/ca.crt' )

      cert      = OpenSSL::X509::Certificate.new( cert_file )
      key       = OpenSSL::PKey::RSA.new( key_file )

      @options   = { :ssl_client_cert => cert, :ssl_client_key => key, :ssl_ca_file => ca_file, :verify_ssl => OpenSSL::SSL::VERIFY_NONE }

      @hasCert = true
    else

      @log.debug( "PKI not found, using basic auth for connection to Icinga 2 API" )

      @options = { :user => @api_user, :password => @api_pass, :verify_ssl => OpenSSL::SSL::VERIFY_NONE }

      @hasCert = false
    end

  end

  def applicationData()

    api_url     = sprintf( '%s/v1/status/IcingaApplication', @api_url_base )
    rest_client = RestClient::Resource.new( URI.encode( api_url ), @options )
    data        = JSON.parse( rest_client.get( @headers ).body )
    result      = data['results'][0]['status'] # there's only one row

    return result

  end

  def statsData()

    api_url     = sprintf( '%s/v1/status/CIB', @api_url_base )
    rest_client = RestClient::Resource.new( URI.encode( api_url ), @options )
    data        = JSON.parse( rest_client.get( @headers ).body )
    result      = data['results'][0]['status'] # there's only one row

    return result

  end

  def apiData()

    api_url     = sprintf( '%s/v1/status/ApiListener', @api_url_base )
    rest_client = RestClient::Resource.new( URI.encode( api_url ), @options )
    data        = JSON.parse( rest_client.get( @headers ).body )
    result      = data['results']

    return result

  end

  def statusHosts( hosts )

    latest          = []
    latest_counter  = 0
    latest_moreinfo = nil

    totals          = {
      "unhandled"   => 0,
      "unreachable" => 0,
      "down"        => 0,
      "ack"         => 0,
      "downtime"    => 0,
      "count"       => 0
    }


    hosts.each do |host|

      if( host['attrs'] )

        totals['count'] += 1
        problem = 0

        name         = host['attrs']['name']
        display_name = host['attrs']['display_name']
        state        = host['attrs']['last_check_result']['state'].to_i
        output       = host['attrs']['last_check_result']['output']
        state_changed = host['attrs']['last_state_change']

        if( state == 0 )
          state_msg   = 'Okay'
          state_class = 'icinga2-status-ok'
        elsif( state == 1 )
          state_msg   = 'WARNING'
          state_class = 'icinga2-status-warning'
          problem = 1
        elsif( state == 2 )
          state_msg   = 'CRITICAL'
          state_class = 'icinga2-status-critical'
          problem = 1
        else
          state_class = 'icinga2-status-unknown'
        end

        latest.push(
          { cols: [ { value: name,   class: 'icinga2-hostname' }, { value: state_msg,  class: state_class }, ] }
        )

        latest.push(
          { cols: [ { value: Time.at( state_changed ).utc.strftime('%H:%M:%S'), class: 'icinga-duration', colspan: 2 }, ]}
        )

        @log.debug( sprintf( '%-30s - %-30s - %s - %s', name, display_name, state, output ) )

      end

    end

#    @log.debug( JSON.pretty_generate( latest ) )
#     latest_moreinfo = latest_counter.to_s + " problems"
#     if latest_counter > 15
#       latest_moreinfo += " | " + (latest_counter - 15).to_s + " not listed"
#     end

    return {
      "totals"          => totals,
      "latest"          => latest,
      "latest_moreinfo" => latest_moreinfo
    }

  end


  def hostsChecks()

    api_url     = sprintf( '%s/v1/objects/hosts?filter=host.state!=0&attrs=name&attrs=display_name&attrs=last_check_result&attrs=last_state_change', @api_url_base )
    rest_client = RestClient::Resource.new( URI.encode( api_url ), @options )
    data        = JSON.parse( rest_client.get( @headers ).body )
    result      = data['results']

    return statusHosts( result )

  end

  def run

    total_critical = 0
    total_warning  = 0
    total_ack      = 0
    total          = 0

    @fullAppData        = applicationData()
    @fullStatsData      = statsData()
    @fullApiData        = apiData()

    @version            = @fullAppData['icingaapplication']["app"]["version"]
    @node_name          = @fullAppData['icingaapplication']['app']['node_name']
    @app_starttime      = @fullAppData['icingaapplication']['app']['program_start']

#     @log.debug( sprintf( "App Info: %s", app_info ) )
    @log.debug( sprintf( "  Node Name : %s", node_name ) )
    @log.debug( sprintf( "  Version   : %s", version ) )
#     @log.debug( sprintf( "Status  : %s", status ) )
#     @log.debug( sprintf( "API  : %s", @fullApiData ) )

    @uptime             = Time.at( @fullStatsData["uptime"].round(2) ).utc.strftime('%H:%M:%S')
    @avg_latency        = @fullStatsData["avg_latency"].round(2)
    @avg_execution_time = @fullStatsData["avg_execution_time"].round(2)

    @services_ok        = @fullStatsData["num_services_ok"].to_int
    @services_pending   = @fullStatsData["num_services_pending"].to_int
    @services_warning   = @fullStatsData["num_services_warning"].to_int
    @services_critical  = @fullStatsData["num_services_critical"].to_int
    @services_unknown   = @fullStatsData["num_services_unknown"].to_int
    @services_ack       = @fullStatsData["num_services_acknowledged"].to_int
    @services_downtime  = @fullStatsData["num_services_in_downtime"].to_int

    @hosts_up           = @fullStatsData["num_hosts_up"].to_int
    @hosts_down         = @fullStatsData["num_hosts_down"].to_int
    @hosts_ack          = @fullStatsData["num_hosts_acknowledged"].to_int
    @hosts_downtime     = @fullStatsData["num_hosts_in_downtime"].to_int

    @total_critical     = services_critical + hosts_down
    @total_warning      = services_warning


    @status_hosts       = hostsChecks()

  end

end

# EOF

#  i = Icinga2.new( '../config/icinga2.json' )
#
#  i.run
#
#  puts " ----------------------------- "
#
#  puts "uptime      : " + i.uptime.to_s
#  puts "services ok : " + i.services_ok.to_s
#  puts "hosts up    : " + i.hosts_up.to_s
#  puts "hosts down  : " + i.hosts_down.to_s

