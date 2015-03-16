#!/usr/bin/env bash

AGENT_DIR="${HOME}/agent"

if [ -z $TEAMCITY_HOSTNAME ]; then
    echo "Fatal error: TEAMCITY_HOSTNAME is not set."
    echo "Launch this container with -e TEAMCITY_HOSTNAME=servername -e TEAMCITY_PORT=port."
    echo
    exit
fi

# See http://tldp.org/LDP/abs/html/devref1.html for description of this syntax.
while ! exec 6<>/dev/tcp/${TEAMCITY_HOSTNAME}/${TEAMCITY_PORT}; do
    echo "$(date) - trying to connect to teamcity-server at ${TEAMCITY_HOSTNAME}..."
    sleep 1
done

# sleep until the agent download is ready
until $(curl --output /dev/null --silent --head --fail http://${TEAMCITY_HOSTNAME}:${TEAMCITY_PORT}/update/buildAgent.zip); do
    printf '.'
    sleep 5
done

# sleep some more to let the server initialize
sleep 10

if [ ! -d "$AGENT_DIR" ]; then
    cd ${HOME}
    echo "Setting up TeamCityagent for the first time..."
    echo "Agent will be installed to ${AGENT_DIR}."
    mkdir -p $AGENT_DIR
    wget http://$TEAMCITY_HOSTNAME:$TEAMCITY_PORT/update/buildAgent.zip
    unzip -q -d $AGENT_DIR buildAgent.zip
    rm buildAgent.zip
    chmod +x $AGENT_DIR/bin/agent.sh
    echo "serverUrl=http://${TEAMCITY_HOSTNAME}:${TEAMCITY_PORT}" > $AGENT_DIR/conf/buildAgent.properties
    echo "name=" >> $AGENT_DIR/conf/buildAgent.properties
    echo "workDir=../work" >> $AGENT_DIR/conf/buildAgent.properties
    echo "tempDir=../temp" >> $AGENT_DIR/conf/buildAgent.properties
    echo "systemDir=../system" >> $AGENT_DIR/conf/buildAgent.properties
else
    echo "Using agent at ${AGENT_DIR}."
fi
$AGENT_DIR/bin/agent.sh run
