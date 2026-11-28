# App icon (the image on the phone's home screen)

| File                      | Requirements                                              |
|---------------------------|-----------------------------------------------------------|
| `app_icon.png`            | 1024 x 1024, square, no transparency, no rounded corners  |
| `app_icon_foreground.png` | 1024 x 1024, transparent background, symbol only, kept    |
|                           | inside the center circle of about 680 px                  |

Background color for the adaptive icon: plum `#410332`.
These are turned into all Android sizes with the `flutter_launcher_icons`
package (set up after the files are added, see the main README).
