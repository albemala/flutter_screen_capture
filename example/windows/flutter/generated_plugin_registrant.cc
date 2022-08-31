//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <flutter_screen_capture/flutter_screen_capture_plugin_c_api.h>
#include <screen_retriever/screen_retriever_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  FlutterScreenCapturePluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterScreenCapturePluginCApi"));
  ScreenRetrieverPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ScreenRetrieverPlugin"));
}
