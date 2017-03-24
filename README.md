# Valkyrie

This is just Trey's experiments on how we might look towards separating the
Hydra/Curation Concerns stack from Fedora.

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
1. Start a dev server via `rake server:development`
1. Bring up a Rails server via `rails s` or a console via `rails c`
