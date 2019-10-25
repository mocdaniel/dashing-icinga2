require 'dashing'
require './lib/icinga2'

configure do
  set :auth_token, 'YOUR_AUTH_TOKEN'
  set :default_dashboard, 'icinga2'

  # allow iframes e.g. icingaweb2
  # https://github.com/Shopify/dashing/issues/199
  # thx Sandro Lang
  set :protection, :except => :frame_options

  helpers do
    def protected!
     # Put any authentication code you want in here.
     # This method is run before accessing any resource.
    end

    # Specify Icinga Web 2 URL
    # https://github.com/Shopify/dashing/issues/509
    def getIcingaWeb2Url()
      # read configuration and try to fetch the correct path
      icinga = Icinga2.new('config/icinga2.json') # fixed path

      if icinga.icingaweb2_url != nil
        return icinga.icingaweb2_url
      else
        return 'http://192.168.33.5/icingaweb2'
      end
    end

    def getTimeZone()
      # read configuration and try to fetch the correct path
      icinga = Icinga2.new('config/icinga2.json') # fixed path
      if icinga.time_zone != nil
        return icinga.time_zone
      else
        return "UTC"
      end
    end
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Sinatra::Application
