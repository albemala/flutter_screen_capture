#include "include/flutter_screen_capture/flutter_screen_capture_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <glib/gstdio.h>
#include <cstring>
#include <gdk/gdk.h>

GdkPixbuf *CaptureScreenArea(int64_t x, int64_t y, int64_t width, int64_t height)
{
    // TODO
    // The passed width and height args, contains the resolution of Primary monitor
    // If user wants to capture the whole display, including the secondary monitors,
    // width and height can be calculated using

    // gdk_window_get_width(window)
    // gdk_window_get_height(window)
    GdkPixbuf *screenshot = nullptr;
    GdkPixbuf *screenShotWithAlpha = nullptr;
    GdkWindow *window = gdk_get_default_root_window();
    screenshot =
        gdk_pixbuf_get_from_window(window, x, y, width,
                                   height);
    screenShotWithAlpha = gdk_pixbuf_add_alpha(screenshot, FALSE, 0, 0, 0);
    return screenShotWithAlpha;
}

struct _FlutterScreenCapturePlugin
{
    GObject parent_instance;
};

#define FLUTTER_SCREEN_CAPTURE_PLUGIN(obj) (G_TYPE_CHECK_INSTANCE_CAST((obj), flutter_screen_capture_plugin_get_type(), FlutterScreenCapturePlugin))

G_DEFINE_TYPE(FlutterScreenCapturePlugin, flutter_screen_capture_plugin, g_object_get_type())

static void flutter_screen_capture_plugin_dispose(GObject *object)
{
    G_OBJECT_CLASS(flutter_screen_capture_plugin_parent_class)->dispose(object);
}

static void flutter_screen_capture_plugin_class_init(FlutterScreenCapturePluginClass *klass)
{
    G_OBJECT_CLASS(klass)->dispose = flutter_screen_capture_plugin_dispose;
}

static void flutter_screen_capture_plugin_init(FlutterScreenCapturePlugin *self) {}

// Called when a method call is received from Flutter.
static void flutter_screen_capture_plugin_handle_method_call(
    FlutterScreenCapturePlugin *self,
    FlMethodCall *method_call)
{
    const gchar *method = fl_method_call_get_name(method_call);
    FlValue *args = fl_method_call_get_args(method_call);

    g_autoptr(FlMethodResponse) response;
    if (strcmp(method, "captureScreenArea") == 0)
    {
        auto capturedScreenArea = CaptureScreenArea(
            fl_value_get_int(fl_value_lookup_string(args, "x")),
            fl_value_get_int(fl_value_lookup_string(args, "y")),
            fl_value_get_int(fl_value_lookup_string(args, "width")),
            fl_value_get_int(fl_value_lookup_string(args, "height")));
        if (capturedScreenArea == nullptr)
        {
            response = FL_METHOD_RESPONSE(fl_method_error_response_new(
                "captureScreenArea failed",
                nullptr,
                nullptr));
        }
        else
        {
            FlValue *dict = fl_value_new_map();
            fl_value_set_string_take(
                dict,
                "buffer",
                fl_value_new_uint8_list(
                    gdk_pixbuf_read_pixels(capturedScreenArea),
                    gdk_pixbuf_get_byte_length(capturedScreenArea)));
            fl_value_set_string_take(
                dict,
                "width",
                fl_value_new_int(gdk_pixbuf_get_width(capturedScreenArea)));
            fl_value_set_string_take(
                dict,
                "height",
                fl_value_new_int(gdk_pixbuf_get_height(capturedScreenArea)));
            fl_value_set_string_take(
                dict,
                "bitsPerPixel",
                fl_value_new_int(gdk_pixbuf_get_bits_per_sample(capturedScreenArea)));
            fl_value_set_string_take(
                dict,
                "bytesPerPixel",
                fl_value_new_int(gdk_pixbuf_get_n_channels(capturedScreenArea)));

            g_object_unref(capturedScreenArea);

            response = FL_METHOD_RESPONSE(fl_method_success_response_new(dict));
        }
    }
    else
    {
        response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
    }
    fl_method_call_respond(method_call, response, nullptr);
}

static void method_call_cb(
    FlMethodChannel *channel,
    FlMethodCall *method_call,
    gpointer user_data)
{
    FlutterScreenCapturePlugin *plugin = FLUTTER_SCREEN_CAPTURE_PLUGIN(user_data);
    flutter_screen_capture_plugin_handle_method_call(plugin, method_call);
}

void flutter_screen_capture_plugin_register_with_registrar(FlPluginRegistrar *registrar)
{
    FlutterScreenCapturePlugin *plugin = FLUTTER_SCREEN_CAPTURE_PLUGIN(
        g_object_new(
            flutter_screen_capture_plugin_get_type(),
            nullptr));

    g_autoptr(FlStandardMethodCodec)
        codec = fl_standard_method_codec_new();
    g_autoptr(FlMethodChannel)
        channel = fl_method_channel_new(
            fl_plugin_registrar_get_messenger(registrar),
            "flutter_screen_capture",
            FL_METHOD_CODEC(codec));
    fl_method_channel_set_method_call_handler(
        channel,
        method_call_cb,
        g_object_ref(plugin),
        g_object_unref);

    g_object_unref(plugin);
}
