# Valkyrie

Valkyrie is a gem for enabling multiple backends for storage of files and metadata in Samvera,
currently developed in a subdirectory of the [proof-of-concept app of the same name](..).

[![CircleCI](https://circleci.com/gh/samvera-labs/valkyrie.svg?style=svg)](https://circleci.com/gh/samvera-labs/valkyrie)
[![Coverage Status](https://coveralls.io/repos/github/samvera-labs/valkyrie/badge.svg?branch=master)](https://coveralls.io/github/samvera-labs/valkyrie?branch=master)
[![Stories in Ready](https://badge.waffle.io/samvera-labs/valkyrie.png?label=ready&title=Ready)](https://waffle.io/samvera-labs/valkyrie)


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'valkyrie', github: 'samvera-labs/valkyrie'
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
  Valkyrie::Adapter.register(
    Valkyrie::Persistence::Postgres::Adapter,
    :postgres
  )

  Valkyrie::Adapter.register(
    Valkyrie::Persistence::Memory::Adapter.new,
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

The initializer registers two `Valkyrie::Adapter` instances for storing metadata:
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
  adapter: postgres
  storage_adapter: disk

test:
  adapter: memory
  storage_adapter: memory

production:
  adapter: postgres
  storage_adapter: fedora
```

For each environment, you must set two values:
* `adapter` is the store where Valkyrie will put the metadata
* `storage_adapter` is the store where Valkyrie will put the files

The values are the short names used in your initializer.


## Usage

### Define a Custom Work

Define a custom work class:

```
# frozen_string_literal: true
class MyModel < Valkyrie::Model
  include Valkyrie::Model::AccessControls
  attribute :id, Valkyrie::Types::ID.optional  # Optional to allow auto-generation of IDs
  attribute :title, Valkyrie::Types::Set       # Sets are unordered
  attribute :authors, Valkyrie::Types::Array   # Arrays are ordered
end
```

#### Work Types Generator

To create a custom Valkyrie model in your application, you can use the Rails generator.  For example, to 
generate a model named `FooBar` with an unordered `title` field and an ordered `member_ids` field:

```
rails generate valkyrie:model FooBar title member_ids:array
```

You can namespace your model class by including a slash in the model name:

```
rails generate valkyrie:model Foo/Bar title member_ids:array
```

### Read and Write Data

```
# create an object
object1 = MyModel.new title: 'My Cool Object', authors: ['Jones, Alice', 'Smith, Bob']
object1 = Persister.save(model: object1)

# load an object from the database
object2 = QueryService.find_by(id: object1.id)

# load all objects
objects = QueryService.find_all

# load all MyModel objects
Valkyrie.config.adapter.query_service.find_all_of_model(model: MyModel)
```


## Installing a Development environment

See the parent app README for [instructions on setting up a development
environment](../#installing-a-development-environment).  To run the test suite:
1. Start Solr and Fedora servers for testing with `rake server:test` in the parent app
1. Run the gem's RSpec test suite with `cd valkyrie && rspec spec`


## License

Valkyrie is available under [the Apache 2.0 license](../LICENSE).


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/samvera-labs/valkyrie/.
