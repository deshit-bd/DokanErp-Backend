# dokan_erp

Requires Flutter 3.27+ and Dart 3.4+.

A new Flutter project.

## API configuration

The app does not ship with a developer machine's private IP address. Enable
the API explicitly at run time:

```sh
flutter run \
  --dart-define=DOKAN_API_ENABLED=true \
  --dart-define=DOKAN_API_BASE_URL=http://YOUR_SERVER_IP:4000
```

Production builds require an HTTPS API base URL.

Architecture rules and the required API integration flow are documented in
[`docs/CLEAN_ARCHITECTURE.md`](docs/CLEAN_ARCHITECTURE.md).

The app is offline-first: SharedPreferences stores local feature snapshots,
the latest successful GET responses, and safe queued mutations. Queued changes
sync automatically after the API becomes reachable.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
