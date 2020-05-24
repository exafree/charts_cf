#~/usr/bin/env bash
#
# Change ref to charts_common_cf to path in pubspec.yaml
#

cmnt_co='s|^  charts_common_cf: \^|  # charts_common_cf: ^|'
uncmnt_co='s|^  # charts_common_cf:$|  charts_common_cf:|'
uncmnt_pt='s|^  #   path: ../charts_common_cf/$|    path: ../charts_common_cf/|'
sed -i -e "${cmnt_co} ; ${uncmnt_co} ; ${uncmnt_pt}" pubspec.yaml

