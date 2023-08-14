import 'package:get/get.dart';

import 'config_keys_logic.dart';

class ConfigKeysBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConfigKeysLogic>(() => ConfigKeysLogic());
  }
}
