import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kofz_key_manager/models.dart';
import 'package:kofz_key_manager/services/preferences.dart';
import 'package:kofz_key_manager/util.dart';
import 'package:universal_io/io.dart';

import 'config_keys_state.dart';

class ConfigKeysLogic extends GetxController {
  final Rx<ConfigKeysState> state = ConfigKeysState(
    p1: UserState.empty(true),
    p2: UserState.empty(false),
  ).obs;

  final TextEditingController p1NameController = TextEditingController();
  final TextEditingController p2NameController = TextEditingController();

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    p1NameController.dispose();
    p2NameController.dispose();
    super.onClose();
  }

  void updateKey({required bool p1, required String key, required int keyId}) {
    state.update((val) {
      var userState = (p1 ? val?.p1 : val?.p2);
      userState?.setting.keyBindings[key] = KeyMapping.getMugenKeyCode(keyId);
      userState?.state = UserState.stateChanged;
      debugPrint(
        "userState?.setting.keyBindings=${userState?.setting.keyBindings}",
      );
    });
  }

  void updatePlayerName({required bool p1, required String value}) {
    state.update((val) {
      UserState userState = (p1 ? val?.p1 : val?.p2)!;
      userState.setting.playerName = value;
    });
  }

  void save({required bool p1}) {
    UserState userState = (p1 ? state.value.p1 : state.value.p2);
    if (userState.state == UserState.stateEmpty ||
        userState.state == UserState.stateSaved) {
      return;
    }
    String? configDirPath =
        KeyValueService.to.getString(KeyValueService.keyConfigDir);
    if (configDirPath == null) {
      Util.showDialog(title: "未指定存储配置的文件夹");
      return;
    }
    if (!userState.setting.allKeysSet) {
      Util.showDialog(title: "还有未指定的键位");
      return;
    }
    if (userState.setting.playerName.isEmpty) {
      Util.showDialog(title: "请输入玩家名");
      return;
    }
    state.update((val) {
      UserState userState = (p1 ? val?.p1 : val?.p2)!;
      userState.file ??= (File(
        "${Directory(configDirPath).path}${Platform.pathSeparator}${userState.setting.playerName}_${p1 ? "p1" : "p2"}.json",
      ));
      userState.file!
          .writeAsStringSync(json.encode(userState.setting.toJson()));
      userState.state = UserState.stateSaved;
      Util.showDialog(title: "保存成功");
    });
  }

  void load({required File file, required bool p1}) {
    UserSetting setting =
        UserSetting.fromJson(json.decode(file.readAsStringSync()));
    if (setting.p1 != p1) {
      Util.showDialog(
        title: "键位不兼容，文件是${setting.p1 ? "1P" : "2P"}，需要${p1 ? "1P" : "2P"}",
      );
      return;
    }
    (p1 ? p1NameController : p2NameController).text = setting.playerName;
    state.update((val) {
      UserState userState = (p1 ? val?.p1 : val?.p2)!;
      userState.setting = setting;
      userState.file = file;
    });
  }
}
