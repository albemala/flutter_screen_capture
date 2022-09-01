import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_screen_capture/src/captured_screen_area.dart';
import 'package:image/image.dart' as image_lib;
import 'package:screen_retriever/screen_retriever.dart';

class ScreenCapture {
  final _methodChannel = const MethodChannel('flutter_screen_capture');

  /// Captures the entire screen area of the main display.
  Future<CapturedScreenArea?> captureEntireScreen() async {
    final primaryDisplay = await ScreenRetriever.instance.getPrimaryDisplay();
    return captureScreenArea(
      Rect.fromLTWH(0, 0, primaryDisplay.size.width, primaryDisplay.size.height),
    );
  }

  /// Captures a screen area of the main display.
  Future<CapturedScreenArea?> captureScreenArea(
    Rect rect,
  ) async {
    final result = await _methodChannel.invokeMethod<Map<Object?, Object?>>(
      'captureScreenArea',
      <String, dynamic>{
        'x': rect.left.toInt(),
        'y': rect.top.toInt(),
        'width': rect.width.toInt(),
        'height': rect.height.toInt(),
      },
    );
    if (result == null) {
      return null;
    }
    final area = CapturedScreenArea.fromJson(result);
    return _sanitizeCapturedArea(area, rect);
  }

  /// Captures the color of a pixel on the screen.
  Future<Color?> captureScreenColor(double x, double y) async {
    final area = await captureScreenArea(
      Rect.fromLTWH(x, y, 1, 1),
    );
    return area?.getPixelColor(0, 0);
  }
}

Future<CapturedScreenArea> _sanitizeCapturedArea(
  CapturedScreenArea area,
  Rect rect,
) async {
  final primaryDisplay = await ScreenRetriever.instance.getPrimaryDisplay();
  final displayRect = Offset.zero & primaryDisplay.size;
  final intersectionRect = rect.intersect(displayRect);
  if (intersectionRect == rect) {
    // No need to sanitize
    return area;
  }

  // The intersection area (between the primary display area
  // and the requested area) is smaller than the requested area.
  // Usually this happens when requesting an area close to the screen border.
  // We need to fill the captured area with black pixels,
  // where the pixels are outside the requested area.

  // Resize the captured area to its actual size
  final correctedArea = area.copyWith(
    width: intersectionRect.width.toInt(),
    height: intersectionRect.height.toInt(),
  );
  // Create a black image of the size of the requested area
  final emptyImage = image_lib.Image.rgb(
    rect.width.toInt(),
    rect.height.toInt(),
  )..fill(const Color(0xFF000000).value);
  // Draw the captured image on top of the black image
  final correctedImage = image_lib.drawImage(
    emptyImage,
    correctedArea.toImage(),
    dstX: (intersectionRect.left - rect.left).toInt(),
    dstY: (intersectionRect.top - rect.top).toInt(),
  );
  // Return the captured area with corrected image and size
  return correctedArea.copyWith(
    buffer: correctedImage.getBytes(),
    width: rect.width.toInt(),
    height: rect.height.toInt(),
  );
}
