# Ciao Delivery (Flutter)

Cross-platform client for the Ciao Spring Boot API (Android, iOS).

## Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) stable (3.24+ recommended)
- **Android:** Android SDK / emulator or device (Java 17 for Gradle)
- **iOS (macOS only):** Xcode 15+, CocoaPods (`sudo gem install cocoapods`)

## First-time setup

From this `mobile` directory:

```bash
flutter pub get
```

That generates `ios/Flutter/Generated.xcconfig`, `ios/Runner/GeneratedPluginRegistrant.*`, and plugin registrants for Android (those files are gitignored—every clone needs `flutter pub get` once).

If `android/` or `ios/` ever look incomplete compared to a fresh Flutter app, repair with:

```bash
# Bash (macOS / Linux / Git Bash)
./tool/ensure_platforms.sh

# PowerShell
.\tool\ensure_platforms.ps1
```

Or manually:

```bash
flutter create . --project-name ciao_delivery --platforms=android,ios
flutter pub get
```

## API base URL

| Where you run the app | Default base URL (no `--dart-define`, no saved setting) |
|------------------------|------------------------------------------------------------|
| Android emulator       | `http://10.0.2.2:8081` (host machine `localhost`)         |
| iOS Simulator          | `http://127.0.0.1:8081`                                   |
| Physical device        | Use your PC’s LAN IP, e.g. `http://192.168.1.5:8081`      |

Override in the app: **Settings** (gear on customer home), or at launch:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.5:8081
```

## HTTP in development

- **Android:** `android:usesCleartextTraffic="true"` and `networkSecurityConfig` are already set for dev HTTP.
- **iOS:** `Info.plist` includes `NSAppTransportSecurity` → `NSAllowsLocalNetworking` so local HTTP (simulator → host) is allowed. Use HTTPS in production.

## Run

```bash
# Pick a device
flutter devices
flutter run
```

**iOS:** Prefer `flutter run`; opening `ios/Runner.xcworkspace` in Xcode works after at least one successful `flutter pub get` (and usually an implicit `pod install` via Flutter).

## Test users

Register three roles (phones must start 6–9, 10 digits), or seed via Postman:

| Role        | Example phone |
|------------|-----------------|
| USER       | 9876543210      |
| RESTAURANT | 9876543211      |
| DELIVERY   | 9876543212      |
