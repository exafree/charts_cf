# Makefile for building, testing and publishing
# charts_common_cf and charts_flutter_cf

AT=@
.PHONY: all
all: help

.PHONY: help
help:
	@echo "Usage charts_cf: make [Target]"
	@echo "  Run commands for building, testing and publishing"
	@echo "  charts_common_cf and charts_flutter_cf"
	@echo
	@echo "Targets:"
	@echo "  get:                  Get packages needed for charts_common_cf and charts_flutter_cf"
	@echo "  test:                 Test charts_common_cf and charts_flutter_cf"
	@echo "  dry-run:              Dry-run publish for charts_common_cf and charts_flutter_cf"
	@echo "  release:              Updates version numbers in pubspec.yaml files,"
	@echo "                        generates new changelog's, creates Release-x.y.z+cf branch,"
	@echo "                        commits changes, creates tag, does a get, test and dry-run"
	@echo "                           Example usage: make release charts_ver=0.10.3+cf"
	@echo "  publish:              Publish charts_common_cf and charts_flutter_cf"
	@echo "  test_common_failing:  Test failures are reported in charts_common_cf"
	@echo "  test_flutter_failing: Test failures are reported in charts_flutter_cf"
	@echo "  help:                 This help message"

.PHONY: get
get: get_common get_flutter

.PHONY: get_common
get_common:
	$(AT)(cd charts_common_cf ; pub get)

.PHONY: get_flutter
get_flutter:
	$(AT)(cd charts_flutter_cf ; flutter pub get)

.PHONY: test
test: test_common test_flutter

.PHONY: test_common
test_common:
	$(AT)(cd charts_common_cf ; pub run test)

.PHONY: test_flutter
test_flutter:
	$(AT)(cd charts_flutter_cf ; flutter test)

.PHONY: test_common_failing
test_common_failing:
	$(AT)(cd charts_common_cf; \
	cp ../tools_cf/failing_test.dart test/; \
	pub run test; \
	result=$$?; \
	rm -f test/failing_test.dart; \
	exit $${result})

.PHONY: test_flutter_failing
test_flutter_failing:
	$(AT)(cd charts_flutter_cf; \
	cp ../tools_cf/failing_test.dart test/; \
	flutter test; \
	result=$$?; \
	rm -f test/failing_test.dart; \
	exit $${result})

.PHONY: gen-changelog
gen-changelog: gen-changelog_common gen-changelog_flutter

.PHONY: gen-changelog_common
gen-changelog_common:
	$(AT)(cd charts_common_cf; \
	if [[ "$${charts_ver}" == "" ]]; then echo "No 'charts_ver=xxxx' parameter, aborting"; exit 1; fi; \
	auto-changelog --latest-version $${charts_ver} --stdout | cat - ../tools_cf/charts_common.original.CHANGELOG.md > CHANGELOG.md)

.PHONY: gen-changelog_flutter
gen-changelog_flutter:
	$(AT)(cd charts_flutter_cf; \
	if [[ "$${charts_ver}" == "" ]]; then echo "No 'charts_ver=xxxx' parameter, aborting"; exit 1; fi; \
	auto-changelog --latest-version $${charts_ver} --stdout | cat - ../tools_cf/charts_flutter.original.CHANGELOG.md > CHANGELOG.md)

.PHONY: dry-run
dry-run: dry-run_common dry-run_flutter

.PHONY: dry-run_common
dry-run_common:
	$(AT)(cd charts_common_cf ; pub publish --dry-run)

.PHONY: dry-run_flutter
dry-run_flutter:
	 $(AT)(cd charts_flutter_cf; \
	   ../tools_cf/change_common_to_package.sh; \
	   flutter pub publish --dry-run; \
	   ../tools_cf/change_common_to_path.sh)

.PHONY: update-version
update-version:
	$(AT)(charts_ver=$${charts_ver} tools_cf/update_version.sh)

.PHONY: release
release: update-version gen-changelog
	$(AT)( \
	if [[ "$${charts_ver}" == "" ]]; then echo "No 'charts_ver=xxxx' parameter, aborting"; exit 1; fi; \
	git commit -am "Release $${charts_ver}" && \
	make gen-changelog charts_ver=$${charts_ver} && \
	git commit -a --amend -C release && \
	git tag $${charts_ver} && \
	make get test dry-run)

.PHONY: publish
publish: get test publish_common publish_flutter

.PHONY: publish_common
publish_common:
	 $(AT)(cd charts_common_cf ; pub publish)

.PHONY: publish_flutter
publish_flutter:
	 $(AT)(cd charts_flutter_cf; \
	   ../tools_cf/change_common_to_package.sh; \
	   flutter pub publish; \
	   ../tools_cf/change_common_to_path.sh)

