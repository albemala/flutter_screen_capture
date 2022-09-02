#include "include/flutter_screen_capture/flutter_screen_capture_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flutter_screen_capture_plugin.h"

void FlutterScreenCapturePluginCApiRegisterWithRegistrar(FlutterDesktopPluginRegistrarRef registrar)
{
    flutter_screen_capture::FlutterScreenCapturePlugin::RegisterWithRegistrar(
            flutter::PluginRegistrarManager::GetInstance()->GetRegistrar<flutter::PluginRegistrarWindows>(registrar)
    );
}
