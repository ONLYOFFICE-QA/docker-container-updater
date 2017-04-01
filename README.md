# docker-container-updater
Stuff to auto-update docker container on server

`docker run --privileged --restart=always -it -v /var/run/docker.sock:/var/run/docker.sock -v $HOME/.docker/config.json:/home/nct-at/.docker/config.json docker-container-updater`