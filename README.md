# General

[Dashing](http://shopify.github.io/dashing/) is a Sinatra based framework
that lets you build beautiful dashboards.

This dashing implementation uses the Icinga 2 API
to show alerts on your dashboard.

![Dashing Icinga 2](public/dashing_icinga2_overview.png "Dashing Icinga 2")

# Demo

A demo is available inside the [Icinga Vagrant Boxes](https://github.com/icinga/icinga-vagrant).

# Support

**This is intended for demo purposes.** You may use the provided examples in your own implementation.

Please open issues at [dev.icinga.org](https://dev.icinga.org/projects/icinga-tools). In case
you've created a PR/patch, open a new issue linking to it as well please :)

If you have any questions, please hop onto the [Icinga community channels](https://www.icinga.org/community/get-help/).

# License

* Dashing is licensed under the [MIT license](https://github.com/Shopify/dashing/blob/master/MIT-LICENSE).
* Icinga specific jobs and dashboards are licensed under the GPLv2+ license.

# Requirements

* Ruby, Gems and Bundler
* Dashing Gem
* Icinga 2 API (v2.5+)

Gems:

    gem install bundler
    gem install dashing

In case the installation takes quite long and you do not need any documentation,
add the `--no-document` flags.

# Configuration

## Icinga 2

Icinga 2 provides either basic auth or client certificates for authentication.

Therefore add a new ApiUser object to your Icinga 2 configuration:

    vim /etc/icinga2/conf.d/api-users.conf

    object ApiUser "dashing" {
      password = "icinga2ondashingr0xx"
      permissions = [ "status/query", "objects/query/*" ]
    }

Set the [ApiUser permissions](http://docs.icinga.org/icinga2/latest/doc/module/icinga2/chapter/icinga2-api#icinga2-api-permissions)
according to your needs. By default we will only fetch
data from the `/v1/status` and `/v1/objects` endpoints, but do not require write
permissions.

In case you want to use client certificates, set the `client_cn` accordingly.

## Dashing Configuration

Edit `config/icinga2.json` and adjust the settings for the Icinga 2 API credentials.

    $ vim config/icinga2.json
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

If you don't have any configuration file yet, the default values from the example above
will be used.

If you prefer to use client certificates, set `pki_path` accordingly. The Icinga 2
job expects the certificate file names based on the local FQDN e.g. `pki/icinga2-master1.localdomain.crt`.

Note: If both methods are configured, the Icinga 2 job prefers client certificates.

# Run

## Linux

Install all required ruby gems into the system path.

    bundle install --system

Now start dashing:

    ./restart-dashing

Additional options are available through `./restart-dashing -h`.

Navigate to [http://localhost:8005](http://localhost:8005)

## Unix and OSX

On OSX El Capitan [OpenSSL was deprecated](https://github.com/eventmachine/eventmachine/issues/602),
therefore you'll need to fix the eventmachine gem:

    brew install openssl
    bundle config build.eventmachine --with-cppflags=-I/usr/local/opt/openssl/include
    bundle install --path binpaths

Note: Dashing is running as thin server which by default uses epoll from within the eventmachine library.
This is not available on unix-based systems, you can safely ignore this warning:

   warning: epoll is not supported on this platform

Now start dashing:

    ./restart-dashing

Additional options are available through `./restart-dashing -h`.

Navigate to [http://localhost:8005](http://localhost:8005)

# Thanks

[bodsch](https://github.com/Icinga/dashing-icinga2/pull/3) for the job rewrite and config file support.
[roidelapliue](https://github.com/roidelapluie/dashing-scripts) for the Icinga 1.x dashing script.

# Development

The Icinga 2 dashboard mainly depends on the following files:

* dashboards/icinga2.erb
* jobs/icinga2.rb
* lib/icinga2.rb
* config/icinga2.json

Additional changes are inside the widgets. `simplemon` was added. `meter` was modified to update the
maximum value at runtime.

## TODO

* Add ticket system demo (e.g. dev.icinga.org)
* Add Grafana dashboard
* Hints for Docker integration (docker-icinga2)
* Replace Dashing with [Smashing](https://github.com/SmashingDashboard/smashing)


