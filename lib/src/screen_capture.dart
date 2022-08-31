import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_screen_capture/src/captured_screen_area.dart';
import 'package:screen_retriever/screen_retriever.dart';

class ScreenCapture {
  final _methodChannel = const MethodChannel('flutter_screen_capture');

  Future<CapturedScreenArea?> captureEntireScreen() async {
    final primaryDisplay = await ScreenRetriever.instance.getPrimaryDisplay();
    return captureScreenArea(
      Rect.fromLTWH(0, 0, primaryDisplay.size.width, primaryDisplay.size.height),
    );
  }

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
    return CapturedScreenArea.fromJson(result);
  }

  Future<Color?> captureScreenColor(double x, double y) async {
    final area = await captureScreenArea(
      Rect.fromLTWH(x, y, 1, 1),
    );
    return area?.getPixelColor(0, 0);
  }
}
