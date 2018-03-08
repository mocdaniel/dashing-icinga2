# Dashing with Icinga 2

#### Table of Contents

1. [Introduction](#introduction)
2. [Support](#support)
3. [License](#license)
4. [Requirements](#requirements)
4. [Installation](#installation)
5. [Configuration](#configuration)
6. [Run](#run)
7. [Authors](#authors)
8. [Troubleshooting](#troubleshooting)
9. [Development](#development)

## Introduction

[Dashing](http://shopify.github.io/dashing/) is a Sinatra based framework
that lets you build beautiful dashboards.

You can put your important infrastructure stats and metrics on your office
dashboard. Data can be pulled with custom jobs or pushed via REST API. You can re-arrange
widgets via drag&drop. Possible integrations include [Icinga](https://www.icinga.com/), [Grafana](https://grafana.com/),
ticket systems such as [RT](https://bestpractical.com/request-tracker/) or [OTRS](https://www.otrs.com),
[sensors](https://shop.netways.de/), [weather](https://github.com/Shopify/dashing/wiki/Additional-Widgets),
[schedules](https://blog.netways.de/2013/06/21/netrp-netways-resource-planner/),
etc. -- literally anything which can be presented as counter or list.

### Icinga 2 Dashboard

The Icinga 2 dashboard is built on top of Dashing and uses the [Icinga 2 API](https://www.icinga.com/products/icinga-2/)
to visualize what's going on with your monitoring. It combines several popular widgets
and provides development instructions for your own implementation. The dashboard
also allows to embed the [Icinga Web 2](https://www.icinga.com/products/icinga-web-2/)
host and service problem lists as Iframe.

![Dashing Icinga 2](public/dashing_icinga2_overview.png "Dashing Icinga 2")

> **Note**:
>
> The Icinga 2 dashboard needs the `dashing` Ruby gem in order to
> use the dashboards, jobs and widgets provided by this project.

### Demo

A full demo is available inside the [standalone](https://github.com/icinga/icinga-vagrant) Icinga Vagrant box.

## Support

You are encouraged to use the existing jobs and dashboards and modify them for your own needs.
More development insights can be found in [this section](#development). If you need help with
development or want to sponsor a feature request, kindly get in touch at info@icinga.com

If you have any questions, please hop onto the [Icinga community channels](https://www.icinga.com/community/get-involved/).

## License

* Dashing is licensed under the [MIT license](https://github.com/Shopify/dashing/blob/master/MIT-LICENSE).
* Icinga specific jobs and dashboards are licensed under the GPLv2+ license.

## Requirements

* Ruby, Gems and Bundler
* Dashing Gem
* Icinga 2 (v2.8+) and the REST API

Supported browsers and clients:

* Linux, Unix, \*Pi
* Chrome, Firefox, Safari

Windows is [not supported](https://github.com/Icinga/dashing-icinga2/issues/47).

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

### Unix and macOS

On macOS [OpenSSL was deprecated](https://github.com/eventmachine/eventmachine/issues/602),
therefore you'll need to fix the eventmachine gem:

```
brew install openssl
bundle config build.eventmachine --with-cppflags=-I/usr/local/opt/openssl/include
bundle install --path binpaths
```

Note: Dashing is running inside thin server which by default uses epoll from within the eventmachine library.
This is not available on Unix based systems, you can safely ignore this warning:

```
warning: epoll is not supported on this platform
```

Proceed to the [configuration](#configuration) section.


## Configuration

### Icinga 2 API

The Icinga 2 API requires either basic authentication or client certificates.

Add a new ApiUser object to your Icinga 2 configuration. Choose the
path depending on your setup type. Keep in mind that synced ApiUser
objects expose the login information to other Icinga 2 instances.

```
vim /etc/icinga2/conf.d/api-users.conf

vim /etc/icinga2/zones.d/global-templates/api-users.conf
```

```
object ApiUser "dashing" {
  password = "icinga2ondashingr0xx"
  permissions = [ "status/query", "objects/query/*" ]
}
```

Set the [ApiUser permissions](https://www.icinga.com/docs/icinga2/latest/doc/12-icinga2-api/#permissions)
according to your needs. By default the Icinga 2 job fetches
data from the `/v1/status` and `/v1/objects` API endpoints, but does not require write
permissions. If you're extending the API queries on your own, keep in mind to add
proper permissions.

In case you want to use client certificates, set the `client_cn` attribute accordingly.

### Dashing Configuration

#### Configuration File

Copy the example configuration from `config/icinga2.json` into `config/icinga2.local.json`
and adjust the settings for the Icinga 2 API credentials in the `icinga2` section.

The `icingaweb2` section allows you to specify the Icinga Web 2 URL
for the iframe widgets. This is read on startup once.

```
cp config/icinga2.json config/icinga2.local.json
```

```
vim config/icinga2.local.json

{
  "icinga2": {
    "api": {
      "host": "localhost",
      "port": 5665,
      "user": "dashing",
      "password": "icinga2ondashingr0xx"
    }
  },
  "icingaweb2": {
    "url": "http://localhost/icingaweb2"
  }
}
```

If you prefer to use client certificates, set the `pki_path` attribute. The Icinga 2
job expects the certificate file names based on the local FQDN e.g. `pki/icinga2-master1.localdomain.crt`.
You can override this behaviour by specifying the `node_name` configuration option
explicitly.

```
{
  "icinga2": {
    "api": {
      "host": "localhost",
      "port": 5665,
      "user": "dashing",
      "pki_path": "pki/",
      "node_name": "icinga2-master1.localdomain"
    }
  },
  "icingaweb2": {
    "url": "http://localhost/icingaweb2"
  }
}
```

> **Note:**
>
> If both methods are configured, the Icinga 2 job prefers client certificates.

#### Environment Variables

If you prefer to configure the Icinga 2 settings in environment variables, you
can do so as well. This helps with containers or local development tests.

Variable                 | Description
-------------------------|-------------------------
ICINGA2\_API\_HOST       | **Required.** Host where the API is listening on.
ICINGA2\_API\_PORT       | **Required.** Port where the API is listening on.
ICINGA2\_API\_USERNAME   | **Optional.** Required for basic auth as username.
ICINGA2\_API\_PASSWORD   | **Optional.** Required for basic auth as password.
ICINGA2\_API\_CERT\_PATH | **Optional.** Client certificate path.
ICINGA2\_API\_NODENAME   | **Optional.** If client certificates do not match the host name, override it.
ICINGAWEB2\_URL          | **Optional.** Set the Icinga Web 2 Url. Defaults to `http://localhost/icingaweb2`.

> **Note**
>
> Environment variables always override local configuration.

Example:

```
ICINGA2_API_HOST=localhost ICINGA2_API_PORT=5665 ICINGA2_API_USERNAME=root ICINGA2_API_PASSWORD=icinga dashing start -p 8005
```

## Run

### Systemd Service

Install the provided Systemd service file from `tools/systemd`. It assumes
that the working directory is `/usr/share/dashing-icinga2` and the Dashing gem
is installed to `/usr/local/bin/dashing`. Adopt these paths for your own needs.

```
cp tools/systemd/dashing-icinga2.service /usr/lib/systemd/system/
systemctl daemon-reload
systemctl start dashing-icinga2.service
systemctl status dashing-icinga2.service
```

This is used inside the [Icinga Vagrant Box "icinga2x"](https://github.com/icinga/icinga-vagrant).

### Script

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

Or with environment variables:

```
ICINGA2_API_HOST=localhost ICINGA2_API_PORT=5665 ICINGA2_API_USERNAME=root ICINGA2_API_PASSWORD=icinga dashing start -p 8005
```

### Docker

You can run Dashing in Docker environment:

Build a container:

```
git clone https://github.com/Icinga/dashing-icinga2.git
cd dashing-icinga2
docker build -t dashing-icinga2:latest .
```

Customize configuration with environment variables:

```
export ICINGA2_API_HOST=icinga2.example.org
export ICINGA2_API_PASSWORD=secret
```

Run a docker container:

```
docker run -ti --rm -e ICINGA2_API_HOST -e ICINGA2_API_PASSWORD -p 8005:8005 dashing-icinga2:latest
```

Navigate to [http://localhost:8005](http://localhost:8005)


### Logrotate

You can install the provided logrotate script to rotate the Dashing log in `/usr/share/dashing-icinga2/log`.

```
cp tools/logrotate/dashing-icinga2 /etc/logrotate.d
```

## Authors

* [dnsmichi](https://github.com/dnsmichi)

Thanks to all contributors! :)

* [flourish86](https://github.com/flourish86) for the UX design and CSS tips.
* [marconett](https://github.com/marconett) for the [colorized and sorted problem list widget](https://github.com/Icinga/dashing-icinga2/pull/41).
* [tutabeier](https://github.com/tutabeier) for [environment variables](https://github.com/Icinga/dashing-icinga2/pull/35) inspiration instead of a local configuration file.
* [mcktr](https://github.com/mcktr) for helping out with [unhandled problems](https://github.com/Icinga/dashing-icinga2/pull/18).
* [tachtler](https://github.com/tachtler) for the [Systemd service and logrotate](https://github.com/Icinga/dashing-icinga2/pull/6) additions.
* [fugstrolch](https://github.com/fugstrolch) for the [Icinga Web 2 iframe integration](https://github.com/Icinga/dashing-icinga2/pull/4).
* [tobiasvdk](https://github.com/tobiasvdk) for check stats widget and suggestions.
* [bodsch](https://github.com/bodsch) for the [job rewrite and config file support](https://github.com/Icinga/dashing-icinga2/pull/3) inspiration, and [better error handling](https://github.com/Icinga/dashing-icinga2/pull/21).
* [spjmurray](https://github.com/spjmurray) for [styling and 1080p resolution](https://github.com/spjmurray/dashing-icinga2/tree/1080p).
* [micke2k](https://github.com/micke2k) for [proper time formatting](https://github.com/Icinga/dashing-icinga2/pull/2).
* [lazyfrosch](https://github.com/lazyfrosch) for ideas on [Dashing with Icinga](https://github.com/lazyfrosch/dashing-icinga).
* [roidelapliue](https://github.com/roidelapluie) for the [Icinga 1.x dashing script](https://github.com/roidelapluie/dashing-scripts).

## Troubleshooting

Please add these details when you are asking a question on the community channels.

### Required Information

* Dashing version (`gem list --local dashing`)
* Ruby version (`ruby -V`)
* Icinga 2 version (`icinga2 --version`)
* Version of this project (tarball name, download date, tag name or `git show -1`)
* Your own modifications to this project, if any

### Widgets are not updated

* Open your browser's development console and check for errors.
* Ensure that the job runner does not log any errors.
* Stop the dashing daemon and run it in foreground.

### Connection Errors

If the connection to the Icinga 2 API was interrupted, check for possible network issues.
The Icinga 2 daemon might have been reloaded at that time.

* Manually test the Icinga 2 API (check https://www.icinga.com/docs for the official documentation)
* Verify that the configuration file contains the correct API details
* Modify the `jobs/icinga2.rb` and add additional logging (use `puts` similar to existing examples)
* Run Dashing in foreground

### Misc Errors

* Port 8005 is not reachable. Ensure that the firewall rules are setup accordingly.
* Iframe is not working. Try [this solution](https://monitoring-portal.org/woltlab/index.php?thread/39888-icinga2-dashing-iframe-issue-resolved/)
and ensure that the `X-Frame-Options` variable is **not** set to `DENY`.

## Development

Fork the repository on GitHub, commit your changes and send a PR please :)

The Icinga 2 dashboard mainly depends on the following files:

* `dashboards/icinga2.erb`
* `jobs/icinga2.rb`
* `lib/icinga2.rb`
* `config/icinga2.json`

Additional changes are inside the widgets. `simplemon` and `simplelist` have been added. `meter` was modified to update the
maximum value at runtime. `list` was updated to highlight colors and change font sizes.

### Configuration

You can use environment variables to quickly set the required configuration settings:

```
ICINGA2_API_HOST=localhost ICINGA2_API_PORT=5665 ICINGA2_API_USERNAME=root ICINGA2_API_PASSWORD=icinga dashing start -p 8005
```

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
consists of an HTML list. It can be used as template where variables are
read from the `config.ru` file but that's for advanced usage.

Example:

```html
vim dashboards/icinga2.erb

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
vim jobs/icinga2.rb

  send_event('icinga-host-meter', {
   value: host_meter,
   max:   host_meter_max,
   moreinfo: "Total hosts: " + host_meter_max.to_s,
   color: 'blue' })
```

`icinga-host-meter` is the value of the `data-id` field in the `dashboards/icinga2.erb` file.

```
vim dashboards/icinga2.erb

    <li data-row="1" data-col="2" data-sizex="1" data-sizey="1">
      <div data-id="icinga-host-meter" data-view="Meter" data-title="Host Problems" data-min="0" data-max="100"></div>
    </li>
```

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
vim jobs/icinga2.rb

  icinga_stats = [
    {"label" => "Host checks/min", "value" => icinga.host_active_checks_1min},
    {"label" => "Service checks/min", "value" => icinga.service_active_checks_1min},
  ]
```

Use this array inside the `icinga-stats` event (`data-id` in the `dashboards/icinga2.erb` file)
as `items` attribute. You can add `moreinfo` which provides an additional legend for this widget.
`color` is optional.

```ruby
vim jobs/icinga2.rb

  send_event('icinga-stats', {
   title: icinga.version + " (" + icinga.version_revision + ")",
   items: icinga_stats,
   moreinfo: "Avg latency: " + icinga.avg_latency.to_s + "s",
   color: 'blue' })
```

#### Simplelist

Print problem counts by state as background color in a simple list.

Example:

```ruby
vim jobs/icinga2.rb

  # Combined view of unhandled host problems (only if there are some)
  unhandled_host_problems = []

  if (icinga.host_count_problems_down > 0)
    unhandled_host_problems.push(
      { "color" => icinga.stateToColor(1, true), "value" => icinga.host_count_problems_down },
    )
  end

  send_event('icinga-host-problems', {
    items: unhandled_host_problems,
    moreinfo: "All Problems: " + icinga.host_count_problems_down.to_s
  })
```

#### Simplemon

Print problem counts by state and coloring. Also add acknowledged objects and those
in downtime.

Example:

```ruby
vim jobs/icinga2.rb

send_event('icinga-service-critical', {
 value: icinga.service_count_critical.to_s,
 color: 'red' })
```

`icinga-service-critical` is the value of `data-id` field inside the `dashboards/icinga2.erb`
file. In order to update the widget you need to send a `value` and a `color` as hash values.

#### IFrame

You can edit `dashboards/icinga2.erb` to modify the iframe widget
for Icinga Web 2. Keep in mind that you keep the template function `<%=getIcingaWeb2Url()%>`
in order to read the Icinga Web 2 Host and URL from the configuration.

Example URL:

```
/icingaweb2/monitoring/list/services?service_problem=1&sort=service_severity&dir=desc
```

Add the fullscreen and compact options for those views.

```
&showFullscreen&showCompact
```

Example:

```html
    <!-- Icinga Web 2 iFrame. getIcingaWeb2Url() is defined in config.ru and reads from config/icinga2*.json -->
    <li data-row="3" data-col="1" data-sizex="2" data-sizey="2">
      <div data-id="iframe" data-view="Iframe" data-url="<%=getIcingaWeb2Url()%>/monitoring/list/hosts?host_problem=1&sort=host_severity&showFullscreen&showCompact"></div>
    </li>
    <li data-row="3" data-col="3" data-sizex="2" data-sizey="2">
      <div data-id="iframe" data-view="Iframe" data-url="<%=getIcingaWeb2Url()%>/monitoring/list/services?service_problem=1&sort=service_severity&dir=desc&showFullscreen&showCompact"></div>
    </li>
```

### References

https://www.icinga.com/2016/01/28/awesome-dashing-dashboards-with-icinga-2/
https://www.icinga.com/2016/12/22/merry-xmas-dashing-with-icinga-2-v1-1-0-is-here/
https://www.icinga.com/2017/07/13/dashing-for-icinga-2-v1-3-0-released/

https://www.antonissen.net/2017/02/19/monitoring-your-network-with-icinga-2-final-part-6/
https://community.spiceworks.com/how_to/147719-icinga2-dashing
https://linoxide.com/monitoring-2/setup-monitoring-dashing-icinga2/
http://brunner-it.de/2016/08/04/icinga2-dashing-installieren/
https://www.unixe.de/icinga2-dashing/
