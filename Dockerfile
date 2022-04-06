FROM ruby:2.7-buster

MAINTAINER Daniel Bodky <dbodky@gmail.com>

ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
  libssl-dev nodejs build-essential \
  && rm -rf /var/lib/apt/lists/* && mkdir -p /usr/share/dashing-icinga2

RUN echo 'gem: --no-document' >> /etc/gemrc && gem install --quiet bundler

WORKDIR /usr/share/dashing-icinga2
ADD Gemfile /usr/share/dashing-icinga2
RUN bundle update --quiet

ADD . /usr/share/dashing-icinga2
ADD config/icinga2.json config/icinga2.local.json
RUN bundle update --quiet

# mimic defaults from config/icinga2.json
ENV ICINGA2_API_HOST localhost
ENV ICINGA2_API_PORT 5665
ENV ICINGA2_API_USERNAME dashing
ENV ICINGA2_API_PASSWORD icinga2ondashingr0xx
ENV ICINGA2_API_CERT_PATH pki/
ENV ICINGA2_API_NODENAME localhost
ENV ICINGAWEB2_URL http://localhost/icingaweb2
ENV DASHBOARD_SHOW_ONLY_HARD_STATE_PROBLEMS 0
ENV DASHBOARD_TIMEZONE UTC


EXPOSE 8005

COPY docker/start.sh /usr/local/bin

CMD ["start.sh"]
