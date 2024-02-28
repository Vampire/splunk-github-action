<div align="center">
  <a href="https://datagon.ai">
    <img width="200" style="max-width:100%;" src="https://datagon.ai/wp-content/uploads/2023/09/Datagon-AI-Logo-Quadratic.png" />
  </a>
  <br/>
  <br/>
  <p>
    <h3>Splunk in GitHub Actions</h3>
  </p>
  <p>
    Start a Splunk instance in your GitHub Actions.
  </p>
  <br/>
  <p>
    <a href="#usage"><strong>Usage</strong></a>
  </p>
  <br/>
  <br/>
  <p>
    <em>Follow <a href="https://www.linkedin.com/company/datagon-ai-gmbh">Datagon AI</a> for updates!</em>
  </p>
</div>

---

## Introduction

This GitHub Action starts a Splunk instance. By default, the Splunk instace is available on the default port `8000` with management port `8089`. You can configure a custom port using the `splunk-app-port` and `splunk-mgmt-port` input. The examples show how to use a custom port.

## Usage

Here’s an exemplary GitHub Action using a Splunk instance to test a Node.js app:

```yaml
name: Run tests

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Git checkout
        uses: actions/checkout@v3

      - name: Use Node.js 20
        uses: actions/setup-node@v4
        with:
          node-version: "20.11.0"

      - name: Start Splunk
        uses: datagon-ai-gmbh/splunk-github-action@1.0.0
        with:
          splunk-image: "splunk/splunk:latest"
          splunk-apps-url: ""
          splunk-password: ${{ secrets.SPLUNK_PASSWORD }}
          splunk-cloud-username: ${{ secrets.SPLUNK_CLOUD_USERNAME }}
          splunk-cloud-password: ${{ secrets.SPLUNK_CLOUD_PASSWORD }}
          splunk-license-uri: ${{ secrets.SPLUNK_LICENSE_URI }}
          splunk-app-port: 8000
          splunk-mgmt-port: 8089
          timezone: "Europe/Berlin"

      - run: npm install

      - run: npm test
        env:
          CI: true
```

### Using a Custom Splunk Port

You can start the Splunk instance on a custom port. Use the `splunk-app-port: 12345` input to configure port `12345` for Splunk. Replace `12345` with the port you want to use in your test runs. Same goes for `splunk-mgmt-port`.

The following example starts a MongoDB server on ports `20345` and `20346`:

```yaml
name: Run tests

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [18.x, 20.x]
        mongodb-version: ["4.2", "4.4", "5.0", "6.0"]

    steps:
      - name: Git checkout
        uses: actions/checkout@v3

      - name: Use Node.js 20
        uses: actions/setup-node@v4
        with:
          node-version: "20.11.0"

      - name: Start Splunk
        uses: datagon-ai-gmbh/splunk-github-action@1.0.0
        with:
          splunk-image: "splunk/splunk:latest"
          splunk-apps-url: ""
          splunk-password: ${{ secrets.SPLUNK_PASSWORD }}
          splunk-cloud-username: ${{ secrets.SPLUNK_CLOUD_USERNAME }}
          splunk-cloud-password: ${{ secrets.SPLUNK_CLOUD_PASSWORD }}
          splunk-license-uri: ${{ secrets.SPLUNK_LICENSE_URI }}
          splunk-app-port: 20345
          splunk-mgmt-port: 20346
          timezone: "Europe/Berlin"

      - name: Install dependencies
        run: npm install

      - name: Run tests
        run: npm test
        env:
          CI: true
```

## License

MIT © [Datagon AI GmbH](https://datagon.ai)

---

> [datagon.ai](https://datagon.ai) &nbsp;&middot;&nbsp;
> GitHub [@Datagon AI](https://github.com/Datagon-AI-GmbH/) &nbsp;&middot;&nbsp;
> LinkedIn [@Datagon AI](https://www.linkedin.com/company/datagon-ai-gmbh)
