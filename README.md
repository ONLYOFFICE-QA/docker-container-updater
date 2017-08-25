# docker-container-updater
Stuff to auto-update docker container on server

```
docker build -t docker-container-updater .
docker run --privileged --restart=always -itd -v /var/run/docker.sock:/var/run/docker.sock --name docker-container-updater docker-container-updater
```
