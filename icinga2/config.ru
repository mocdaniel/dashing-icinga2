require 'dashing'

configure do
  set :auth_token, 'YOUR_AUTH_TOKEN'
  set :default_dashboard, 'icinga2'

  # icinga2 api config
  set :icinga2_api_url, 'https://localhost:5665/v1'
  #set :icinga2_api_nodename, 'clientcertificatecommonname'
  #set :icinga2_api_username, 'dashing'
  #set :icinga2_api_password, 'icinga'

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
