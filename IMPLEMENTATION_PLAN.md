# ResQ bug fixes and rollout plan

This document follows the findings in [BUG_REPORT.md](BUG_REPORT.md).

## Implemented

| Finding | Change |
| --- | --- |
| Smart Scan compile errors | Restored the `List<ImageLabel>` type for ML Kit image labels. [Smart Scan](lib/screens/smart_scan_screen.dart) |
| Missing environment asset | Removed the required `assets/.env` bundle entry. Gemini and Crisis News now accept optional Dart build configuration. Moved web-only WebView registration behind a conditional import so the native smoke test can compile. [Startup](lib/main.dart) · [Build settings](pubspec.yaml) |
| Lost offline SOS and misleading confirmation | Save the report before acknowledging it. The app uses the existing SQLite queue on Android and iOS, IndexedDB on the web, and local preferences on other supported desktop targets. The confirmation says the SOS was saved locally and delivery is pending. Mesh broadcast remains best-effort. [SOS screen](lib/screens/sos_screen.dart) · [Queue and delivery](lib/services/offline_mesh_service.dart) |
| Incorrect SOS coordinates | Store a null location when GPS is unavailable and tell the user. Legacy queued reports containing the exact old fallback coordinates are also treated as having no location. [SOS screen](lib/screens/sos_screen.dart) · [Queue and delivery](lib/services/offline_mesh_service.dart) |
| Missing automatic sync | Retry when connectivity or authentication changes and every 30 seconds while the app is open. The report keeps its original timestamp and document ID across retries. [Queue and delivery](lib/services/offline_mesh_service.dart) |
| Missing media uploads | Keep attachment bytes with the queued report, publish the SOS record first, then upload photos and videos to Firebase Storage and add their storage paths to the report. Failed transfers stay queued. Attachments have a combined 20 MB limit. The app does not have an attachment viewer. [SOS screen](lib/screens/sos_screen.dart) · [Queue and delivery](lib/services/offline_mesh_service.dart) |
| Public Firebase access | Use Firebase anonymous authentication for device profiles. Firestore rules restrict profiles to their owners and SOS reports and media to their owners and authenticated responders. The map uses the same access policy. [Firestore rules](firestore.rules) · [Storage rules](storage.rules) · [Map](lib/screens/live_map_screen.dart) |

## Verification

- Dart analysis reported zero compile errors, seven warnings, and 100 informational diagnostics.
- The Flutter smoke test and the desktop offline SOS queue regression test passed.
- The Flutter web release build succeeded with a Cupertino icon font warning.
- Firebase role enforcement, live uploads, browser queue persistence, and physical-device mesh reception still need the staging checks below.

## Rollout and acceptance checks

1. Enable Firebase Anonymous Authentication and provision the Cloud Storage bucket in the staging project. Assign the `responder: true` custom claim to authorized responder accounts using the Admin SDK. Ordinary users see their own reports on the map.
2. Review legacy Firebase data before promoting the rules. Existing device-only profiles use local IDs without verified ownership, so users with those profiles will need to register again. Use a trusted server-side migration for profiles whose ownership you can establish. Older SOS records without `ownerUid` are visible to responders only. Existing filename-only records cannot supply attachment bytes.
3. Deploy the Firestore rules, the `ownerUid`/`timestamp` index, the Storage rules, and the compatible app together. Confirm the index has finished building. The repository changes do not change the deployed Firebase project.
4. In staging, sign in on two devices and try profile, SOS, and attachment access as the owner, a different user, a responder, and a signed-out client. Only the intended roles should have access.
5. Turn off connectivity, deny location, and submit an SOS with a photo and video. Confirm the local save message, restart the app, restore connectivity, and verify that one Firestore report appears with a null location and the original submission time. Simulate a Storage failure and confirm the SOS record still arrives and the attachments sync later. Repeat on a browser with IndexedDB and on a physical mobile device. Verify actual peer reception separately if relying on mesh delivery.
6. For builds that need Gemini or Crisis News, supply `GEMINI_API_KEY`, `GEMINI_MODEL`, and `NEWS_API_KEY` as applicable via `--dart-define` or `--dart-define-from-file`. Client build values can be inspected in distributed apps.
