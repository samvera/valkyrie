# Valkyrie

Valkyrie is a gem for enabling multiple backends for storage of files and metadata in Samvera.

![Valkyrie Logo](valkyrie_logo.png)

Code: [![Version](https://badge.fury.io/rb/valkyrie.png)](http://badge.fury.io/rb/valkyrie)
[![Build Status](https://circleci.com/gh/samvera-labs/valkyrie.svg?style=svg)](https://circleci.com/gh/samvera-labs/valkyrie)
[![Coverage Status](https://coveralls.io/repos/github/samvera-labs/valkyrie/badge.svg?branch=master)](https://coveralls.io/github/samvera-labs/valkyrie?branch=master)
[![Stories in Ready](https://badge.waffle.io/samvera-labs/valkyrie.png?label=ready&title=Ready)](https://waffle.io/samvera-labs/valkyrie)

Docs: [![Contribution Guidelines](http://img.shields.io/badge/CONTRIBUTING-Guidelines-blue.svg)](./CONTRIBUTING.md)
[![Apache 2.0 License](http://img.shields.io/badge/APACHE2-license-blue.svg)](./LICENSE)
[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://rubydoc.info/github/samvera-labs/valkyrie)

Jump in: [![Slack Status](http://slack.samvera.org/badge.svg)](http://slack.samvera.org/)

## Primary Contacts

### Product Owner
[Carolyn Cole](https://github.com/cam156)

### Technical Lead
[Trey Pendragon](https://github.com/tpendragon)

## Help

The Samvera community is here to help. Please see our [support guide](./SUPPORT.md).

## Getting Started

Add this line to your application's Gemfile:

```
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

  # To use the postgres adapter you must add `gem 'pg'` to your Gemfile
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
    Valkyrie::Storage::Fedora.new(connection: Ldp::Client.new("http://localhost:8988/rest")),
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
at once, `Valkyrie::Persistence::Solr` for storing in Solr, and `Valkyrie::Persistence::Fedora` for storing
in Fedora.

The initializer also registers three `Valkyrie::StorageAdapter` instances for storing files:
* `:disk` which stores files on disk
* `:fedora` which stores files in Fedora
* `:memory` which stores files in an in-memory cache (again, not persistent, so this is only appropriate for
  testing)

### Sample configuration with custom `Valkyrie.config.resource_class_resolver`:
```
require 'valkyrie'
Rails.application.config.to_prepare do
  Valkyrie.config.resource_class_resolver = lambda do |resource_klass_name|
    # Do complicated lookup based on the string
  end
end
```

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

Further details can be found on the [Persistence Wiki
page](https://github.com/samvera-labs/valkyrie/wiki/Persistence).

## Usage

### Define a Custom Work
Define a custom work class:

```
# frozen_string_literal: true
class MyModel < Valkyrie::Resource
  include Valkyrie::Resource::AccessControls
  attribute :title, Valkyrie::Types::Set    # Sets deduplicate values
  attribute :date, Valkyrie::Types::Array   # Arrays can contain duplicate values
end
```

Attributes are unordered by default.  Adding `ordered: true` to an attribute definition will preserve the
order of multiple values.

```
attribute :authors, Valkyrie::Types::Array.meta(ordered: true)
```

Defining resource attributes is explained in greater detail on the [Using Types Wiki
page](https://github.com/samvera-labs/valkyrie/wiki/Using-Types).

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

The Wiki documents the usage of [Queries](https://github.com/samvera-labs/valkyrie/wiki/Queries),
[Persistence](https://github.com/samvera-labs/valkyrie/wiki/Persistence), and
[ChangeSets and Dirty Tracking](https://github.com/samvera-labs/valkyrie/wiki/ChangeSets-and-Dirty-Tracking).

### Concurrency Support
A Valkyrie repository may have concurrent updates, for example, from a load-balanced Rails application, or
from multiple [Sidekiq](https://github.com/mperham/sidekiq) background workers).  In order to prevent multiple
simultaneous updates applied to the same resource from losing or corrupting data, Valkyrie supports optimistic
locking.  How to use optimistic locking with Valkyrie is documented on the [Optimistic Locking Wiki
page](https://github.com/samvera-labs/valkyrie/wiki/Optimistic-Locking).

### The Public API
Valkyrie's public API is defined by the shared specs that are used to test each of its core classes.
This include change sets, resources, persisters, adapters, and queries. When creating your own kinds of
these kinds of classes, you should use these shared specs to test your classes for conformance to
Valkyrie's API.

When breaking changes are introduced, necessitating a major version change, the shared specs will reflect
this. When new features are added and a minor version is released there will be no change to the existing
shared specs, but there may be new ones. These new shared specs will fail in your application if you have
custom adapters, but your application will still work.

Using the shared specs in your own models is described in more detail on the [Shared Specs Wiki
page](https://github.com/samvera-labs/valkyrie/wiki/Shared-Specs).

### Fedora 5 Compatibility
When configuring your adapter, include the `fedora_version` parameter in your metadata or storage adapter
config.  If Fedora requires auth, you can also include that in the URL, e.g.:

   ```
   Valkyrie::Storage::Fedora.new(
     connection: Ldp::Client.new("http://fedoraAdmin:fedoraAdmin@localhost:8988/rest"),
     fedora_version: 5
   )
   ```

## Installing a Development environment

### With Docker
The development and test stacks use fully contained virtual volumes and bind all services to different ports,
so they can be running at the same time without issue.

#### External Requirements
* [Docker](https://store.docker.com/search?offering=community&type=edition) version >= 17.09.0

### Dependency Setup (Mac OSX)
1. `brew install docker`
1. `brew install docker-machine`
1. `brew install docker-compose`

### Starting Docker (Mac OSX)
1. `docker-machine create default`
1. `docker-machine start default`
1. `eval "$(docker-machine env)"`

#### Starting the development mode dependencies
1. Start Solr, Fedora, and PostgreSQL with `rake docker:dev:daemon` (or `rake docker:dev:up` in a separate
   shell to run them in the foreground)
1. Run `rake db:create db:migrate` to initialize the database
1. Develop!
1. Run `rake docker:dev:down` to stop the server stack
   * Development servers maintain data between runs. To clean them out, run `rake docker:dev:clean`

#### To run the test suite with all dependencies in one go
1. `rake docker:spec`

#### To run the test suite manually
1. Start Solr, Fedora, and PostgreSQL with `rake docker:test:daemon` (or `rake docker:test:up` in a separate
   shell to run them in the foreground)
1. Run `rake db:create db:migrate` to initialize the database
1. Run the gem's RSpec test suite with `rspec spec` or `rake`
1. Run `rake docker:test:down` to stop the server stack
   * The test stack cleans up after itself on exit.

### Without Docker

#### External Requirements
* PostgreSQL with the uuid-ossp extension.
  * Note: Enabling uuid-ossp requires database superuser privileges.
    * From `psql`: `alter user [username] with superuser;`

#### To run the test suite
1. Start Solr and Fedora servers for testing with `rake server:test`
1. Run `rake db:create` (First time only)
1. Run `rake db:migrate`

## Acknowledgments

This software has been developed by and is brought to you by the Samvera community.  Learn more at the
[Samvera website](http://samvera.org/).

![Samvera Logo](https://wiki.duraspace.org/download/thumbnails/87459292/samvera-fall-font2-200w.png?version=1&modificationDate=1498550535816&api=v2)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/samvera-labs/valkyrie/.
