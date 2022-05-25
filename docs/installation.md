# Installation

## Centos7

1. Update your system and install needed dependencies, including **Ruby v2.3** for the targeted Bundler version:

```
$ yum update
$ yum groupinstall "Development Tools"
$ yum makecache
$ yum install epel-release centos-release-scl-rh
$ yum install nodejs rh-ruby23-ruby rh-ruby23-ruby-devel rh-ruby23-rubygems rh-ruby23-rubygem-bundler
```

2. Configure dynamic linking for runtime bindings:

```
$ echo '/opt/rh/rh-ruby23/root/usr/lib64' > /etc/ld.so.conf.d/rh-ruby.conf
$ ldconfig
```

3. Add `ruby` and `gem` to path temporarily and install `bundler`:

```
$ export PATH="/opt/rh/rh-ruby23/root/bin:$PATH"
$ gem install bundler
```

4. Add `ruby`, `gem` and `bundle` to PATH permanently:

```
update-alternatives --install /usr/bin/ruby ruby /opt/rh/rh-ruby23/root/bin/ruby 23 --slave /usr/bin/gem gem /opt/rh/rh-ruby23/root/bin/gem --slave /usr/bin/bundle bundle /opt/rh/rh-ruby23/root/bin/bundle

```

4. Clone the repository and move it to `/usr/share/`:

```
$ git clone https://github.com/mocdaniel/dashing-icinga2
$ mv dashing-icinga2/ /usr/share/
$ cd /usr/share/dashing-icinga2
```

5. Bundle the application and copy the `puma` gem to `/usr/local/bin/`:

```
$ bundle
$ cp /opt/rh/rh-ruby23/root/usr/local/share/gems/gems/puma-5.6.4/bin/puma /usr/local/bin/
```

6. Copy the provided `dashing-icinga2.service` file to `/usr/lib/systemd/system/` and enable the service:

```
$ cp /usr/share/dashing-icinga2/tools/systemd/dashing-icinga2.service /usr/lib/systemd/system/dashing-icinga2.service
$ systemctl daemon-reload
$ systemctl enable --now dashing-icinga2.service
```

dashing-icinga2 should be running now!