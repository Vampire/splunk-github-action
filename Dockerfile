FROM docker:stable
COPY start-splunk.sh /start-splunk.sh
RUN chmod +x /start-splunk.sh
ENTRYPOINT ["/start-splunk.sh"]
