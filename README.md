# Valkyrie

A proof of concept "breakable toy" for enabling multiple backends for storage of
  files and metadata in Samvera.

[![CircleCI](https://circleci.com/gh/samvera-labs/valkyrie.svg?style=svg)](https://circleci.com/gh/samvera-labs/valkyrie) [![Coverage Status](https://coveralls.io/repos/github/samvera-labs/valkyrie/badge.svg?branch=master)](https://coveralls.io/github/samvera-labs/valkyrie?branch=master)

## Configure Valkyrie

Valkyrie is configured in `config/valkyrie.yml`.  For each environment you must set
two values.  The first, `adapter`, is the store where Valkyrie will put the metadata.
The valid values for `adapter` are `:postgres` (default), `:fedora`(actually ActiveFedora),
`:memory` (should only be used for running tests, because it's not persistent).  
You can register your own adapters in `config/initializers/register_adapter.rb`.

Valkyrie will automatically persist to the metadata store you have chosen and write
to Solr synchronously (using the `:indexing_persister`).

The second configuration value `storage_adapter` is where the binaries are stored.
The valid values for `storage_adapter` are `:disk` and `:memory`. `:memory` should
only be used for testing as it's not a persistent store.


## Installing a Development environment

1. Install Postgres on your machine.  If you have homebrew on OS X you can run the following steps:
   1. `brew install postgres`
   1. `brew services start postgresql`
   1.  `gem install pg -- --with-pg-config=/usr/local/bin/pg_config`
   1.  `cp config/database.yml.example config/database.yml`
   1.  Edit `config/database.yml` so that the username is the name you use to log into your Mac
1. `bundle install`
1. `rake db:create:all`
1. `rake db:migrate`
1. Start solr and fedora servers for testing via `rake server:test`
1. Start solr and fedora servers for development via `rake server:development`
1. Bring up a Rails server via `rails s` or a console via `rails c`
1. Run specs via `rspec spec`


## License

Valkyrie is available under [the Apache 2.0 license](LICENSE).
