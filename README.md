# flutter_screen_capture

[![Pub](https://img.shields.io/pub/v/flutter_screen_capture)](https://pub.dev/packages/flutter_screen_capture)

A plugin to capture the entire screen or part of it on desktop platforms.

|             | macOS | Windows | Linux |
|:------------|:------|:--------|:------|
| **Support** | ✅     | ✅       | ❌     |

## Usage

### Capture the entire screen

```dart
final area = await ScreenCapture().captureEntireScreen();
```

### Capture a specific area of the screen

```dart
final topLeftCorner = Rect.fromLTWH(0, 0, 100, 100);
final area = await ScreenCapture().captureScreenArea(topLeftCorner);
```

### Capture a single pixel color

```dart
final color = await ScreenCapture().captureScreenColor(100, 100);
```

### Widgets

There are 2 widgets you can use to see a live preview of a screen area or a pixel color.
They both display what's under the mouse cursor.

Screen area preview:

```dart
SizedBox(
  width: 72,
  height: 72,
  child: ScreenAreaLiveView(areaSize: 72 / 4),
)
```

Color live preview:

```dart
SizedBox(
  width: 48,
  height: 48,
  child: ScreenColorLiveView(),
)
```

### Advanced usage

See the [example app](https://github.com/albemala/flutter_screen_capture/tree/main/example) for a complete usage
example.



## Current limitations

- Linux is not supported yet.
- Capturing on multiple screens is not supported yet.
- Capturing on high-resolution screens (e.g. Retina displays) is not supported yet.



## Support this project

<a href="https://www.buymeacoffee.com/albemala" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>



## Other projects

🧰 **[exabox](https://exabox.app/)** — Essential tools for developers: All the tools you need in one single app.

😃 **[Ejimo](https://github.com/albemala/emoji-picker)** — Emoji and symbol picker

🗺️ **[WMap](https://wmap.albemala.me/)** — Create beautiful, minimal, custom map wallpapers and backgrounds for your
phone or tablet.

🎨 **[iro‿iro](https://iro-iro.albemala.me/)** — Rearrange the colors to form beautiful patterns in this relaxing color puzzle game.



## Credits

Created by [@albemala](https://github.com/albemala) ([Twitter](https://twitter.com/albemala))
