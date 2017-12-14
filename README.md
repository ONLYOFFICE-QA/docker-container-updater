# docker-container-updater
Stuff to auto-update docker container on server

```
docker system prune -af
docker volume rm $(docker volume ls -qf dangling=true)
docker build -t docker-container-updater .
docker run --privileged --shm-size=2g --restart=always -itd -v /var/run/docker.sock:/var/run/docker.sock --name docker-container-updater docker-container-updater
```
