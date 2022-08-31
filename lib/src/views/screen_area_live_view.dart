import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screen_capture/src/captured_screen_area.dart';
import 'package:flutter_screen_capture/src/screen_capture.dart';
import 'package:screen_retriever/screen_retriever.dart';

class ScreenAreaLiveView extends StatefulWidget {
  final double areaSize;

  const ScreenAreaLiveView({
    super.key,
    required this.areaSize,
  });

  @override
  _ScreenAreaLiveViewState createState() => _ScreenAreaLiveViewState();
}

class _ScreenAreaLiveViewState extends State<ScreenAreaLiveView> with SingleTickerProviderStateMixin {
  final _plugin = ScreenCapture();
  CapturedScreenArea? _area;
  late Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((duration) async {
      final cursorScreenPoint = await ScreenRetriever.instance.getCursorScreenPoint();
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
    for (var y = 0; y < area.height; y++) {
      for (var x = 0; x < area.width; x++) {
        final color = area.getPixelColor(x.toDouble(), y.toDouble());
        canvas.drawRect(
          Rect.fromLTWH(
            x * pixelWidth,
            y * pixelHeight,
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
