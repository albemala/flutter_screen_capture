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
    final correctedRect = await _sanitizeRect(rect);

    final result = await _methodChannel.invokeMethod<Map<Object?, Object?>>(
      'captureScreenArea',
      <String, dynamic>{
        'x': correctedRect.left.toInt(),
        'y': correctedRect.top.toInt(),
        'width': correctedRect.width.toInt(),
        'height': correctedRect.height.toInt(),
      },
    );
    if (result == null) {
      return null;
    }

    final area = CapturedScreenArea.fromJson(result);
    if (correctedRect == rect) {
      return area;
    } else {
      return _sanitizeCapturedArea(area, rect, correctedRect);
    }
  }

  /// Captures the color of a pixel on the screen.
  Future<Color?> captureScreenColor(double x, double y) async {
    final area = await captureScreenArea(
      Rect.fromLTWH(x, y, 1, 1),
    );
    return area?.getPixelColor(0, 0);
  }
}

Future<Rect> _sanitizeRect(Rect rect) async {
  final primaryDisplay = await ScreenRetriever.instance.getPrimaryDisplay();
  final displayRect = Offset.zero & primaryDisplay.size;
  return rect.intersect(displayRect);
}

Future<CapturedScreenArea> _sanitizeCapturedArea(
  CapturedScreenArea area,
  Rect originalRect,
  Rect correctedRect,
) async {
  // The intersection area (between the primary display area
  // and the requested area) is smaller than the requested area.
  // Usually this happens when requesting an area close to the screen border.
  // We need to fill the captured area with black pixels,
  // where the pixels are outside the requested area.

  // Create a black image of the size of the requested area
  final emptyImage = image_lib.Image.fromBytes(
    originalRect.width.toInt(),
    originalRect.height.toInt(),
    List<int>.filled(
      originalRect.width.toInt() * originalRect.height.toInt() * 4,
      0,
    ),
  );
  // Draw the captured image on top of the black image
  final correctedImage = image_lib.drawImage(
    emptyImage,
    area.toImage(),
    dstX: (correctedRect.left - originalRect.left).toInt(),
    dstY: (correctedRect.top - originalRect.top).toInt(),
    blend: false,
  );
  // Return the captured area with corrected image and size
  return area.copyWith(
    buffer: correctedImage.getBytes(),
    width: originalRect.width.toInt(),
    height: originalRect.height.toInt(),
  );
}
