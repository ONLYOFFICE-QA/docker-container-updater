#!/usr/bin/env bash

docker stop 4testing-documentserver-ee docker-container-updater
docker rm 4testing-documentserver-ee docker-container-updater
docker system prune -af
docker build -t docker-container-updater .
docker run --privileged --shm-size=2g --restart=always -itd \
       -v /var/run/docker.sock:/var/run/docker.sock \
       --name docker-container-updater \
       docker-container-updater
