

require './lib/icinga2'

icinga = Icinga2.new( 'config/icinga2.json' )

SCHEDULER.every '3m' do

  icinga.run

  send_event( 'icinga-uptime', {
    value: icinga.uptime,
    color: 'blue' }
  )

  send_event( 'icinga-version', {
    value: icinga.version,
    color: 'blue' }
  )

  send_event( 'icinga-hosts-latest', {
    rows:     icinga.status_hosts["latest"],
    moreinfo: icinga.status_hosts["latest_moreinfo"]
  })

  # icinga-hosts-latest


  puts " ----------------------------- "

  puts "uptime      : " + icinga.uptime.to_s
  puts "services ok : " + icinga.services_ok.to_s
  puts "hosts up    : " + icinga.hosts_up.to_s
  puts "hosts down  : " + icinga.hosts_down.to_s

  puts " ----------------------------- "

end

