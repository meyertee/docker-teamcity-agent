# TeamCity Agent Dockerfile
# docker run -e TEAMCITY_SERVER=http://teamcity:8111 -dt -p 9090:9090 meyertee/teamcity-agent

FROM java:8

MAINTAINER Thomas Meyer <thomas@meyertee.com>

ENV TEAMCITY_HOSTNAME teamcity
ENV TEAMCITY_PORT 8111

#ENV DOCKER_HOST unix:///var/run/docker.sock
ENV DOCKER_HOST tcp://127.0.0.1:2375
ENV REGISTRY_HOSTNAME registry
ENV REGISTRY_PORT 5000
ENV REGISTRY_ADDRESS http://registry:5000

ADD setup-agent.sh /scripts/setup-agent.sh

RUN apt-get update && apt-get install -y wget unzip sudo docker.io
RUN adduser teamcity
RUN echo "DOCKER_OPTS=\"-H=$DOCKER_HOST --insecure-registry $REGISTRY_HOSTNAME:$REGISTRY_PORT\"" >> /etc/default/docker

VOLUME /var/lib/docker
EXPOSE 9090
CMD service docker start; sudo -u teamcity -s -- sh -c "TEAMCITY_HOSTNAME=${TEAMCITY_HOSTNAME} TEAMCITY_PORT=${TEAMCITY_PORT} bash /scripts/setup-agent.sh"
