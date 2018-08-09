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
