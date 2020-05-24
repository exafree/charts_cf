#~/usr/bin/env bash
#
# Convert files so they create and reference exafree/charts_cf
# instead of google/charts.  Prior to running this script make
# desired changes to AUTHORS, CONTRIBUTING.md and README.md files.
#
# Then from the root of the repo run `./tools_cf/convert.sh`.
# The convert.sh script appends "_cf", where _cf is an acronym
# for community fork, to references to charts_common and
# charts_flutter in all dart and pubspec.yaml files. It also
# tweaks a few other fields in the pubspec.yaml files as detailed
# in the respective comments below. These changes to pubspec.yaml
# make sure they reference the new packages and minimize warning
# from issued by `publsh --dry-run`.

cc1_script='s|package:charts_common/common.dart|package:charts_common_cf/charts_common_cf.dart|'
cc2_script='s|package:charts_common/|package:charts_common_cf/|'
cf1_script='s|package:charts_flutter/flutter.dart|package:charts_flutter_cf/charts_flutter_cf.dart|'
cf2_script='s|package:charts_flutter/|package:charts_flutter_cf/|'
find . -type f -name '*.dart' -print0 | xargs -0 \
   sed -i -e "${cc1_script} ; ${cc2_script} ; ${cf1_script} ; ${cf2_script}"

# Change version to 0.10.2
ver='s|version: 0.9.0|version: 0.10.2|'
homepage='s|homepage: .*$|homepage: https://github.com/exafree/charts_cf|'
cover='s|charts_common: 0.9.0|charts_common: ^0.10.2|'
log='s|logging: any|logging: ^0.11.4|'
author='/author: /d'
addco_cf='s|charts_common|charts_common_cf|'
addcf_cf='s|charts_flutter|charts_flutter_cf|'
find . -type f -name 'pubspec.yaml' -print0 | xargs -0 \
   sed -i -e "${ver} ; ${homepage} ; ${cover} ; ${log} ; ${author} ; ${addco_cf} ; ${addcf_co} ; ${addcf_cf}"

# Fix GitHub repo link
sed -i -e 's|\[GitHub repo\](https://github.com/google/charts)|[GitHub repo](https://github.com/exafree/charts_cf)|' charts_flutter/README.md

# Replace README.md with the following
cat >README.md <<EOL
# Charts Community Fork

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
Dartx27s [package versioning](https://dart.dev/tools/pub/versioning)\
spec and the value will be advanced from as google/charts with
the minor version field incremented by 1 and the patch field will
be 0. This means that the charts_cf public API will
**always** be backwards compatible with google/charts, but have
new functionality or improvements as stated in
[semver spec](https://semver.org/spec/v2.0.0-rc.1.html) rule 8.
EOL

# Replace CONTRIBUTING.dm with the following
cat >CONTRIBUTING.md <<EOL
This project is a fork of https://gitbhub.com/google/charrts
with enhancements by the exafree community. External contributions
are very welcome.
EOL

# Append new Author
echo 'Wink Saville <wink@saville.com' >> AUTHORS

# Update CHANGELOG.md files
sed -i -e '1i \
# 0.10.2\
* Try again, forgot to add homepage to sed script for pubspec.\
* Tweak link in charts_flutter_cf/README.md to github.com/exafree/charts_cf\
\
# 0.10.1\
* Second attempt at a Fork of google/charts with pachages renamed\
  from charts_common and charts_flutter to charts_common_cf and
  charts_flutter_cf. Where "cf" is an acronym for "community fork".\
\
* Fix the incorrect homepage links in the pubspec.yaml\
* In Makefile fixed a typo, leaving off the '_cf' in `cd charts_common_cf`\
  in the publish_common target. And remove a debug `ls` in test_flutter target.\
\
# 0.10.0\
* Fork of google/charts with pachages renamed from charts_common\
  and charts_flutter to charts_common_cf and charts_flutter_cf.\
  Where "cf" is an acronym for "community fork".\
' charts_common/CHANGELOG.md charts_flutter/CHANGELOG.md

# Rename common.dart to charts_common_cf.dart to remove pubish warning
mv charts_common/lib/common.dart charts_common/lib/charts_common_cf.dart

# Rename flutter.dart to charts_flutter_cf.dart to remove pubish warning
mv charts_flutter/lib/flutter.dart charts_flutter/lib/charts_flutter_cf.dart

# Rename the directories to charts_common_cf and charts_flutter_cf
mv charts_common charts_common_cf
mv charts_flutter charts_flutter_cf
