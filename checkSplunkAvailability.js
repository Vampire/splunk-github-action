const splunkjs = require("splunk-sdk");

const config = {
  username: "admin", // Update with actual admin username if different
  password: process.env.SPLUNK_PASSWORD, // Ensure SPLUNK_PASSWORD is set in your environment variables
  scheme: "https",
  host: "so1", // Update with your Splunk container's hostname or IP
  port: "8089", // Update if using a custom management port
};

const service = new splunkjs.Service(config);

service.login(function (err, success) {
  if (err || !success) {
    console.error("Splunk login failed:", err);
    process.exit(2); // Exit with error code to indicate failure
  } else {
    console.log("Splunk login successful");
    process.exit(0); // Exit with success code
  }
});
