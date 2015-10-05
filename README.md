# General

[Dashing](http://shopify.github.io/dashing/) is a Sinatra based framework
that lets you build beautiful dashboards.

This dashing implementation uses the Icinga 2 API
to show basic alerts on your dashboard.

# License

* Dashing is licensed under the [MIT license](https://github.com/Shopify/dashing/blob/master/MIT-LICENSE).
* Icinga specific jobs and dashboards are licensed under the GPLv2+ license.

# Requirements

* Ruby, Gems and Bundler
* Dashing Gem
* Icinga 2 API with client certificates

# Run

   cd icinga2
   bundle
   dashing start

Navigate to [http://localhost:3030](http://localhost:3030)

# Thanks

[roidelapliue](https://github.com/roidelapluie/dashing-scripts) for the Icinga 1.x dashing script.

# Dashing Installation

    sudo gem install dashing
    sudo gem install bundler

    dashing new icinga2
    cd icinga2
    bundle

    dashing start

## Widgets

    dashing generate widget table
    dashing generate widget showmon

## Jobs

    dashing generate job icinga2


