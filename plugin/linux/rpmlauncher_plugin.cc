#include "include/rpmlauncher_plugin/rpmlauncher_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cstring>

#define RPMLAUNCHER_PLUGIN(obj)                                     \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), rpmlauncher_plugin_get_type(), \
                              RpmlauncherPlugin))

struct _RpmlauncherPlugin
{
  GObject parent_instance;
};

G_DEFINE_TYPE(RpmlauncherPlugin, rpmlauncher_plugin, g_object_get_type())

// Called when a method call is received from Flutter.
static void rpmlauncher_plugin_handle_method_call(
    RpmlauncherPlugin *self,
    FlMethodCall *method_call)
{
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar *method = fl_method_call_get_name(method_call);

  if (strcmp(method, "getPlatformVersion") == 0)
  {
    struct utsname uname_data = {};
    uname(&uname_data);
    g_autofree gchar *version = g_strdup_printf("Linux %s", uname_data.version);
    g_autoptr(FlValue) result = fl_value_new_string(version);

    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  }
  else if (strcmp(method, "getTotalPhysicalMemory") == 0)
  {
    response = FL_METHOD_RESPONSE(get_memory_total());
  }
  else
  {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void rpmlauncher_plugin_dispose(GObject *object)
{
  G_OBJECT_CLASS(rpmlauncher_plugin_parent_class)->dispose(object);
}

static void rpmlauncher_plugin_class_init(RpmlauncherPluginClass *klass)
{
  G_OBJECT_CLASS(klass)->dispose = rpmlauncher_plugin_dispose;
}

static void rpmlauncher_plugin_init(RpmlauncherPlugin *self) {}

static void method_call_cb(FlMethodChannel *channel, FlMethodCall *method_call,
                           gpointer user_data)
{
  RpmlauncherPlugin *plugin = RPMLAUNCHER_PLUGIN(user_data);
  rpmlauncher_plugin_handle_method_call(plugin, method_call);
}

void rpmlauncher_plugin_register_with_registrar(FlPluginRegistrar *registrar)
{
  RpmlauncherPlugin *plugin = RPMLAUNCHER_PLUGIN(
      g_object_new(rpmlauncher_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "rpmlauncher_plugin",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  g_object_unref(plugin);
}

static unsigned long get_memory_total()
{
  std::string token;
  std::ifstream file("/proc/meminfo");
  while (file >> token)
  {
    if (token == "MemTotal:")
    {
      unsigned long mem;
      if (file >> mem)
      {
        return mem;
      }
      else
      {
        return 0;
      }
    }
    // Ignore the rest of the line
    file.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
  }
  return 0; // Nothing found
}