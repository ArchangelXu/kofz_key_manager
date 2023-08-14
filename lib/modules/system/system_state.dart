import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kofz_key_manager/services/preferences.dart';

class SystemState {
  Size? resolution;
  String? configDir;
  String? mugenFilePath;
  int? masterVolume;
  int? bgmVolume;
  int? efxVolume;
  bool loading = false;

  SystemState() {
    resolution = Size(
      KeyValueService.to.getDouble(KeyValueService.keyResolutionWidth) ??
          Get.size.width,
      KeyValueService.to.getDouble(KeyValueService.keyResolutionHeight) ??
          Get.size.height,
    );
    configDir = KeyValueService.to.getString(KeyValueService.keyConfigDir);
    mugenFilePath =
        KeyValueService.to.getString(KeyValueService.keyMugenFilePath);
  }
}
