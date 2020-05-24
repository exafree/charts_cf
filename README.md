# Charts Community Fork

[Gitter exafree/charts_cf chat room](https://gitter.im/exafree/charts_cf)

This repo, charts_cf, is a fork of [google/charts](https://github.com/google/charts)

This fork is necessary as Google is not currently accepting pull
requests and there are bugs that need to be fixed and features the
community feels need to be added.

The current proposal is that the master branch of this repo
will be the same as a commit on the master branch of
google/charts and will be synchronized with the most
current commit as soon as practical. The master branch will
then be merged with our release branch ASAP. A new release
will be created soon thereafter.

The version number of a charts_cf release will follow
Dartx27s [package versioning](https://dart.dev/tools/pub/versioning)spec and the value will be advanced from as google/charts with
the minor version field incremented by 1 and the patch field will
be 0. This means that the charts_cf public API will
**always** be backwards compatible with google/charts, but have
new functionality or improvements as stated in
[semver spec](https://semver.org/spec/v2.0.0-rc.1.html) rule 8.
