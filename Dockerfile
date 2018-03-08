FROM ruby:2.4-alpine

RUN apk --no-cache add \
    --virtual build_deps \
    build-base \
    ruby-dev

RUN apk --no-cache add \
    nodejs \
    libc-dev

WORKDIR /app

ADD Gemfile /app
RUN bundle
RUN apk del build_deps


ADD . /app
ADD config/icinga2.json config/icinga2.local.json

ENV ICINGA2_API_HOST localhost
ENV ICINGA2_API_PORT 5665
ENV ICINGA2_API_USERNAME dashing
ENV ICINGA2_API_PASSWORD secret
ENV ICINGA2_API_CERT_PATH pki/
ENV ICINGA2_API_NODENAME icinga2-master1.localdomain
ENV ICINGAWEB2_URL http://localhost/icingaweb2

EXPOSE 8005

CMD ["dashing", "start", "-p", "8005"]
