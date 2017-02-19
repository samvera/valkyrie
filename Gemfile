source "https://rubygems.org"

gem "autoprefixer-rails"
gem "jquery-rails"
gem "normalize-rails", "~> 3.0.0"
gem "pg"
gem "puma"
gem "sqlite3"
gem "rack-canonical-host"
gem "rails", "~> 5.0.0"
gem "recipient_interceptor"
gem "sass-rails", "~> 5.0"
gem "simple_form"
gem "sprockets", ">= 3.0.0"
gem "sprockets-es6"
gem "suspenders"
gem "title"
gem "uglifier"
gem 'devise'
gem 'activerecord-import'

## Fedora Adapter
gem 'active-fedora'
gem 'rdf'
gem 'hydra-works'

group :development do
  gem "listen"
  gem "spring"
  gem "spring-commands-rspec"
  gem "web-console"
end

group :development, :test do
  gem "awesome_print"
  gem "bullet"
  gem "bundler-audit", ">= 0.5.0", require: false
  gem "dotenv-rails"
  gem "factory_girl_rails"
  gem "pry-byebug"
  gem "pry-rails"
  gem "rspec-rails"
  gem 'capybara'
  gem 'rubocop'
  gem 'rubocop-rspec'
end

group :development, :staging do
  gem "rack-mini-profiler", require: false
end

group :test do
  gem "database_cleaner"
  gem "formulaic"
  gem "launchy"
  gem "shoulda-matchers"
  gem "simplecov", require: false
  gem "timecop"
  gem "webmock"
end

group :staging, :production do
  gem "rack-timeout"
  gem "rails_stdout_logging"
end

## Enter Hydra Stuff
gem 'blacklight'

group :development, :test do
  gem 'solr_wrapper', '>= 0.3'
  gem 'rails-controller-testing'
end

gem 'rsolr', '~> 1.0'

gem 'devise-guests', '~> 0.5'
gem 'virtus'
gem 'rdf'
gem 'reform'
gem 'reform-rails'

# Maybe extract just the stuff for multi-inputs..
gem 'hydra-editor'
gem 'jquery-ui-rails', '~> 6.0'
