# Change log

## master (unreleased)

### New features

* Show more version info in logs
* Do not update `SharedFunctional` repo
* Use default branch for `OnlineDocuments` repo
* Enable autostart of `ds:example`
* Remove usage of `docker-hub-hook-catcher`
* Increase timeout for version update monitoring
* Add `dependabot` config
* Add rubocop check in CI
* Add `markdownlint` check in CI
* Add `yard` task to check that all code is documented
* Enable `WOPI` by default
* Add https support on default 443 port
* Add `yamllint` check in CI

### Fixes

* Fix `markdownlint` failure because of old `nodejs` in CI

### Changes

* Use actual `bundler` in `gems.locked`
* Init and updating using bash script
* Check `dependabot` at 8:00 Moscow time daily
* Use latest `ruby-3.2` to check code-style
