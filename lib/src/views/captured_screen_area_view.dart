import 'package:flutter/widgets.dart';
import 'package:flutter_screen_capture/src/captured_screen_area.dart';

/// A widget that displays a captured screen area as an image.
class CapturedScreenAreaView extends StatelessWidget {
  final CapturedScreenArea area;

  const CapturedScreenAreaView({
    super.key,
    required this.area,
  });

  @override
  Widget build(BuildContext context) {
    return Image.memory(
      area.toPngImage(),
    );
  }
}
