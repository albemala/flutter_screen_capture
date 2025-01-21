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

## Projects using this package

- **[Hexee Pro](https://hexee.app/)** - Palette editor & Advanced color toolkit for designers and developers.

Feel free to submit a pull request to add your project to this list.

## Support this project

- [GitHub Sponsor](https://github.com/sponsors/albemala)
- [Buy Me A Coffee](https://www.buymeacoffee.com/albemala)

## Other projects

[All my projects](https://projects.albemala.me/)

## Credits

Created by [@albemala](https://github.com/albemala) ([Twitter](https://twitter.com/albemala))
