# ResQ bug report

## Verification

- Dart analysis reported **2 compile errors, 10 warnings, and 100 informational diagnostics**.
- The Flutter smoke test stopped while building the asset bundle because `assets/.env` was missing. Runtime flows were therefore unavailable for testing.
- The SOS and Firestore findings below come from reviewing the source. The deployed Firestore rules were unverified.

## Build blockers

| Finding | Impact and evidence |
| --- | --- |
| Smart Scan fails to compile | The code reads `label` and `confidence` from a value typed as `Object`. [Smart Scan screen](lib/screens/smart_scan_screen.dart#L194) |
| Required environment asset is missing | Flutter declares `assets/.env` in the bundle, and startup loads it before Firebase initializes. The missing file blocked the smoke test. [Asset declaration](pubspec.yaml#L60) · [Startup](lib/main.dart#L37) |

## Bugs found in code review

| Severity | Finding | Impact and evidence |
| --- | --- | --- |
| Critical | Offline SOS can disappear while the app reports success | On platforms without mesh support, the queue method returns before saving the report. The UI still says “SOS TRANSMITTED” and claims a response team is being dispatched. [Offline queue](lib/services/offline_mesh_service.dart#L35) · [Confirmation dialog](lib/screens/sos_screen.dart#L795) |
| Critical | SOS can report the wrong location | If GPS is unavailable or the location hasn’t loaded, the app submits hard-coded Los Angeles coordinates. [SOS location](lib/screens/sos_screen.dart#L748) |
| Critical if deployed | Firestore rules allow unauthenticated reads and writes | The checked-in rules let unauthenticated users read and modify SOS reports, user records, and alerts. [Firestore rules](firestore.rules#L4) |
| High | Queued SOS reports remain pending when connectivity returns | The only call to sync queued reports runs after another online SOS is submitted. [SOS submission](lib/screens/sos_screen.dart#L764) |
| High | SOS photos and videos are missing from submitted reports | The submission saves filenames only. Responders cannot retrieve the media through the report. [SOS attachments](lib/screens/sos_screen.dart#L752) |
