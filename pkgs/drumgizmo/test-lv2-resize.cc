// Exercise the real LV2 editor with a host that ignores its initial resize request.
#include <lv2/core/lv2.h>
#include <lv2/ui/ui.h>
#include <lv2/urid/urid.h>
#include <X11/Xlib.h>
#include <dlfcn.h>
#include <cassert>
#include <chrono>
#include <cstdint>
#include <iostream>
#include <string>
#include <thread>
#include <unordered_map>

static uint32_t map_uri(void* handle, const char* uri)
{
  auto& urids = *static_cast<std::unordered_map<std::string, uint32_t>*>(handle);
  auto result = urids.emplace(uri, urids.size() + 1);
  return result.first->second;
}
static int ignore_resize(void*, int, int) { return 0; }
static void ignore_write(LV2UI_Controller, uint32_t, uint32_t, uint32_t, const void*) {}

int main(int argc, char** argv)
{
  assert(argc == 2);
  std::string bundle = argv[1];
  auto* library = dlopen((bundle + "/drumgizmo.so").c_str(), RTLD_NOW);
  if(!library) { std::cerr << dlerror() << '\n'; return 1; }
  auto descriptor = reinterpret_cast<LV2_Descriptor_Function>(dlsym(library, "lv2_descriptor"))(0);
  auto ui = reinterpret_cast<LV2UI_DescriptorFunction>(dlsym(library, "lv2ui_descriptor"))(0);
  std::unordered_map<std::string, uint32_t> urids;
  LV2_URID_Map map{&urids, map_uri};
  LV2_Feature map_feature{LV2_URID__map, &map};
  const LV2_Feature* features[]{&map_feature, nullptr};
  auto instance = descriptor->instantiate(descriptor, 48000.0, bundle.c_str(), features);
  assert(instance);
  auto* display = XOpenDisplay(nullptr);
  assert(display);
  auto parent = XCreateSimpleWindow(display, DefaultRootWindow(display), 0, 0, 160, 120, 0, 0, 0);
  XMapWindow(display, parent);
  XSync(display, False);
  LV2UI_Resize resize{nullptr, ignore_resize};
  LV2_Feature instance_feature{"http://lv2plug.in/ns/ext/instance-access", instance};
  LV2_Feature parent_feature{LV2_UI__parent, reinterpret_cast<void*>(parent)};
  LV2_Feature resize_feature{LV2_UI__resize, &resize};
  const LV2_Feature* ui_features[]{&instance_feature, &parent_feature, &resize_feature, nullptr};
  LV2UI_Widget widget = nullptr;
  auto handle = ui->instantiate(ui, descriptor->URI, bundle.c_str(), ignore_write, nullptr, &widget, ui_features);
  assert(handle && widget);
  const auto* idle = static_cast<const LV2UI_Idle_Interface*>(ui->extension_data(LV2_UI__idleInterface));
  assert(idle);
  auto pump = [&] {
    for(int i = 0; i < 100; ++i) {
      idle->idle(handle);
      XSync(display, False);
      std::this_thread::sleep_for(std::chrono::milliseconds(2));
    }
  };
  auto check_size = [&](unsigned expected_width, unsigned expected_height) {
    Window root;
    int x, y;
    unsigned width, height, border, depth;
    assert(XGetGeometry(display, reinterpret_cast<Window>(widget), &root, &x, &y,
                        &width, &height, &border, &depth));
    std::cout << "editor: " << width << 'x' << height << std::endl;
    assert(width == expected_width && height == expected_height);
  };
  pump();
  check_size(750, 740);
  for(auto size : {std::pair{900u, 800u}, {160u, 120u}, {1u, 1u}, {750u, 740u}}) {
    XResizeWindow(display, parent, size.first, size.second);
    XSync(display, False);
    pump();
    check_size(std::max(size.first, 750u), std::max(size.second, 740u));
  }
  ui->cleanup(handle);
  descriptor->cleanup(instance);
  XDestroyWindow(display, parent);
  XCloseDisplay(display);
  dlclose(library);
}
