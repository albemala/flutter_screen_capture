#ifndef FLUTTER_PLUGIN_FLUTTER_SCREEN_CAPTURE_PLUGIN_H_
#define FLUTTER_PLUGIN_FLUTTER_SCREEN_CAPTURE_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace flutter_screen_capture {

class FlutterScreenCapturePlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  FlutterScreenCapturePlugin();

  virtual ~FlutterScreenCapturePlugin();

  // Disallow copy and assign.
  FlutterScreenCapturePlugin(const FlutterScreenCapturePlugin&) = delete;
  FlutterScreenCapturePlugin& operator=(const FlutterScreenCapturePlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace flutter_screen_capture

#endif  // FLUTTER_PLUGIN_FLUTTER_SCREEN_CAPTURE_PLUGIN_H_
