#!/bin/sh

SPLUNK_IMAGE=${1:-"splunk/splunk:latest"}
SPLUNK_APPS_URL=${2}
SPLUNK_PASSWORD=${3}
SPLUNK_CLOUD_USERNAME=${4}
SPLUNK_CLOUD_PASSWORD=${5}
SPLUNK_LICENSE_URI=${6}
SPLUNK_APP_PORT=${7:-"8000"}
SPLUNK_MGMT_PORT=${8:-"8089"}
TZ=${9:-"UTC"}

# Log the configurations
echo "::group::Starting Splunk instance"
echo "  - image [$SPLUNK_IMAGE]"
echo "  - apps url [$SPLUNK_APPS_URL]"
echo "  - password [$SPLUNK_PASSWORD]"
echo "  - cloud username [$SPLUNK_CLOUD_USERNAME]"
echo "  - cloud password [$SPLUNK_CLOUD_PASSWORD]"
echo "  - license uri [$SPLUNK_LICENSE_URI]"
echo "  - app port [$SPLUNK_APP_PORT]"
echo "  - mgmt port [$SPLUNK_MGMT_PORT]"
echo "  - timezone [$TZ]"
echo ""

docker run --name so1 \
  -e SPLUNK_START_ARGS=--accept-license \
  -e SPLUNK_APPS_URL=$SPLUNK_APPS_URL \
  -e SPLUNKBASE_USERNAME=$SPLUNK_CLOUD_USERNAME \
  -e SPLUNKBASE_PASSWORD=$SPLUNK_CLOUD_PASSWORD \
  -e SPLUNK_LICENSE_URI=$SPLUNK_LICENSE_URI \
  -e SPLUNK_PASSWORD=$SPLUNK_PASSWORD \
  -e TZ=$TZ \
  -p 8000:$SPLUNK_APP_PORT \
  -p 8088:8088 \
  -p 8089:$SPLUNK_MGMT_PORT \
  -p 8191:8191 \
  -p 8065:8065 \
  -p 9887:9887 \
  -p 9997:9997 \
  --volume splunkvar:/opt/splunk/var \
  --volume splunketc:/opt/splunk/etc \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  --restart on-failure \
  --detach \
  $SPLUNK_IMAGE

if [ $? -ne 0 ]; then
    echo "Error starting Splunk Docker container"
    exit 2
fi
echo "::endgroup::"

# Helper function to wait for Splunk to be started before moving on
wait_for_splunk () {
  echo "::group::Waiting for Splunk to accept connections"
  sleep 1
  TIMER=0

  until $(curl --output /dev/null --silent --head --fail http://localhost:8000)
  do
    echo "."
    sleep 1
    TIMER=$((TIMER + 1))

    if [[ $TIMER -eq 240 ]]; then
      echo "Splunk did not initialize within 240 seconds. Exiting."
      exit 2
    fi
  done
  echo "::endgroup::"
}

wait_for_splunk

echo "Splunk is up and running on port 8000 for web interface."
