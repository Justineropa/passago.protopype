# PassaGo driver app (Flutter)

Android app for tricycle drivers. It has exactly the six established screens,
built from the Stitch designs in the parent folder:

1. Welcome
2. Driver Login
3. Schedule Selection (AM / PM)
4. Driver Dashboard
5. Passenger Distribution
6. Trip Records

Screens 4 to 6 share a bottom navigation bar. Everything uses placeholder
data for now, and the Bluetooth button is simulated.

## First-time setup

This folder contains the Dart code (`lib/`, `test/`, `pubspec.yaml`) but not
the generated Android project files. Create those with Flutter, then copy the
code over them. Run these in the folder where you keep your projects:

```
flutter create --platforms=android --org com.passago passago_app_new
```

Then copy these three things from this repo's `passago_app/` folder into
`passago_app_new/`, replacing what is there:

- `lib/` (replace the whole folder)
- `test/` (replace the whole folder)
- `pubspec.yaml`

Then, inside `passago_app_new/`:

```
flutter pub get
flutter test
flutter run
```

`flutter run` works on an Android emulator or a USB-connected phone. Commit
the generated `android/` folder to GitHub too, so you only do this once.

If `flutter pub get` complains about `flutter_lints`, run
`flutter pub add --dev flutter_lints` and try again.

## How to try it

1. Welcome, then Log in. Any Driver ID of 3 or more characters and any 6-digit
   PIN works. This is a prototype, there is no real authentication yet.
2. Pick the AM or PM shift and start it. The passenger count resets to 0.
3. On the Dashboard, wait about a second for "Handlebar button connected",
   then tap "Simulate handlebar click". The count goes up by one, the queue
   position updates, and the simulated device receives an acknowledgment.
4. On Distribution, the queue is sorted fewest passengers first. Accepting
   the sample trip offer sets your status to On trip and adds a trip record.

## Folder guide

```
lib/
  main.dart                       app start
  theme.dart                      colors and theme (palette from the designs)
  data/mock_data.dart             ALL placeholder data (names, trips, terminal)
  state/app_state.dart            shared state: count, shift, queue, offer
  services/
    passenger_button_service.dart Bluetooth button interface + simulated device
  widgets/common.dart             logo placeholder, buttons, cards, animation
  screens/                        the six screens + main_shell.dart (bottom nav)
test/                             logic tests and one smoke test
```

## Bluetooth button (Phase 3, not built yet)

The app only talks to the hardware through `PassengerButtonService`. Today
`SimulatedButtonService` stands in for the ESP32. The flow already matches
your plan:

1. The device sends an event with a **unique id** for each button press.
2. The app counts it once, even if the same id arrives again (for example
   after a reconnect), then calls `acknowledge(id)`.
3. The ESP32 shows REGISTERED on the OLED only after that acknowledgment.

Still to do, and it needs the firmware side decided first:

- Choose the BLE service and characteristic design with the ESP32 sketch
  (one characteristic the ESP32 notifies with the event id, one the phone
  writes the acknowledged id to, and optionally one for battery level).
- Write `BleButtonService implements PassengerButtonService` using the
  `flutter_blue_plus` package (`flutter pub add flutter_blue_plus`).
- Add Bluetooth permissions to `android/app/src/main/AndroidManifest.xml`
  and request them at runtime (`BLUETOOTH_SCAN` and `BLUETOOTH_CONNECT` on
  Android 12 and newer).
- The Android emulator has no Bluetooth, so the real test needs a phone.
- The ESP32 needs to keep its event counter across power loss, or the ids
  could repeat after a restart.

## Differences from the Stitch designs (on purpose)

- **No Notifications screen and no Profile tab.** The handoff fixes the app
  at six screens, and the Profile link in the design went nowhere.
- **Welcome wording.** "Every driver gets equal trips" was replaced with
  wording that says drivers with fewer passengers are prioritized. The
  handoff says not to promise equal distribution.
- **Removed invented details:** the "Accredited by Poblacion TODA Office"
  line, the helpline phone number, the "+12.4% vs last week" figure, the
  "turn share" percentage, the Export log button and the simulated
  loading/skeleton blocks.
- **Numbers are calculated, not typed in.** Queue position, "of N available
  drivers", terminal average and the trip totals come from the data, so they
  always agree with each other. The design had Ramon as Body 127 and 102.
- **Logo.** `PgLogo` in `widgets/common.dart` is a plain "PG" placeholder.
  Replace it with the final tricycle emblem when the master logo is done.
- **Home-screen fairness text** says drivers with fewer passengers are
  prioritized. Nothing in the app claims equal passenger counts or income.
