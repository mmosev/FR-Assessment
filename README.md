# Fire Stopping Assessment App

Android (and iOS) app for recording fire stopping penetrations and generating professional PDF reports.

## Features
- Create projects and multiple penetrations
- Full form matching the original tick sheet
- Photo attachment (camera + gallery)
- **Draw signature on screen** (included in PDF)
- **Company logo + company name** on every PDF (set in Settings)
- **Generate PDF for a single penetration** or **the whole project**
- Share PDF via email, WhatsApp, Drive, etc.
- **Dark mode**
- All data stored locally on the device

## How to build & install

1. Install Flutter: https://docs.flutter.dev/get-started/install
2. Open a terminal in this folder and run:

```bash
flutter pub get
flutter build apk --release
```

3. The APK will be at:
```
build/app/outputs/flutter-apk/app-release.apk
```

4. Copy the APK to your phone and install it.

## Settings
Open the gear icon on the home screen to:
- Toggle Dark mode
- Set Company name
- Upload Company logo (appears on all PDFs)

## Project structure
```
lib/
  main.dart
  models/
  screens/
    projects_list_screen.dart
    project_detail_screen.dart
    penetration_form_screen.dart
    settings_screen.dart
  services/
    storage_service.dart
    pdf_service.dart
    settings_service.dart
```
