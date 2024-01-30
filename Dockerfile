ARG ruby_version=2.6
FROM ruby:${ruby_version}

SHELL ["/bin/bash", "-c"]

WORKDIR /opt/valkyrie

COPY . .

RUN chmod -R 0777 .

USER 1001:0

ENV HOME=/opt/valkyrie

RUN gem install bundler && bundle install
