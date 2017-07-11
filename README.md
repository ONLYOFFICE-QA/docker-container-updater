# docker-container-updater
Stuff to auto-update docker container on server

`docker run --privileged --restart=always -itd -v /var/run/docker.sock:/var/run/docker.sock docker-container-updater`
