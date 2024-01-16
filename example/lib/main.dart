import 'package:flutter/material.dart';
import 'package:flutter_screen_capture/flutter_screen_capture.dart';
import 'package:screen_retriever/screen_retriever.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _plugin = ScreenCapture();
  Color? _color;
  CapturedScreenArea? _screenArea;
  CapturedScreenArea? _fullScreenArea;

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (key) async {
        switch (key.character) {
          case 'c': // capture screen pixel
            await _captureScreenPixel();
            break;
          case 'a': // capture screen area
            await _captureScreenArea();
            break;
          case 'f': // capture full screen
            await _captureFullScreen();
            break;
        }
      },
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Screen pixel color',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                const Row(
                  children: [
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: ScreenColorLiveView(),
                    ),
                    SizedBox(width: 24),
                    Text('Live at cursor position'),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      color: _color,
                    ),
                    const SizedBox(width: 24),
                    const Text('Press C to capture color at cursor position'),
                  ],
                ),
                const SizedBox(height: 64),
                Text(
                  'Screen area',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                const Row(
                  children: [
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: ScreenAreaLiveView(areaSize: 72 / 4),
                    ),
                    SizedBox(width: 24),
                    Text('Live at cursor position'),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    if (_screenArea != null)
                      CapturedScreenAreaView(area: _screenArea!),
                    const SizedBox(width: 24),
                    const Text('Press A to capture screen at cursor position'),
                  ],
                ),
                const SizedBox(height: 64),
                Text(
                  'Full screen',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                const Text('Press F to capture the entire screen'),
                const SizedBox(height: 24),
                if (_fullScreenArea != null)
                  CapturedScreenAreaView(area: _fullScreenArea!),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _captureScreenPixel() async {
    final cursorScreenPoint =
        await ScreenRetriever.instance.getCursorScreenPoint();
    final color = await _plugin.captureScreenColor(
      cursorScreenPoint.dx,
      cursorScreenPoint.dy,
    );
    setState(() {
      _color = color;
    });
  }

  Future<void> _captureScreenArea() async {
    final cursorScreenPoint =
        await ScreenRetriever.instance.getCursorScreenPoint();
    final rect = Rect.fromCircle(center: cursorScreenPoint, radius: 72 / 2);
    final area = await _plugin.captureScreenArea(rect);
    setState(() {
      _screenArea = area;
    });
  }

  Future<void> _captureFullScreen() async {
    final area = await _plugin.captureEntireScreen();
    setState(() {
      _fullScreenArea = area;
    });
  }
}
