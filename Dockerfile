FROM onlyofficetestingrobot/nct-at-testing-node

MAINTAINER Pavel.Lobashov "shockwavenn@gmail.com"

RUN sudo apt-get update && \
    sudo apt-get -y install \
            apt-transport-https \
            ca-certificates \
            curl \
            software-properties-common
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
RUN sudo add-apt-repository \
            "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
            $(lsb_release -cs) \
            stable"
RUN sudo apt-get update && \
    sudo apt-get -y install docker-ce
RUN sudo usermod -aG docker nct-at
COPY . /home/nct-at/docker-container-updater
WORKDIR /home/nct-at/docker-container-updater
CMD bash -c "ruby main.rb"
