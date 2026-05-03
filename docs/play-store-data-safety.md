# Google Play Data Safety Draft

Use this as a draft when completing Play Console > App content > Data safety.

## Data collection

PingFlow does not collect data for advertising and does not sell user data.

Data processed for app functionality:

- App activity: diagnostic history and diagnostic results.
- Device or other IDs: none.
- Location: none.
- Personal info: none in the current version.
- App info and performance: none through analytics SDKs.
- Network data: domains or IP addresses entered by the user, public IP lookup, latency, traceroute, speed test results.

## Sharing

PingFlow may transmit user-entered domains or IP addresses to the PingFlow backend API only to perform requested diagnostics.

PingFlow may contact a public IP lookup service to display the user's public IP address.

No data is shared for advertising or sale.

## Security practices

- Data is transmitted over HTTPS for production backend requests.
- Users can delete local diagnostic history inside the app.
- The app does not require account creation.

## Notes for Play Console answers

- Mark data as collected only when Play Console treats backend processing as collection.
- Mark diagnostic host/IP data as used for app functionality.
- Do not declare purchases unless in-app purchases are added back later.
- Do not declare ads because the app does not include ads.
