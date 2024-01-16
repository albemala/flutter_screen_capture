import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screen_capture/src/captured_screen_area.dart';
import 'package:flutter_screen_capture/src/screen_capture.dart';
import 'package:screen_retriever/screen_retriever.dart';

/// A widget that displays the screen area at the cursor position.
/// The area is updated every frame.
///
/// Notes:
/// - Make sure to wrap it into a [SizedBox] to give it a size.
class ScreenAreaLiveView extends StatefulWidget {
  /// The size of the captured area in pixels.
  final double areaSize;

  const ScreenAreaLiveView({
    required this.areaSize,
    super.key,
  }) : assert(areaSize > 0, 'areaSize must be greater than 0');

  @override
  State<ScreenAreaLiveView> createState() => _ScreenAreaLiveViewState();
}

class _ScreenAreaLiveViewState extends State<ScreenAreaLiveView>
    with SingleTickerProviderStateMixin {
  final _plugin = ScreenCapture();
  CapturedScreenArea? _area;
  late Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((duration) async {
      final cursorScreenPoint =
          await ScreenRetriever.instance.getCursorScreenPoint();
      final rect = Rect.fromCircle(
        center: cursorScreenPoint,
        radius: widget.areaSize / 2,
      );
      final area = await _plugin.captureScreenArea(rect);
      setState(() {
        _area = area;
      });
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_area == null) {
      return const SizedBox();
    } else {
      return CustomPaint(
        painter: CapturedScreenAreaPainter(area: _area!),
      );
    }
  }
}

class CapturedScreenAreaPainter extends CustomPainter {
  final CapturedScreenArea area;

  const CapturedScreenAreaPainter({
    required this.area,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pixelWidth = size.width / area.width;
    final pixelHeight = size.height / area.height;
    for (var row = 0; row < area.height; row++) {
      for (var column = 0; column < area.width; column++) {
        final color = area.getPixelColor(column.toDouble(), row.toDouble());
        canvas.drawRect(
          Rect.fromLTWH(
            column * pixelWidth,
            row * pixelHeight,
            pixelWidth,
            pixelHeight,
          ),
          Paint()..color = color,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CapturedScreenAreaPainter oldDelegate) {
    return oldDelegate.area != area;
  }
}
