import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/errors/app_error_handler.dart';
import '../features/common/presentation/controllers/mobile_settings_controller.dart';
import 'router/app_router.dart';
import 'theme/fishtrace_theme.dart';

class FishTraceApp extends StatefulWidget {
  const FishTraceApp({super.key});

  @override
  State<FishTraceApp> createState() => _FishTraceAppState();
}

class _FishTraceAppState extends State<FishTraceApp> {
  late final RouterConfig<Object> _router;

  @override
  void initState() {
    super.initState();
    _router = buildRouter();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MobileSettingsController>();
    return Obx(() {
      final settings = controller.settings.value;
      final theme = buildFishTraceTheme().copyWith(
        visualDensity: settings.compactDashboard
            ? VisualDensity.compact
            : VisualDensity.standard,
      );
      return MaterialApp.router(
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        title: 'FishTrace',
        debugShowCheckedModeBanner: false,
        theme: theme,
        darkTheme: ThemeData.dark(
          useMaterial3: true,
        ).copyWith(visualDensity: theme.visualDensity),
        themeMode: settings.useDeviceTheme ? ThemeMode.system : ThemeMode.light,
        routerConfig: _router,
      );
    });
  }
}
