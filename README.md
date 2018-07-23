# Valkyrie

Valkyrie is a gem for enabling multiple backends for storage of files and metadata in Samvera.

[![CircleCI](https://circleci.com/gh/samvera-labs/valkyrie.svg?style=svg)](https://circleci.com/gh/samvera-labs/valkyrie)
[![Coverage Status](https://coveralls.io/repos/github/samvera-labs/valkyrie/badge.svg?branch=master)](https://coveralls.io/github/samvera-labs/valkyrie?branch=master)
[![Stories in Ready](https://badge.waffle.io/samvera-labs/valkyrie.png?label=ready&title=Ready)](https://waffle.io/samvera-labs/valkyrie)

## Primary Contacts

### Product Owner

[Carolyn Cole](https://github.com/cam156)

### Technical Lead

[Trey Pendragon](https://github.com/tpendragon)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'valkyrie'
```

And then execute:

    $ bundle


## Configuration

Valkyrie is configured in two places: an initializer that registers the persistence options and a YAML
configuration file that sets which options are used by default in which environments.

### Sample initializer: `config/initializers/valkyrie.rb`:

Here is a sample initializer that registers a couple adapters and storage adapters, in each case linking an
instance with a short name that can be used to refer to it in your application:

```
# frozen_string_literal: true
require 'valkyrie'
Rails.application.config.to_prepare do
  Valkyrie::MetadataAdapter.register(
    Valkyrie::Persistence::Postgres::MetadataAdapter.new,
    :postgres
  )

  Valkyrie::MetadataAdapter.register(
    Valkyrie::Persistence::Memory::MetadataAdapter.new,
    :memory
  )

  Valkyrie::StorageAdapter.register(
    Valkyrie::Storage::Disk.new(base_path: Rails.root.join("tmp", "files")),
    :disk
  )

  Valkyrie::StorageAdapter.register(
    Valkyrie::Storage::Fedora.new(connection: ActiveFedora.fedora.connection),
    :fedora
  )


  Valkyrie::StorageAdapter.register(
    Valkyrie::Storage::Memory.new,
    :memory
  )
end
```

The initializer registers two `Valkyrie::MetadataAdapter` instances for storing metadata:
* `:postgres` which stores metadata in a PostgreSQL database
* `:memory` which stores metadata in an in-memory cache (this cache is not persistent, so it is only
  appropriate for testing)

Other adapter options include `Valkyrie::Persistence::BufferedPersister` for buffering in memory before bulk
updating another persister, `Valkyrie::Persistence::CompositePersister` for storing in more than one adapter
at once, and `Valkyrie::Persistence::Solr` for storing in Solr.

The initializer also registers three `Valkyrie::StorageAdapter` instances for storing files:
* `:disk` which stores files on disk
* `:fedora` which stores files in Fedora
* `:memory` which stores files in an in-memory cache (again, not persistent, so this is only appropriate for
  testing)

### Sample configuration: `config/valkyrie.yml`:

A sample configuration file that configures your application to use different adapters:

```
development:
  metadata_adapter: postgres
  storage_adapter: disk

test:
  metadata_adapter: memory
  storage_adapter: memory

production:
  metadata_adapter: postgres
  storage_adapter: fedora
```

For each environment, you must set two values:
* `metadata_adapter` is the store where Valkyrie will put the metadata
* `storage_adapter` is the store where Valkyrie will put the files

The values are the short names used in your initializer.


## Usage

### Define a Custom Work

Define a custom work class:

```
# frozen_string_literal: true
class MyModel < Valkyrie::Resource
  include Valkyrie::Resource::AccessControls
  attribute :id, Valkyrie::Types::ID.optional  # Optional to allow auto-generation of IDs
  attribute :title, Valkyrie::Types::Set       # Sets are unordered
  attribute :authors, Valkyrie::Types::Array   # Arrays are ordered
end
```

#### Work Types Generator

To create a custom Valkyrie model in your application, you can use the Rails generator.  For example, to
generate a model named `FooBar` with an unordered `title` field and an ordered `member_ids` field:

```
rails generate valkyrie:resource FooBar title member_ids:array
```

You can namespace your model class by including a slash in the model name:

```
rails generate valkyrie:resource Foo/Bar title member_ids:array
```

### Read and Write Data

```
# initialize a metadata adapter
adapter = Valkyrie::MetadataAdapter.find(:postgres)

# create an object
object1 = MyModel.new title: 'My Cool Object', authors: ['Jones, Alice', 'Smith, Bob']
object1 = adapter.persister.save(resource: object1)

# load an object from the database
object2 = adapter.query_service.find_by(id: object1.id)

# load all objects
objects = adapter.query_service.find_all

# load all MyModel objects
Valkyrie.config.metadata_adapter.query_service.find_all_of_model(model: MyModel)
```


## Installing a Development environment

### Without Docker

#### External Requirements
* PostgreSQL with the uuid-ossp extension.
  * Note: Enabling uuid-ossp requires database superuser privileges.
    * From `psql`: `alter user [username] with superuser;`

#### To run the test suite
1. Start Solr and Fedora servers for testing with `rake server:test`
1. Run `rake db:create` (First time only)
1. Run `rake db:migrate`

### With Docker

#### External Requirements
* [Docker](https://store.docker.com/search?offering=community&type=edition) version >= 17.09.0
*
### Dependency Setup (Mac OSX)

1. `brew install docker`
1. `brew install docker-machine`
1. `brew install docker-compose`

### Starting Docker (Mac OSX)

1. `docker-machine create default`
1. `docker-machine start default`
1. `eval "$(docker-machine env)"

#### Starting the development mode dependencies
1. Start Solr, Fedora, and PostgreSQL with `rake docker:dev:daemon` (or `rake docker:dev:up` in a separate shell to run them in the foreground)
1. Run `rake db:create db:migrate` to initialize the database
1. Develop!
1. Run `rake docker:dev:down` to stop the server stack
   * Development servers maintain data between runs. To clean them out, run `rake docker:dev:clean`

#### To run the test suite with all dependencies in one go
1. `rake docker:spec`

#### To run the test suite manually
1. Start Solr, Fedora, and PostgreSQL with `rake docker:test:daemon` (or `rake docker:test:up` in a separate shell to run them in the foreground)
1. Run `rake db:create db:migrate` to initialize the database
1. Run the gem's RSpec test suite with `rspec spec` or `rake`
1. Run `rake docker:test:down` to stop the server stack
   * The test stack cleans up after itself on exit.

The development and test stacks use fully contained virtual volumes and bind all services to different ports, so they can be running at the same time without issue.

## Get Help

If you have any questions regarding Valkyrie you can send a message to [the
Samvera community tech list](mailto:samvera-tech@googlegroups.com) or the `#valkyrie`
channel in the [Samvera community Slack
team](https://wiki.duraspace.org/pages/viewpage.action?pageId=87460391#Getintouch!-Slack).

## License

Valkyrie is available under [the Apache 2.0 license](../LICENSE).


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/samvera-labs/valkyrie/.
