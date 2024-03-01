const splunkjs = require("splunk-sdk");

const config = {
  username: "admin", // Update with actual admin username if different
  password: process.env.SPLUNK_PASSWORD, // Ensure SPLUNK_PASSWORD is set in your environment variables
  scheme: "https",
  host: process.env.SPLUNK_CONTAINER_NAME, // Ensure SPLUNK_CONTAINER_NAME is set in your environment variables
  port: process.env.SPLUNK_MGMT_PORT, // Ensure SPLUNK_MGMT_PORT is set in your environment variables
};

const service = new splunkjs.Service(config);

try {
  service.login(function (err, success) {
    if (err || !success) {
      console.error("Splunk login failed:", err);
      process.exit(2); // Exit with error code to indicate failure
    } else {
      console.log("Splunk login successful");
      process.exit(0); // Exit with success code
    }
  });
} catch (error) {
  console.error("Error occurred:", error);
  process.exit(2); // Exit with error code to indicate failure
}
