const splunkjs = require("splunk-sdk");

const config = {
  username: "admin", // Update with actual admin username if different
  password: process.env.SPLUNK_PASSWORD, // Ensure SPLUNK_PASSWORD is set in your environment variables
  host: "127.0.0.1",
  port: String(process.env.SPLUNK_MGMT_PORT), // Ensure SPLUNK_MGMT_PORT is set in your environment variables
};

const service = new splunkjs.Service(config);

const checkSplunkAvailability = async () => {
  try {
    const answer = await service.login();
    console.log("Splunk is available:", answer);
  } catch (error) {
    console.error("Error occurred:", error);
    process.exit(2); // Exit with error code to indicate failure
  }
};

checkSplunkAvailability();
