import 'package:flutter/services.dart';

class FlutterScreenCapturePlugin {
  final _methodChannel = const MethodChannel('flutter_screen_capture');

  Future<String?> getPlatformVersion() async {
    return _methodChannel.invokeMethod<String>('getPlatformVersion');
  }
}
