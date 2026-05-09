Sprints :
1. [x] Sprint 8 — Mobile UX Polish & Operational Feed Clarity

2. [x] Sprint 9 Plan — Rail Context Model: Services, Stations, Routes & Staff Presence


HOW TO START:

Exact order to restart and finish cleanly:

1. Confirm branch and state
- git checkout feat/rail-context-model
- git status

2. Start infra
- docker compose up -d
- optional check: pg_isready -h localhost -p 5433

3. Run backend gates
- cargo fmt
- cargo clippy -- -D warnings
- cargo test

4. Run mobile gates
- cd mobile
- flutter analyze
- flutter test
- cd ..

5. Run smoke tests with backend running

- terminal A: cargo run

- terminal B:
  
  - python3 gate11_mobile_api.py
  
  - curl -s -o /dev/null -w "%{http_code}\n" http://localhost:3000/rail/services
  
  - curl -s -o /dev/null -w "%{http_code}\n" http://localhost:3000/dashboard/rail/services


Can you run Android/iOS emulators now?
Yes.

iOS Simulator on Mac:
1. Keep backend running on host at localhost:3000.
2. Run:
- cd mobile
- flutter emulators
- flutter emulators --launch apple_ios_simulator
- flutter run -d ios

Why it failed:

flutter run -d ios is not a valid target on your machine.
Flutter looked for a device literally named ios, found none, and listed your real simulator device instead.
Use this exact sequence from the mobile folder:

flutter devices
flutter run -d 9AC938F7-0AD0-456D-B3E5-9A13424BBEF0
Or by name:

flutter run -d "iPhone 16e"
If it still does not attach:

Open Simulator and ensure iPhone 16e is fully booted (not just opened).
Run flutter devices again and confirm it shows as connected.
Then run flutter run -d "iPhone 16e".

3. Your current API base URL in constants.dart is localhost:3000, which works for iOS simulator.

Android Emulator on Mac:
1. Android emulator cannot use localhost to reach your Mac host backend.
2. Change API base URL in constants.dart:
- from http://localhost:3000
- to http://10.0.2.2:3000
3. Then run:
- cd mobile
- flutter emulators --launch <android_emulator_id>
- flutter run -d <android_device_id>
4. Revert the constant after Android testing if you want iOS/local behavior unchanged.

If you want, I can do the remaining repo-cleanup work for you now: archive Sprint 9 specs, inspect the 2 unstaged backend diffs, and leave you with an exact final git add/commit command for a clean PR.