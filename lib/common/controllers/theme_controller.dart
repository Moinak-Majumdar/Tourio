import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

enum AppThemeMode { system, light, dark }

class ThemeController extends GetxController with WidgetsBindingObserver {
  final Rx<bool> isDark = true.obs;

  final Rx<AppThemeMode> themeMode = AppThemeMode.system.obs;

  void changeTheme(AppThemeMode mode) {
    themeMode.value = mode;

    if (mode == AppThemeMode.dark) {
      isDark.value = true;
    } else if (mode == AppThemeMode.light) {
      isDark.value = false;
    } else {
      isDark.value =
          SchedulerBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
  }

  // ---------------- Lifecycle ----------------

  @override
  void onInit() {
    WidgetsBinding.instance.addObserver(this);
    _syncTheme();
    super.onInit();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangePlatformBrightness() {
    _syncTheme();
  }

  void _syncTheme() {
    themeMode.value = AppThemeMode.system;
    isDark.value =
        SchedulerBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark;
  }
}
