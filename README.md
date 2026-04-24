# ECHO — Flutter App

Dark-themed disaster response app with 8 screens matching the Stitch/ECHO design.

## Screens
- `/` → Signup/Login
- `/home` → Dashboard (SOS hero, family safety, local grid map, diagnostics)
- `/sos` → SOS Report form
- `/map` → Live Tactical Map
- `/community` → Peer Portal (community help)
- `/local` → Local Incidents Dashboard
- `/disaster` → Disaster Mode Protocol
- `/war` → War Mode Protocol

## Setup

### 1. Install dependencies
```bash
flutter pub get
```

### 2. Run on device / emulator
```bash
# See connected devices
flutter devices

# Run on Chrome (web)
flutter run -d chrome

# Run on Android emulator
flutter run -d emulator-5554

# Run on iOS simulator
flutter run -d iPhone
```

### 3. Build APK
```bash
flutter build apk --release
```

### 4. Build for web (localhost)
```bash
flutter build web
cd build/web
python3 -m http.server 8080
# Open: http://localhost:8080
```

## Dependencies
Only two packages needed (both in pubspec.yaml):
- `google_fonts: ^6.2.1`
- `flutter_animate: ^4.5.0`

Run `flutter pub get` and you're done — no extra setup.

## Design Notes
- Background: `#131313`
- Primary: `#FFFFFF`
- Error: `#FFB4AB` / Error Container: `#93000A`
- Fonts: SpaceGrotesk (headlines) + Inter (body)
- All maps are `CustomPaint` grids (no map API key needed)
