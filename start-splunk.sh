#!/bin/sh

SPLUNK_IMAGE=${1:-"splunk/splunk:latest"}
SPLUNK_CONTAINER_NAME=${2:-"so1"}
SPLUNK_APPS_URL=${3-""}
SPLUNK_PASSWORD=${4}
SPLUNK_CLOUD_USERNAME=${5}
SPLUNK_CLOUD_PASSWORD=${6}
SPLUNK_LICENSE_URI=${7}
SPLUNK_APP_PORT=${8:-"8000"}
SPLUNK_MGMT_PORT=${9:-"8089"}
TZ=${10:-"UTC"}

echo "::group::Pulling Splunk image"
docker pull $SPLUNK_IMAGE
if [ $? -ne 0 ]; then
    echo "Error pulling Splunk Docker image"
    exit 2
fi
echo "::endgroup::"

# Log the configurations
echo "::group::Starting Splunk instance"
echo "  - image [$SPLUNK_IMAGE]"
echo "  - container name [$SPLUNK_CONTAINER_NAME]"
echo "  - apps url [$SPLUNK_APPS_URL]"
echo "  - password [$SPLUNK_PASSWORD]"
echo "  - cloud username [$SPLUNK_CLOUD_USERNAME]"
echo "  - cloud password [$SPLUNK_CLOUD_PASSWORD]"
echo "  - license uri [$SPLUNK_LICENSE_URI]"
echo "  - app port [$SPLUNK_APP_PORT]"
echo "  - mgmt port [$SPLUNK_MGMT_PORT]"
echo "  - timezone [$TZ]"
echo ""

# Stop and remove the container if it exists
docker stop $SPLUNK_CONTAINER_NAME
docker rm -f $SPLUNK_CONTAINER_NAME
docker volume rm splunkvar
docker volume rm splunketc

# Create the volumes
docker volume create splunkvar
docker volume create splunketc

docker run --name $SPLUNK_CONTAINER_NAME \
  -e SPLUNK_START_ARGS=--accept-license \
  -e SPLUNK_APPS_URL=$SPLUNK_APPS_URL \
  -e SPLUNKBASE_USERNAME=$SPLUNK_CLOUD_USERNAME \
  -e SPLUNKBASE_PASSWORD=$SPLUNK_CLOUD_PASSWORD \
  -e SPLUNK_PASSWORD=$SPLUNK_PASSWORD \
  -e SPLUNK_LICENSE_URI=$SPLUNK_LICENSE_URI \
  -e TZ=$TZ \
  -p 8000:$SPLUNK_APP_PORT \
  -p 8088:8088 \
  -p 8089:$SPLUNK_MGMT_PORT \
  -p 8191:8191 \
  -p 8065:8065 \
  -p 9887:9887 \
  -p 9997:9997 \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  --volume splunkvar:/opt/splunk/var \
  --volume splunketc:/opt/splunk/etc \
  --restart on-failure \
  --detach \
  --network=host \
  $SPLUNK_IMAGE

if [ $? -ne 0 ]; then
    echo "Error starting Splunk Docker container"
    exit 2
fi
echo "::endgroup::"

# Helper function to wait for Splunk to be started before moving on
wait_for_splunk() {
  echo "::group::Waiting for Splunk to accept connections"
  TIMER=0
  MAX_RETRIES=10 # Number of retries before considering the service unavailable
  RETRY_INTERVAL=20 # Seconds to wait between retries

  # Ensure node is available in the script's environment
  which node
  if [ $? -ne 0 ]; then
    echo "Node.js is not installed. Exiting."
    exit 2
  fi

  export SPLUNK_PASSWORD=$SPLUNK_PASSWORD
  export SPLUNK_CONTAINER_NAME=$SPLUNK_CONTAINER_NAME
  export SPLUNK_MGMT_PORT=$SPLUNK_MGMT_PORT

  until node /checkSplunkAvailability.js
  do
    echo "Attempt $TIMER: Splunk is not available yet."
    sleep $RETRY_INTERVAL
    TIMER=$((TIMER + 1))

    if [ $TIMER -ge $MAX_RETRIES ]; then
      echo "Splunk did not become available within the expected timeframe. Exiting."
      exit 0
    fi
  done

  echo "Splunk is now available."
  echo "::endgroup::"
}

wait_for_splunk

echo "Splunk is up and running on port 8000 for web interface."
