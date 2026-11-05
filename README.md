# FoodLoop Android prototype

## Included
- Dark mode with green accents
- Demo login with Student / Cafeteria role selector
- Student Discover screen, search and dietary filters
- Food details and portion selector
- Local reservation flow and My Pickups screen
- My Impact and Profile screens
- Cafeteria surplus entry screen

## Run
Install Flutter SDK and Android Studio with Android SDK. Open this folder in a terminal:

```bash
flutter pub get
flutter run
```

Build a debug APK:
```bash
flutter build apk --debug
```
APK: `build/app/outputs/flutter-apk/app-debug.apk`

## Important prototype limitations
This first milestone is a local interactive UI prototype. Login is not real college-email verification; records are in memory and are not shared between phones. The reservation code is demo text, not a scannable QR token. Cafeteria submission is a UI placeholder. Do not use this build for actual food distribution.

## Production integration plan
1. Confirm official college email domain(s) with college IT. Do not guess the domain.
2. Create Firebase project and register Android application.
3. Configure FlutterFire (`flutterfire configure`).
4. Add firebase_core, firebase_auth, cloud_firestore and firebase_messaging.
5. Enable email/password authentication and email verification. Enforce allowed domains and roles using trusted backend rules; client-side checks alone are not security.
6. Firestore collections: users, food_batches, reservations, collection_points, audit_logs.
7. Use transactions or server-side functions for atomic reservation, preventing oversubscription.
8. Generate random server-side QR credentials and allow only authorised staff to verify physical handover.
9. Add push notifications and expiry jobs.
10. Add Python demand forecasting and analytics after the core flow is reliable.

## Suggested team split
- Member 1: Flutter UI and student screens
- Member 2: Firebase authentication and Firestore
- Member 3: reservations, QR and cafeteria workflow
- Member 4: prediction, notifications, integration and testing
