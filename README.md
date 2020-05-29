# Charts Community Fork

[Gitter exafree/charts_cf chat room](https://gitter.im/exafree/charts_cf)

This repo, charts_cf, is a fork of [google/charts](https://github.com/google/charts
and provides a charting module, [charts_flutter_cf](https://pub.dev/packages/charts_flutter_cf) for flutter.

# Development

Contributations are welcome by creating a Pull request on the [charts_cf repo](https://github.com/exafree/charts_cf).

To make a pull request fork the repoistory, create a branch,
add your feature or fix a bug and create a commit. Push that branch to
your fork and create a github pull request.

There are actually two modules in this repo, charts_flutter_cf located in
<project_root_charts_cf>/charts_flutter_cf/ and charts_common_cf located in
<project_root_charts_cf>/charts_common_cf/.

I when working on a feature or bug fix in your fork one work flow is to clone
your fork as a submodule in a project that will be using `charts_flutter_cf`.

For example, I use `flutter_benchmarkx_gui`. To get started with you own
test application update your `pubspec.yaml` commenting out the pub.dev
dependency and change it to use `path: submodules/charts_cf/charts_flutter_cf`:
```
  #charts_flutter_cf: ^0.10.2
  charts_flutter_cf:
    path: submodules/charts_cf/charts_flutter_cf
```

Then add the submodule to your project, here is an example with bm_gui:
```
wink@3900x:~/prgs/flutter/projects/bm_gui (master)
$ git submodule add git@github.com:winksaville/charts_cf submodules/charts_cf
Cloning into '/home/wink/prgs/flutter/projects/bm_gui/submodules/charts_cf'...
remote: Enumerating objects: 3364, done.
remote: Counting objects: 100% (3364/3364), done.
remote: Compressing objects: 100% (1681/1681), done.
remote: Total 3364 (delta 1789), reused 3166 (delta 1595), pack-reused 0
Receiving objects: 100% (3364/3364), 4.86 MiB | 8.94 MiB/s, done.
Resolving deltas: 100% (1789/1789), done.
```

Now make the charts_cf modules in the newly created submodule
```
wink@3900x:~/prgs/flutter/projects/bm_gui (release)
$ cd submodules/charts_cf

wink@3900x:~/prgs/flutter/projects/bm_gui/submodules/charts_cf (release)
$ make get test
Resolving dependencies... (1.0s)
+ _fe_analyzer_shared 3.0.0
+ analyzer 0.39.8
...
+ watcher 0.9.7+15
+ web_socket_channel 1.1.0
+ webkit_inspection_protocol 0.7.3
+ yaml 2.2.1
Downloading test 1.14.6...
Downloading test_core 0.3.6...
Changed 54 dependencies!
Running "flutter pub get" in charts_flutter_cf...                   1.3s
Running "flutter pub get" in example...                             1.1s
Precompiling executable... (10.0s)
Precompiled test:test.
00:38 +398: All tests passed!
00:08 +28: All tests passed!
```

**Now verify your test application still works** and then commit the work,
most likely on a dev branch in your test app:
```
$ git checkout -b submodule-charts_cf
Switched to a new branch 'submodule-charts_cf'

wink@3900x:~/prgs/flutter/projects/bm_gui (submodule-charts_cf)
$ git add *

wink@3900x:~/prgs/flutter/projects/bm_gui (submodule-charts_cf)
$ git status
On branch submodule-charts_cf
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	new file:   .gitmodules
	modified:   pubspec.yaml
	new file:   submodules/charts_cf

wink@3900x:~/prgs/flutter/projects/bm_gui (submodule-charts_cf)
$ git commit -m 'Add submodules/charts_cf'
[submodule-charts_cf c5ffe0a] Add submodules/charts_cf
 3 files changed, 4 insertions(+), 1 deletion(-)
 create mode 100644 .gitmodules
 create mode 160000 submodules/charts_cf```
```

Now, you can `cd submodules/charts_cf`, create a new branch and work on
whatever feature or bug fix you desire in `submodules/charts_cf/`. When it's
working and tests are written, create a pull request from your fork to
exafree/charts_cf.

# Makefile

The make file convience commands to get dependencies, test and publish
charts_cf:
```
$ make
Usage charts_cf: make [Target]
  Run commands for building, testing and publishing
  charts_common_cf and charts_flutter_cf

Targets:
  get:                  Get packages needed for charts_common_cf and charts_flutter_cf
  test:                 Test charts_common_cf and charts_flutter_cf
  dry-run:              Dry-run publish for charts_common_cf and charts_flutter_cf
  publish:              Publish charts_common_cf and charts_flutter_cf
  test_common_failing:  Test failures are reported in charts_common_cf
  test_flutter_failing: Test failures are reported in charts_flutter_cf
  help:                 This help message
```
# Background

This fork is necessary as Google is not currently accepting pull
requests and there are bugs that need to be fixed and features the
community feels need to be added.

# Goals

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
