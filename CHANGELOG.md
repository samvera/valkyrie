# v1.5.0 RC2 2018-02-01

## Changes since last release

* Fix solr casting when an updated_at key isn't present in the solr document.
  [tpendragon](https://github.com/tpendragon)

Additional thanks to the following for code review:

[mjgiarlo](https://github.com/mjgiarlo)

# v1.5.0 RC1 2018-02-01

## Changes since last release

* Add missing query service requirement to persister shared specs
  [cjcolvar](https://github.com/cjcolvar)
* Provide a warning when postgres adapter overwrites an ID, deprecate this
  behavior so it will throw an exception in the future.
  [cam156](https://github.com/cam156)
  [hackmastera](https://github.com/hackmastera)
  [tpendragon](https://github.com/tpendragon)
* Add support for passing just an ID to find_inverse_references_by
  [cam156](https://github.com/cam156)
  [hackmastera](https://github.com/hackmastera)
* Fix memory adapter raising an exception in find_by_alternate_identifier when
  there are resources without the alternate_identifier attribute.
  [jeremyf](https://github.com/jeremyf)
* Provide a warning when using the postgres adapter without manually providing
  the pg gem, so it can be an optional dependency in 2.0.0.
  [hackmastera](https://github.com/hackmastera)
* Provide guidance in specs on how to define alternate_ids
  [cjcolvar](https://github.com/cjcolvar)
* Upload files to Fedora using form/multipart.
  [tpendragon](https://github.com/tpendragon)
* Improve CompositePersister documentation.
  [tpendragon](https://github.com/tpendragon)
* Add a Valkyrie::Types::Params::ID type which handles when an HTML form passes
  an empty string value.
  [tpendragon](https://github.com/tpendragon)
* Deprecate .member on Valkyrie::Types::Array & Set
  [tpendragon](https://github.com/tpendragon)
* Fix updated_at not being set correctly for the Solr adapter, fix shared specs.
  [tpendragon](https://github.com/tpendragon)

Additional thanks to the following for code review and issue reports leading to
this release:

[awead](https://github.com/awead)
[escowles](https://github.com/escowles)
[kelynch](https://github.com/kelynch)
[mbklein](https://github.com/mbklein)
[no-reply](https://github.com/no-reply)
[revgum](https://github.com/revgum)

# v1.4.0 2018-01-08

## Changes since last release.

* Add support for Fedora 5
  [escowles](https://github.com/escowles)

# v1.3.0 2018-12-03

## Changes since last release

* Add deprecations for known methods changing in 2.0
* Add `set_value` method.

# v1.2.2 2018-10-05

## Changes since last release

* Fix consistency in adapter's responses to queries.
  [ojlyytinen](https://github.com/ojlyytinen)

# v1.2.1 2018-09-25

## Changes since last release

* Fix solr persister to pass through exceptions on timeout
  [hackmastera](https://github.com/hackmastera)
* Fix generated specs to work with shared_specs expectation
  [revgum](https://github.com/revgum)

# v1.2.0 2018-08-29

## Changes since last release

* Added `optimistic_locking_enabled?` to ChangeSets.

# v1.2.0.RC3 2018-08-15

## Changes since last release

* Fix for postgres optimistic locking.

# v1.2.0.RC2 2018-08-10

## Changes since last release

* Support for ordered properties.
  [Documentation](https://github.com/samvera-labs/valkyrie/wiki/Using-Types#ordering-values)
* Shared specs for Solr indexers.

# v1.2.0.RC1 2018-08-09

## Changes since last release

* Support for single values.
  [Documentation](https://github.com/samvera-labs/valkyrie/wiki/Using-Types#singular-values)
* Optimistic Locking.
  [Documentation](https://github.com/samvera-labs/valkyrie/wiki/Optimistic-Locking)
* Remove reliance on ActiveFedora for Fedora Storage Adapter.
* Only load adapters if referenced.
* Postgres Adapter uses transactions for `save_all`
* Resources now include `id` attribute by default.

## Special Thanks

This release was made possible by a community sprint undertaken between Penn
State University Libraries & Princeton University Library. Thanks to the
following participants who made it happen:

* [awead](https://github.com/awead)
* [cam156](https://github.com/cam156)
* [DanCoughlin](https://github.com/DanCoughlin)
* [escowles](https://github.com/escowles)
* [hackmastera](https://github.com/hackmastera)
* [jrgriffiniii](https://github.com/jrgriffiniii)
* [mtribone](https://github.com/mtribone)
* [tpendragon](https://github.com/tpendragon)

# v1.1.2 2018-06-08

## Changes since last release

* Performance improvements for ActiveRecord to Valkyrie::Resource conversions.
    [tpendragon](https://github.com/tpendragon)

# v1.1.1 2018-05-31

## Changes since last release

* Loosened ActiveRecord restriction to allow upgrading pg gem to 1.0.
    [hackmastera](https://github.com/hackmastera)

# v1.1.0 2018-05-08

## Changes since last release

* Added `find_by_alternate_identifier` query.
    [stkenny](https://github.com/stkenny)
* Added Docker environment for development.
    [mbklein](https://github.com/mbklein)
* Fixed README documentation.
    [revgum](https://github.com/revgum)
* Deprecated `Valkyrie::Persistence::Fedora::PermissiveSchema.references`
* Deprecated `Valkyrie::Persistence::Fedora::PermissiveSchema.alternate_ids`

# v1.0.0 2018-03-23

## Changes since last release

* Final release of 1.0.0!
* Support slashes in IDs for Fedora adapter.
    [dlpierce](https://github.com/dlpierce)
* Added find_many_by_ids query.
* Enforces only persisting arrays - no scalars.
* Fixes casting edge cases for `Set` and `Array`.
* Significantly improved documentation
* Support `Booleans`
* Support `RDF::Literal`
* Fix support for `DateTime`.
* Fix rake tasks leaking out of gem.
* Extract derivatives/file characterization to
    [valkyrie-derivatives](https://github.com/samvera-labs/valkyrie-derivatives)
* ChangeSet shared spec
* Allow strings as an argument for find_by.
* Improve development documentation.
* Throw error on `find_inverse_references_by` for unsaved `resource`.

# v1.0.0.RC2 2018-03-14

## Changes since last release

* Support slashes in IDs for Fedora adapter.
    [dlpierce](https://github.com/dlpierce)

# v1.0.0.RC1 2018-03-02

Initial Release

## Changes Since Last Sprint

* Added find_many_by_ids query.
* Enforces only persisting arrays - no scalars.
* Fixes casting edge cases for `Set` and `Array`.
* Significantly improved documentation
* Support `Booleans`
* Support `RDF::Literal`
* Fix support for `DateTime`.
* Fix rake tasks leaking out of gem.
* Extract derivatives/file characterization to
    [valkyrie-derivatives](https://github.com/samvera-labs/valkyrie-derivatives)
* ChangeSet shared spec
* Allow strings as an argument for find_by.
* Improve development documentation.
* Throw error on `find_inverse_references_by` for unsaved `resource`.

## Special Thanks to All Contributors:

* [atz](https://github.com/atz)
* [awead](https://github.com/awead)
* [barmintor](https://github.com/barmintor)
* [bmquinn](https://github.com/bmquinn)
* [cam156](https://github.com/cam156)
* [carrickr](https://github.com/carrickr)
* [cbeer](https://github.com/cbeer)
* [cjcolvar](https://github.com/cjcolvar)
* [csyversen](https://github.com/csyversen)
* [dlpierce](https://github.com/dlpierce)
* [escowles](https://github.com/escowles)
* [geekscruff](https://github.com/geekscruff)
* [hackmastera](https://github.com/hackmastera)
* [jcoyne](https://github.com/jcoyne)
* [jeremyf](https://github.com/jeremyf)
* [jgondron](https://github.com/jgondron)
* [jrgriffiniii](https://github.com/jrgriffiniii)
* [mbklein](https://github.com/mbklein)
* [stkenny](https://github.com/stkenny)
* [tpendragon](https://github.com/tpendragon)
