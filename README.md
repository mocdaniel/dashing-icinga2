# Dashing with Icinga 2

#### Table of Contents

1. [Introduction](#introduction)
2. [Support](#support)
3. [License](#license)
4. [Requirements](#requirements)
4. [Installation](#installation)
5. [Configuration](#configuration)
6. [Run](#run)
7. [Thanks](#thanks)
8. [Troubleshooting](#troubleshooting)
9. [Development](#development)

## Introduction

[Dashing](http://shopify.github.io/dashing/) is a Sinatra based framework
that lets you build beautiful dashboards.

The Icinga 2 dashboard uses the Icinga 2 API to
visualize what's going on with your monitoring.

It combines several popular widgets and provides
development instructions for your own implementation.

The dashboard also allows to embed the Icinga Web 2 host and
service problem lists as iframe.

> **Note**:

> You still need to install the `dashing` gem in order to
> use the dashboards, jobs and widgets provided by this project.

![Dashing Icinga 2](public/dashing_icinga2_overview.png "Dashing Icinga 2")

### Demo

A demo is available inside the [Icinga Vagrant Box "icinga2x"](https://github.com/icinga/icinga-vagrant).

## Support

You are encouraged to use the existing jobs and dashboards and modify them for your own needs.
More development insights can be found in [this section](#development).

If you have any questions, please hop onto the [Icinga community channels](https://www.icinga.com/community/get-involved/).

## License

* Dashing is licensed under the [MIT license](https://github.com/Shopify/dashing/blob/master/MIT-LICENSE).
* Icinga specific jobs and dashboards are licensed under the GPLv2+ license.

## Requirements

* Ruby, Gems and Bundler
* Dashing Gem
* Icinga 2 (v2.6+) and the REST API

## Installation

Either clone this repository from GitHub or download the tarball.

Git clone:

```
cd /usr/share
git clone https://github.com/Icinga/dashing-icinga2.git
cd dashing-icinga2
```

Tarball download:

```
cd /usr/share
wget https://github.com/Icinga/dashing-icinga2/archive/master.zip
unzip master.zip
mv dashing-icinga2-master dashing-icinga2
cd dashing-icinga2
```


### Linux

RedHat/CentOS 7 (requires EPEL repository):

```
yum makecache
yum -y install epel-release
yum -y install rubygems rubygem-bundler ruby-devel openssl gcc-c++ make nodejs
```

Note: The development tools and header files are required for building the `eventmachine` gem.

Debian/Ubuntu:

```
apt-get update
apt-get -y install ruby bundler nodejs
```

Proceed with the `bundler` gem installation for all systems (CentOS, Debian, etc.).

```
gem install bundler
```

In case the installation takes quite long and you do not need any documentation,
add the `--no-document` flags.

Install the dependencies using Bundler.

```
cd /usr/share/dashing-icinga2
bundle
```

Proceed to the [configuration](#configuration) section.

### Unix and OSX

On OSX El Capitan [OpenSSL was deprecated](https://github.com/eventmachine/eventmachine/issues/602),
therefore you'll need to fix the eventmachine gem:

```
brew install openssl
bundle config build.eventmachine --with-cppflags=-I/usr/local/opt/openssl/include
bundle install --path binpaths
```

Note: Dashing is running as thin server which by default uses epoll from within the eventmachine library.
This is not available on unix-based systems, you can safely ignore this warning:

```
warning: epoll is not supported on this platform
```

Proceed to the [configuration](#configuration) section.


## Configuration

### Icinga 2 API

The Icinga 2 API requires either basic auth or client certificates for authentication.

Therefore add a new ApiUser object to your Icinga 2 configuration:

```
vim /etc/icinga2/conf.d/api-users.conf

object ApiUser "dashing" {
  password = "icinga2ondashingr0xx"
  permissions = [ "status/query", "objects/query/*" ]
}
```

Set the [ApiUser permissions](http://docs.icinga.com/icinga2/latest/doc/module/icinga2/chapter/icinga2-api#icinga2-api-permissions)
according to your needs. By default the Icinga 2 job will fetch
data from the `/v1/status` and `/v1/objects` endpoints, but does not require write
permissions. If you're extending the API queries on your own, keep in mind to add
proper permissions.

In case you want to use client certificates, set the `client_cn` accordingly.

### Dashing Configuration

Edit `config/icinga2.json` and adjust the settings for the Icinga 2 API credentials.

```
vim config/icinga2.json

{
  "icinga2": {
    "api": {
      "host": "localhost",
      "port": 5665,
      "user": "dashing",
      "password": "icinga2ondashingr0xx"
    }
  }
}
```

If you don't have any configuration file yet, the default values from the example above
will be used.

If you prefer to use client certificates, set `pki_path` accordingly. The Icinga 2
job expects the certificate file names based on the local FQDN e.g. `pki/icinga2-master1.localdomain.crt`.

Note: If both methods are configured, the Icinga 2 job prefers client certificates.

## Run

You can start dashing as daemon by using this script:

```
./restart-dashing
```

Additional options are available through `./restart-dashing -h`.

Navigate to [http://localhost:8005](http://localhost:8005)

### Foreground

You can run Dashing in foreground for tests and debugging too:

```
export PATH="/usr/local/bin:$PATH"
dashing start -p 8005
```

In addition to that you should think about an initscript/systemd service file too.


## Thanks

[fugstrolch](https://github.com/Icinga/dashing-icinga2/pull/4) for the Icinga Web 2 iframe integration.
[tobiasvdk](https://github.com/tobiasvdk) for check stats widget and suggestions.
[bodsch](https://github.com/Icinga/dashing-icinga2/pull/3) for the job rewrite and config file support inspiration.
[spjmurray](https://github.com/spjmurray/dashing-icinga2/tree/1080p) for styling and 1080p resolution.
[micke2k](https://github.com/Icinga/dashing-icinga2/pull/2) for proper time formatting.
[roidelapliue](https://github.com/roidelapluie/dashing-scripts) for the Icinga 1.x dashing script.

## Troubleshooting

### Required Information

* Dashing version (`gem list --local dashing`)
* Ruby version (`ruby -V`)
* Version of this project (tarball name, download date, tag name or `git show -1`)
* Your own modifications to this project, if any

### Widgets are not updated

* Open your browser's development console and check for errors.
* Ensure that the job runner does not log any errors.
* Stop the dashing daemon and run it in foreground.

### Connection Errors

If the connection to the Icinga 2 API was interrupted, check for possible network issues. The Icinga 2 daemon might have been reloaded at that time.

* Manually test the Icinga 2 API (check docs.icinga.com for the official documentation)
* Verify that the configuration file contains the correct API details
* Modify the `jobs/icinga2.rb` and add additional logging (use `puts` similar to existing examples)
* Run Dashing in foreground

### Misc Errors

* Port 8005 is not reachable. Ensure that the firewall rules are setup accordingly.
* Iframe is not working. Try [this solution](https://monitoring-portal.org/index.php?thread/39888-icinga2-dashing-iframe-issue-resolved/) and ensure that the `X-Frame-Options`
variable is not set to `DENY`.

## Development

Fork the repository on GitHub, commit your changes and send a PR please :)

The Icinga 2 dashboard mainly depends on the following files:

* dashboards/icinga2.erb
* jobs/icinga2.rb
* lib/icinga2.rb
* config/icinga2.json

Additional changes are inside the widgets. `simplemon` was added. `meter` was modified to update the
maximum value at runtime. `list` was updated to highlight colors and change font sizes.

### Icinga 2 Library

`lib/icinga2.rb` provides a class `icinga` which is responsible
for reading the configuration file, initializing the api connection
and fetching data.

Several public attributes are exposed by this class already. You'll
need to instantiate a new object and then call the `run` method.

Then you are able to access these attributes and public functions
such as `getHostobjects` and `getServiceObjects`. These two functions
can be called by passing

* attrs as an array of attribute strings
* filter as Icinga 2 API filter string
* joins as an array of joined objects and/or attributes

A simple test runner for testing own modifications has been added
into `test/icinga2.rb`. You can find additional examples over there as
well.

> **Note**
>
> These code parts may change. Keep this in mind on updates.


### Icinga 2 Job

Widgets are updated by calling `send_event` inside the `jobs/icinga2.rb` file
in the event scheduler.

The widget data is calculated from the `Icinga2` object class.

Include the Icinga 2 library:

```ruby
require './lib/icinga2'
```

Instantiate a new object called `icinga` from the `Icinga2` class. Add the
path to the configuration file.

```ruby
# initialize data provider
icinga = Icinga2.new('config/icinga2.json') # fixed path
```

Run the scheduler every five seconds and start it now.

```ruby
SCHEDULER.every '5s', :first_in => 0 do |job|
```

Then call the `run` method to fetch the current data into the `icinga` object

```ruby
# run data provider
icinga.run
```

Now you are able to access the exported object attributes and call available
object methods. Please check `libs/icinga2.rb` for specific options. If you
require more attributes and/or methods please send a PR!

### Icinga 2 Dashboard

The dashboard is located in the `dashboards/icinga2.erb` file and mostly
consists of an HTML list.

Example:

```html
<li data-row="1" data-col="1" data-sizex="1" data-sizey="1">
  <div data-id="icinga-host-meter" data-view="Meter" data-title="Host Problems" data-min="0" data-max="100" style="background-color: #0095bf;"></div>
</li>
```

The following attributes are important:

* `data-row` and `data-col` specify the location of the widget on screen.
* `data-sizex` and `data-sizey` specify the width and height of a widget by tiles.
* `data-view` defines the name of the widget to use
* `data-id` specifies the name of the data source for the used widget (important for `send_event` later)
* `data-title` defines the widget's title on top
* `data-min` and `data-max` are widget specific in this example. They are referenced inside the Coffee script file inside the widget code.
* `style` can be used to specify certain CSS to make the widget look more beautiful if not already.

### Dashboard Widgets

The widgets are located inside the `widgets` directory. Each widget consists of three files:

* `widget.html` defines the basic layout
* `widget.scss` specifies required styling
* `widget.coffee` implements the event handlng for the widget, e.g. `OnData` when `send_event` pushes new data.

#### Meter

This widget is used to display host and service problem counts. The maximum value is updated
at runtime too because of API-created objects.

Example:

```ruby
send_event('icinga-host-meter', {
 value: host_meter,
 max:   host_meter_max,
 moreinfo: "Total hosts: " + host_meter_max.to_s,
 color: 'blue' })
```

`icinga-host-meter` is the value of the `data-id` field in the `dashboards/icinga2.erb` file.
In order to update the widget you'll need to send a hash which contains the following keys
and values:

* `value` containing the current problem count
* `max` specifying the current object count
* `moreinfo` creating a string which is displayed below the meter as legend
* `color` for specifying the widget's color

#### List

Used to print the average checks per minute and list service problems by severity.

Example for check statistics:

Create a new array containing a hash for each table row. The `label` key is required,
`value` is optional.

```ruby
check_stats = [
  {"label" => "Host (active)", "value" => icinga.host_active_checks_1min},
  {"label" => "Service (active)", "value" => icinga.service_active_checks_1min},
]
```

Use this array inside the `icinga-checks` event (`data-id` in the `dashboards/icinga2.erb` file)
as `items` attribute. You can add `moreinfo` which provides an additional legend for this widget.
`color` is optional.

```ruby
send_event('icinga-checks', {
 items: check_stats,
 moreinfo: "Avg latency: " + icinga.avg_latency.to_s + "s",
 color: 'blue' })
```


#### Simplemon

Print problem counts by state and coloring. Also add acknowledged objects and those
in downtime.

Example:

```ruby
send_event('icinga-service-critical', {
 value: icinga.service_count_critical.to_s,
 color: 'red' })
```

`icinga-service-critical` is the value of `data-id` field inside the `dashboards/icinga2.erb`
file. In order to update the widget you need to send a `value` and a `color` as hash values.

#### IFrame

You can edit `dashboards/icinga2.erb` to modify the iframe widget
for Icinga Web 2.

Example URL:

```
http://192.168.33.5/icingaweb2/monitoring/list/services?service_problem=1&sort=service_severity&dir=desc
```

Add the fullscreen and compact options for those views.

```
&showFullscreen&showCompact
```

Example:

```html
<li data-row="4" data-col="1" data-sizex="2" data-sizey="2">
  <div data-id="iframe" data-view="Iframe" data-url="http://192.168.33.5/icingaweb2/monitoring/list/hosts?host_problem=1&sort=host_severity&showFullscreen&showCompact"></div>
</li>
```

### References

https://www.icinga.com/2016/01/28/awesome-dashing-dashboards-with-icinga-2/
https://gist.github.com/hussfelt/a6fe71ebd7cce327df29

### TODO

* Add ticket system demo (e.g. github.com/icinga/icinga2)
* Add Grafana dashboard
* Replace Dashing with [Smashing](https://github.com/SmashingDashboard/smashing)
