# Use docker:stable as the base image
FROM docker:stable

# Install Node.js and npm
RUN apk add --update nodejs npm

# Copy the start script and package.json to the container
COPY start-splunk.sh /start-splunk.sh
COPY checkSplunkAvailability.js /checkSplunkAvailability.js
COPY package.json /package.json

# Install Splunk SDK and other Node.js dependencies
RUN npm install

# Make the start script executable
RUN chmod +x /start-splunk.sh

# Use root as the user
USER root

# Set the entrypoint to the start script
ENTRYPOINT ["/start-splunk.sh"]
