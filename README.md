# Charts Community Fork

[Gitter exafree/charts_cf chat room](https://gitter.im/exafree/charts_cf)

This repo, charts_cf, is a fork of [google/charts](https://github.com/google/charts)
and provides a charting module, [charts_flutter_cf](https://pub.dev/packages/charts_flutter_cf) for flutter.

This fork is necessary as Google is not currently accepting pull
requests and there are bugs that need to be fixed and features the
community feels need to be added.

## Guide lines

The master branch of this repo will be the same as a commit on
the master branch of google/charts and will be synchronized with the most
current commit google/charts master as soon as practical. The release branch of
this repo will then be rebaased on top of master and a new release
created soon thereafter.

The version number of a charts_cf release will follow
Dart's [package versioning](https://dart.dev/tools/pub/versioning) spec.
The major number will be the same as google/charts with minor version
number being greather than the google/charts minor version. This means
that the charts_cf public API will **always** be backwards compatible with
google/charts, but have new functionality or improvements as stated in
[semver spec](https://semver.org/spec/v2.0.0-rc.1.html) rule 8.

Long term we hope that Google will accpet changes directly, but until
such time we will do our best to fix bugs and enhance google/charts
and remain backwards compatible.

## Pull requests

We look forward to seeing pull requests. In general we desire that
an [issue be created](https://git@github.com/exafree/charts_cf/issues)
before a PR is merged and it's probably a good idea to create an issue
before creating a PR so we might discuss solutions. When creating
the commit message add a "Fixes: #xx" line in the last paragraph of
the commit message, where xx is the issue number. This will link the
PR with an issue and when the PR is closed the issue will also be closed.
Also, links will appear between the PR and Issue will appear in
CHANGELOG.md.

Of great importance is that tests should be provided with a PR, these
can extend a current test file or a new test file can be created. If
in doubt we suggest creating a new test file as it will be easier to
merge/rebase changes into google/charts.

## Dependencies
 - Dart
 - Flutter

### Development Dependencies
 - Gnu make
 - git
 - npm
   - auto-changelog

## Development

To make a pull request fork the repoistory, create a branch,
add your feature or fix a bug and create a commit. Push that branch to
your fork and create a github pull request.

There are actually two modules in this repo, charts_flutter_cf located in
<project_root_charts_cf>/charts_flutter_cf/ and charts_common_cf located in
<project_root_charts_cf>/charts_common_cf/.

I when working on a feature or bug fix in your fork one work flow is to clone
your fork as a submodule in a project that will be using `charts_flutter_cf`.

For example, I use `flutter_benchmarkx_gui`. To get started with your own
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

## Releasing

You can release from a fork.

1. Fork exafree/charts and clone, if you've not already done so.
2. Add an upstream remote, if you've not already done so.
```
$ git remote add upstream git@github.com:exafree/charts_cf
$ git remote -v
origin	git@github.com:winksaville/charts_cf (fetch)
origin	git@github.com:winksaville/charts_cf (push)
upstream	git@github.com:exafree/charts_cf (fetch)
upstream	git@github.com:exafree/charts_cf (push)
```
3. Sync with upstream and be sure your clone is `Already up to date`
```
$ git checkout release
Switched to branch 'release'
Your branch is up to date with 'origin/release'.

$ git pull upstream release
From github.com:exafree/charts_cf
 * branch            release    -> FETCH_HEAD
Already up to date.
```
4. Get dependencies and run the tests
```
$ make get test
Resolving dependencies...
Got dependencies!
Running "flutter pub get" in charts_flutter_cf...                   0.4s
Running "flutter pub get" in example...                             0.4s
Precompiling executable... (10.3s)
Precompiled test:test.
00:41 +417: All tests passed!
00:02 +28: All tests passed!
```
5. Create a release branch, use **next version** NOT 0.10.3+cf.
This command updates version numbers in pubspec.yaml files,
generates new changelog's, creates Release-x.y.z+cf branch,
commits changes, creates tag, does a get, test and dry-run.
```
$ make rlease charts_ver=0.10.3+cf
```
6. Push the branch and tags to your fork
```
git push origin Release-0.10.3+cf
```
7. On [exafree/charts_cf](https://github.com/exafree/charts_cf)
create a Pull Request and then Squash and Merge.
8. Checkout release, pull from upstream, push to origin/release so
the release branch of your fork is upto date:
```
$ git checkout release
$ git pull upstream release
$ git push origin release
```
9. Final check before publishing the git-status should show no
modified, untracked or changed files. You should also verify your
perferred test application works!:
```
$ make get test dry-run
$ git status
```
10. if all is well publish:
```
$ make publish
```

## Makefile

The make file provides convience commands to get dependencies, test and publish
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
  release:              Updates version numbers in pubspec.yaml files,
                        generates new changelog's, creates Release-x.y.z+cf branch,
                        commits changes, creates tag, does a get, test and dry-run
                           Example usage: make release charts_ver=0.10.3+cf
  publish:              Publish charts_common_cf and charts_flutter_cf
  test_common_failing:  Test failures are reported in charts_common_cf
  test_flutter_failing: Test failures are reported in charts_flutter_cf
  help:                 This help message

```
