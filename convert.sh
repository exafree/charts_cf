#~/usr/bin/env bash

cc_script='s|package:charts_common/|package:charts_common_community/|'
cf_script='s|package:charts_flutter/|package:charts_flutter_community/|'

find . -type f -name '*.dart' -print0 | xargs -0 sed -i -e "${cc_script}"
find . -type f -name '*.dart' -print0 | xargs -0 sed -i -e "${cf_script}"

sed -i -e 's|charts_common|charts_common_community|' charts_common/pubspec.yaml charts_flutter/pubspec.yaml
sed -i -e 's|charts_flutter|charts_flutter_community|' charts_flutter/pubspec.yaml
sed -i -e 's|charts_flutter|charts_flutter_community|' charts_flutter/example/pubspec.yaml

mv charts_common charts_common_community
mv charts_flutter charts_flutter_community
