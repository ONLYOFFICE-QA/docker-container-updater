FROM onlyofficetestingrobot/nct-at-testing-node

MAINTAINER Pavel.Lobashov "shockwavenn@gmail.com"

RUN apt-get update && \
    apt-get -y install \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common
RUN curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add -
RUN add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
        $(lsb_release -cs) \
        stable"
RUN apt-get update && \
    apt-get -y install docker-ce
COPY . /home/nct-at/docker-container-updater
WORKDIR /home/nct-at/docker-container-updater
CMD bash -c "ruby main.rb"
