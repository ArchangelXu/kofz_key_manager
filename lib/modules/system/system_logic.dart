import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kofz_key_manager/models.dart';
import 'package:kofz_key_manager/modules/config_keys/config_keys_logic.dart';
import 'package:kofz_key_manager/modules/config_keys/config_keys_state.dart';
import 'package:kofz_key_manager/services/preferences.dart';
import 'package:kofz_key_manager/util.dart';
import 'package:pretty_json/pretty_json.dart';
import 'package:sprintf/sprintf.dart';
import 'package:universal_io/io.dart';

import 'system_state.dart';

class SystemLogic extends GetxController {
  static const minPropertyFormatLength = 12;
  final Rx<SystemState> state = SystemState().obs;

  final TextEditingController configDirController = TextEditingController();
  final TextEditingController mugenFileController = TextEditingController();
  final TextEditingController masterVolumeController = TextEditingController();
  final TextEditingController bgmVolumeController = TextEditingController();
  final TextEditingController efxVolumeController = TextEditingController();

  @override
  void onReady() {
    super.onReady();
    configDirController.text = state.value.configDir ?? "未选择";
    mugenFileController.text = state.value.mugenFilePath ?? "未选择";
    if (state.value.mugenFilePath != null) {
      load(state.value.mugenFilePath!);
    }
  }

  @override
  void onClose() {
    state.close();
    configDirController.dispose();
    mugenFileController.dispose();
    masterVolumeController.dispose();
    bgmVolumeController.dispose();
    efxVolumeController.dispose();
    super.onClose();
  }

  void updateMasterVolume(String value) {
    int? volume = _checkVolume(value);
    if (volume != null) {
      state.value.masterVolume = volume;
    }
  }

  void updateBgmVolume(String value) {
    int? volume = _checkVolume(value);
    if (volume != null) {
      state.value.bgmVolume = volume;
    }
  }

  void updateEfxVolume(String value) {
    int? volume = _checkVolume(value);
    if (volume != null) {
      state.value.efxVolume = volume;
    }
  }

  void updateConfigDir(String value) {
    state.update((val) {
      val?.configDir = value;
      configDirController.text = value;
      KeyValueService.to.putString(KeyValueService.keyConfigDir, value);
    });
  }

  void save() {
    var keyLogic = Get.find<ConfigKeysLogic>();
    var keyState = keyLogic.state;

    if (state.value.mugenFilePath == null) {
      Util.showDialog(title: "未选择mugen.cfg文件");
      return;
    }
    if (!keyState.value.p1.setting.allKeysSet) {
      Util.showDialog(title: "1P键位未设置");
      return;
    }
    if (!keyState.value.p2.setting.allKeysSet) {
      Util.showDialog(title: "2P键位未设置");
      return;
    }
    if (state.value.masterVolume == null) {
      Util.showDialog(title: "主音量未设置");
      return;
    }
    if (state.value.bgmVolume == null) {
      Util.showDialog(title: "音乐音量未设置");
      return;
    }
    if (state.value.efxVolume == null) {
      Util.showDialog(title: "音效音量未设置");
      return;
    }
    if (state.value.resolution == null) {
      Util.showDialog(title: "分辨率未设置");
      return;
    }
    _saveCfgFile(File(state.value.mugenFilePath!));
  }

  void load(String path) {
    state.update((val) {
      val?.loading = true;
    });
    try {
      // List<String> lines = File(path).readAsLinesSync();
      List<String> lines = Util.decodeGbk(File(path)).split("\n");
      int? width = _findIntProperty(lines: lines, key: "GameWidth");
      int? height = _findIntProperty(lines: lines, key: "GameHeight");
      int? master = _findIntProperty(lines: lines, key: "MasterVolume");
      int? bgm = _findIntProperty(lines: lines, key: "BGMVolume");
      int? efx = _findIntProperty(lines: lines, key: "WavVolume");
      state.update((val) {
        if (width != null && height != null) {
          val?.resolution = Size(width.toDouble(), height.toDouble());
        }
        val?.masterVolume = master;
        val?.bgmVolume = bgm;
        val?.efxVolume = efx;
        val?.mugenFilePath = path;
      });

      KeyValueService.to.putString(KeyValueService.keyMugenFilePath, path);
      masterVolumeController.text = master?.toString() ?? "";
      bgmVolumeController.text = bgm?.toString() ?? "";
      efxVolumeController.text = efx?.toString() ?? "";
      String? configDir =
          KeyValueService.to.getString(KeyValueService.keyConfigDir);
      if (configDir != null) {
        int lineIndex = lines.indexWhere((e) => e.contains("[P1 Keys]"));
        UserState? userState = _findExistingUserSetting(
          lines: lines,
          p1: true,
          configDir: configDir,
          offset: lineIndex,
        );
        var logic = Get.find<ConfigKeysLogic>();
        if (userState != null) {
          logic.p1NameController.text = userState.setting.playerName;
          logic.state.update((val) {
            val?.p1 = userState!;
          });
        }
        lineIndex = lines.indexWhere((e) => e.contains("[P2 Keys]"), lineIndex);
        userState = _findExistingUserSetting(
          lines: lines,
          p1: false,
          configDir: configDir,
          offset: lineIndex,
        );
        if (userState != null) {
          logic.p2NameController.text = userState.setting.playerName;
          logic.state.update((val) {
            val?.p2 = userState!;
          });
        }
      }
      mugenFileController.text = path;
    } catch (e) {
      print(e);
      Util.showDialog(title: "错误", message: "$e");
    } finally {
      state.update((val) {
        val?.loading = false;
      });
    }
  }

  int? _checkVolume(String value) {
    int? volume = int.tryParse(value);
    if (volume == null) {
      return null;
    }
    return clampDouble(volume.toDouble(), 0, 100).toInt();
  }

  bool _checkConflictKeys() {
    var keyLogic = Get.find<ConfigKeysLogic>();
    var keyState = keyLogic.state;
    Set<int?> set = {};
    for (var value in keyState.value.p1.setting.keyBindings.values) {
      if (set.contains(value)) {
        Util.showDialog(
          title: "按键冲突：${KeyMapping.getKeyboardKeyName(value)?.keyLabel}",
        );
        return false;
      }
      set.add(value);
    }
    set.clear();
    for (var value in keyState.value.p2.setting.keyBindings.values) {
      if (set.contains(value)) {
        Util.showDialog(
          title: "按键冲突：${KeyMapping.getKeyboardKeyName(value)?.keyLabel}",
        );
        return false;
      }
      set.add(value);
    }
    var intersection = keyState.value.p1.setting.keyBindings.values
        .toSet()
        .intersection(keyState.value.p2.setting.keyBindings.values.toSet());
    if (intersection.isNotEmpty) {
      // key conflicts
      Util.showDialog(
        title:
            "按键冲突：${intersection.map((e) => KeyMapping.getKeyboardKeyName(e)?.keyLabel).whereNotNull().toList()}",
      );
      return false;
    }
    return true;
  }

  void _saveCfgFile(File file) {
    if (!_checkConflictKeys()) {
      return;
    }
    state.update((val) {
      val?.loading = true;
    });
    try {
      // List<String> lines = file.readAsLinesSync();
      List<String> lines = Util.decodeGbk(file).split("\n");
      _replaceCfgLine(
        lines: lines,
        key: "GameWidth",
        value: state.value.resolution!.width.toInt().toString(),
      );
      _replaceCfgLine(
        lines: lines,
        key: "GameHeight",
        value: state.value.resolution!.height.toInt().toString(),
      );
      _replaceCfgLine(
        lines: lines,
        key: "MasterVolume",
        value: state.value.masterVolume!.toString(),
      );
      _replaceCfgLine(
        lines: lines,
        key: "BGMVolume",
        value: state.value.bgmVolume!.toString(),
      );
      _replaceCfgLine(
        lines: lines,
        key: "WavVolume",
        value: state.value.efxVolume!.toString(),
      );
      int lineIndex = lines.indexWhere((e) => e.contains("[P1 Keys]"));
      var keyLogic = Get.find<ConfigKeysLogic>();
      var keyState = keyLogic.state;
      _replaceKeyBindingLines(
        lines: lines,
        setting: keyState.value.p1.setting,
        offset: lineIndex,
      );
      lineIndex = lines.indexWhere((e) => e.contains("[P2 Keys]"), lineIndex);
      _replaceKeyBindingLines(
        lines: lines,
        setting: keyState.value.p2.setting,
        offset: lineIndex,
      );
      // file.writeAsStringSync(lines.join("\n"));
      file.writeAsBytesSync(Util.encodeGbk(lines.join("\n")));
      Util.showDialog(title: "保存完成");
    } catch (e) {
      print(e);
      Util.showDialog(title: "错误", message: "$e");
    } finally {
      state.update((val) {
        val?.loading = false;
      });
    }
  }

  void _replaceKeyBindingLines({
    required List<String> lines,
    required UserSetting setting,
    int? offset,
  }) {
    for (MapEntry<String, int?> entry in setting.keyBindings.entries) {
      _replaceCfgLine(
        lines: lines,
        key: entry.key,
        value: entry.value.toString(),
        offset: offset,
      );
    }
  }

  void _replaceCfgLine({
    required List<String> lines,
    required String key,
    required String value,
    int? offset,
  }) {
    int index = lines.indexWhere(
      (e) {
        var firstCheck = e.trim().startsWith(key) && e.contains("=");
        if (!firstCheck) {
          return false;
        }
        List<String> array = e.split("=").map((e) => e.trim()).toList();
        return array[0] == key;
      },
      offset ?? 0,
    );
    if (index != -1) {
      lines[index] = sprintf("%-${minPropertyFormatLength}s=$value", [key]);
    }
  }

  UserState? _findExistingUserSetting({
    required List<String> lines,
    required bool p1,
    required String configDir,
    int? offset,
  }) {
    Directory dir = Directory(configDir);
    if (!dir.existsSync()) {
      return null;
    }
    List<String> paths = dir
        .listSync()
        .map((e) => e.path)
        .where((e) => e.endsWith("_${p1 ? "p1" : "p2"}.json"))
        .toList();
    if (paths.isEmpty) {
      return null;
    }
    Map<String, int?> configKeys = [
      GameKey.up,
      GameKey.down,
      GameKey.left,
      GameKey.right,
      GameKey.a,
      GameKey.b,
      GameKey.c,
      GameKey.d,
      GameKey.j,
      GameKey.k,
      GameKey.start,
    ].asMap().map(
          (key, value) => MapEntry(
            value.mugenName,
            _findIntProperty(
              lines: lines,
              key: value.mugenName,
              offset: offset,
            ),
          ),
        );
    for (int i = 0; i < paths.length; i++) {
      File file = File(paths[i]);
      var userSetting =
          UserSetting.fromJson(json.decode(file.readAsStringSync()));
      debugPrint(
        "comparing: ${file.path}\ncfg:\n${prettyJson(configKeys)}\njson:${prettyJson(userSetting.keyBindings)}",
      );
      if (mapEquals(userSetting.keyBindings, configKeys)) {
        return UserState(userSetting, file, UserState.stateSaved);
      }
    }
    return null;
  }

  String? _findStringProperty({
    required List<String> lines,
    required String key,
    int? offset,
  }) {
    int index = lines.indexWhere(
      (e) {
        var firstCheck = e.trim().startsWith(key) && e.contains("=");
        if (!firstCheck) {
          return false;
        }
        List<String> array = e.split("=").map((e) => e.trim()).toList();
        return array[0] == key;
      },
      offset ?? 0,
    );

    return index == -1
        ? null
        : lines[index].substring(lines[index].indexOf("=") + 1).trim();
  }

  int? _findIntProperty({
    required List<String> lines,
    required String key,
    int? offset,
  }) {
    return int.tryParse(
      _findStringProperty(lines: lines, key: key, offset: offset) ?? "",
    );
  }
}
