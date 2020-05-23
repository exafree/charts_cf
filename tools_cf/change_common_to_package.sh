#~/usr/bin/env bash
#
# Change ref to charts_common_cf to package in pubspec.yaml

uncmnt_co='s|# charts_common_cf: \^|charts_common_cf: ^|'
cmnt_co='s|^  charts_common_cf:$|  # charts_common_cf:|'
cmnt_pt='s|^    path: ../charts_common_cf/$|  #   path: ../charts_common_cf/|'
sed -i -e "${uncmnt_co} ; ${cmnt_co} ; ${cmnt_pt}" pubspec.yaml

