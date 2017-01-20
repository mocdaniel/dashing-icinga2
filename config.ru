require 'dashing'

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
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Sinatra::Application
