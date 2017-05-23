# Valkyrie

A proof of concept "breakable toy" for enabling multiple backends for storage of
  files and metadata in Hydra.

[![CircleCI](https://circleci.com/gh/projecthydra-labs/valkyrie.svg?style=svg)](https://circleci.com/gh/projecthydra-labs/valkyrie) [![Coverage Status](https://coveralls.io/repos/github/projecthydra-labs/valkyrie/badge.svg?branch=master)](https://coveralls.io/github/projecthydra-labs/valkyrie?branch=master)


### Installing a Dev environment

1. Install Postgres on your machine.  If you have homebrew on OS X you can run the following steps:
   1. `brew install postgres`
   1. `brew services start postgresql`
   1.  `gem install pg -- --with-pg-config=/usr/local/bin/pg_config`
   1.  `cp config/database.yml.example config/database.yml`
   1.  Edit `config/database.yml` so that the username is the name you use to log into your Mac
1. `bundle install`
1. `rake db:create:all`
1. `rake db:migrate`
1. Start a test server via `rake server:test`
1. Start a dev server via `rake server:development`
1. Bring up a Rails server via `rails s` or a console via `rails c`
1. Run specs via `rspec spec`


# License

Valkyrie is available under [the Apache 2.0 license](LICENSE).
