import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tourio/common/controllers/tour_controller.dart';
import 'package:tourio/common/theme/app_theme.dart';
import 'package:tourio/screens/home/home_screen.dart';

import 'common/controllers/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await DatabaseHelper.instance.resetDatabase();
  await GetStorage.init();
  Get.put(ThemeController(), permanent: true);
  Get.put(TourController(), permanent: true);
  runApp(TourioApp());
}

class TourioApp extends StatelessWidget {
  const TourioApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(() {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Tourio',
        theme: themeController.isDark.value ? AppTheme.dark : AppTheme.light,
        home: const HomeScreen(),
      );
    });
  }
}
