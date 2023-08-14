import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kofz_key_manager/modules/config_keys/config_keys_binding.dart';
import 'package:kofz_key_manager/modules/system/system_binding.dart';
import 'package:kofz_key_manager/pages.dart';
import 'package:kofz_key_manager/services/file.dart';
import 'package:kofz_key_manager/services/preferences.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();

  const size = Size(880, 720);
  WindowOptions windowOptions = const WindowOptions(
    size: size,
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    minimumSize: size,
    titleBarStyle: TitleBarStyle.normal,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  runApp(const App());
}

class _ScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
      };
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    AppBarTheme appBarTheme = const AppBarTheme(centerTitle: true);
    //  const inputBorder = OutlineInputBorder(
    //   borderRadius: BorderRadius.all(Radius.circular(8)),
    //   borderSide: BorderSide(width: 2),
    // );
    //  const inputErrorBorder = OutlineInputBorder(
    //   borderRadius: BorderRadius.all(Radius.circular(8)),
    //   borderSide: BorderSide(width: 2),
    // );
    //  const highLightedInputBorder = OutlineInputBorder(
    //   borderRadius: BorderRadius.all(Radius.circular(8)),
    //   borderSide: BorderSide(width: 2),
    // );
    //  const inputDecorationTheme = InputDecorationTheme(
    //   focusedBorder: highLightedInputBorder,
    //   enabledBorder: inputBorder,
    //   disabledBorder: inputBorder,
    //   errorBorder: inputErrorBorder,
    //   errorMaxLines: 5,
    //   contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    //   border: inputBorder,
    //   labelStyle: TextStyle(fontSize: 14),
    // );
    var themeData = ThemeData(
      appBarTheme: appBarTheme,
      // inputDecorationTheme: inputDecorationTheme,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF9E5EF8),
      ),
    );
    return GetMaterialApp(
      title: 'KOFZ按键管理',
      theme: themeData,
      initialBinding: _InitialBindings(),
      scrollBehavior: _ScrollBehavior(),
      home: const HomePage(),
    );
  }
}

class _InitialBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KeyValueService>(() => KeyValueService());
    Get.lazyPut<FileService>(() => FileService());
    // Get.lazyPut<SystemBinding>(() => SystemBinding());
    // Get.lazyPut<ConfigKeysBinding>(() => ConfigKeysBinding());
    SystemBinding().dependencies();
    ConfigKeysBinding().dependencies();
  }
}
