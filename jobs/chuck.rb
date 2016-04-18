
# original from: https://gist.github.com/windowfinn/f8c35551138babcc3e9e

require 'net/http'
require 'json'
require 'cgi'

#The Internet Chuck Norris Database
server = "http://api.icndb.com"

#Id of the widget
id = "chuck"

#Proxy details if you need them - see below
proxy_host = 'XXXXXXX'
proxy_port = 8080
proxy_user = 'XXXXXXX'
proxy_pass = 'XXXXXXX'

SCHEDULER.every '3m', :first_in => 0 do |job|

    uri = URI("#{server}/jokes/random?limitTo=nerdy,explicit")

    #This is for when there is no proxy
    res = Net::HTTP.get(uri)

    #This is for when there is a proxy
    #res = Net::HTTP::Proxy(proxy_host, proxy_port, proxy_user, proxy_pass).get(uri)

    #marshal the json into an object
    j = JSON[res]

    #Get the joke
    joke = CGI.unescapeHTML(j['value']['joke'])

    #Send the joke to the text widget
    send_event(id, { title: "Chuck Norris Facts", text: joke })
end
