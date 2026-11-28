# PassaGo driver app (Flutter)

Android app for tricycle drivers. Six main screens, built from the Stitch
designs, plus a few secondary screens and pop-ups:

1. Welcome
2. Driver Login
3. Schedule Selection (AM / PM shift and daily quota)
4. Driver Dashboard
5. Passenger Distribution (the terminal line)
6. Trip Records

Secondary screens: Trip mode, QR check-in, Shift summary, Settings,
permission explanations. Pop-ups: raise quota, end shift, leave queue,
Bluetooth pairing.

This is a school prototype. Everything runs on one phone with sample data,
and the Bluetooth button and the QR camera are simulated for now.

## How the app behaves

- The driver starts an AM or PM shift and sets a **daily quota**. The quota
  can be raised during the shift, never lowered.
- To join the **queue** the driver scans the terminal QR code (simulated for
  now). New drivers go to the end of the line.
- The line stays in **arrival order**. The driver marked **Next** is chosen
  from the first 3 in line: the one with the fewest passengers, and nobody is
  skipped more than twice. The app only shows this. It cannot control who
  gets a passenger.
- Passengers are counted with the **+1 button** in the app or the physical
  button. The app works with no device at all.
- The **first registered passenger starts a trip**, from the queue or from
  the street. The app switches to **Trip mode** (big count, big +1,
  press-and-hold **End trip**).
- The shift ends when the **quota is reached** (after the current trip), when
  the driver ends it, or when the **scheduled hours** run out. A summary is
  shown.
- A driver on break is out of the queue and rejoins at the end.

## First-time setup

The repo has the Dart code but not the generated Android project files.
Generate them once, inside this folder:

```
cd passago_app
flutter create --platforms=android --org com.passago .
flutter pub get
flutter test
flutter run
```

`flutter create .` only adds the missing Android files. It does not replace
the code in `lib/`. Commit the new `android/` folder to GitHub afterwards.

If you already have a working project folder from earlier, you can instead
copy these four things from this folder into it and choose Replace:
`lib/`, `test/`, `assets/` and `pubspec.yaml`.

`flutter run` works on a USB-connected phone (USB debugging on) or an
emulator. The first run takes a long time. Later runs are much faster.

## Try it

1. Welcome, Get started, then log in with any Driver ID of 3 or more
   characters and any 6-digit PIN (prototype only).
2. Pick a shift, set a quota (try 3), and start the shift.
3. Dashboard: tap **Join queue**, then **Simulate scan success**.
   Distribution shows your place in the line.
4. In Settings, tap **Simulate next driver leaving the line** to watch the
   line move. The Next tag follows the hybrid rule.
5. Tap **+1 passenger**. Trip mode opens. Tap +1 again for more passengers.
6. Press and hold **End trip** for 2 seconds. Repeat until you reach the
   quota. The shift summary appears after the trip that reaches it.
7. Settings also has demo tools: simulate a Bluetooth connection loss, and
   reset all demo data.

## Folder guide

```
lib/
  main.dart                  app start, text-size setting, forced light mode
  theme.dart                 ALL colors and shapes (flat style)
  models.dart                shared data types
  data/mock_data.dart        ALL sample data (names, terminal, old trips)
  logic/queue_logic.dart     the queue rules (pure code, tested)
  state/app_state.dart       shift, quota, queue, trips, counting rules
  services/
    passenger_button_service.dart  Bluetooth button interface + simulator
  widgets/                   shared widgets, pairing sheet, quota sheet
  screens/                   all screens
test/                        logic tests and a smoke test
assets/
  branding/                  logo files (see its README)
  app_icon/                  app icon source images (see its README)
  design_reference/          optional Stitch/Figma exports, not used by the app
```

## Logo and app icon

Put the logo PNGs in `assets/branding/` with the file names listed in its
README. Until they are there, the app shows a plain text placeholder.

For the home-screen app icon, add `assets/app_icon/app_icon.png` and
`assets/app_icon/app_icon_foreground.png` (sizes in its README), then:

```
dart pub add --dev flutter_launcher_icons
```

Add this block to the end of `pubspec.yaml`:

```
flutter_launcher_icons:
  android: true
  ios: false
  image_path: "assets/app_icon/app_icon.png"
  adaptive_icon_background: "#410332"
  adaptive_icon_foreground: "assets/app_icon/app_icon_foreground.png"
```

Then run `dart run flutter_launcher_icons` and rebuild the app.

## What is simulated / still to build

- **QR check-in:** "Simulate scan success" stands in for the camera. Real
  scanning needs a camera package and the camera permission.
- **Bluetooth:** `SimulatedButtonService` stands in for the ESP32. The app
  already counts each press once by its unique id, ignores an app tap right
  after a device press, and acknowledges only after recording. The real
  version needs the BLE service design agreed with the ESP32 sketch, the
  `flutter_blue_plus` package, and Bluetooth permissions. The Bluetooth-off,
  not-found and permission-denied pairing states come with it. The OLED must
  show REGISTERED only after the app acknowledges.
- **Real login, a shared queue across several phones, fares, GPS-based trip
  lock, admin tools:** not in this prototype (future work).
- Trip mode does not detect movement. The warning and the hold-to-end button
  only reduce accidental taps. It is not a full safety lock.
- Shifts started outside their scheduled hours do not end by themselves at
  the scheduled time (so a demo does not end instantly).
