# docker-container-updater

Utility to auto-update `onlyoffice/4testing-documentserver-ee`
docker container on server

## Initialization

```shell script
bash init.sh
```

You can use this script in any problematic situation - it have auto-cleanup.\
So if something stuck, not working, etc - just use this script

## Description

Every 5 minutes the script checks `last_updated` date
of `onlyoffice/4testing-documentserver-ee` docker hub repo.\
If `last_updated` date is different than previous stored one - it will execute:

1. Stop all current running docker containers and cleanup space
2. Start a new container from newer `latest` version of docker repo
3. Run `sanity` automation level tests for new container
4. As soon as sanity is done - back to step 0 - checking if any new version exists.

Please note that during step 3 - sanity tests, the script will not check for updates.\
Sanity tests are usually run for couple hours, so if several
versions of DocumentServer released one
by one - probably only first one and last run will be installed.
