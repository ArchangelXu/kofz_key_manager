import 'dart:convert';
import 'dart:io';

import 'package:charset/charset.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kofz_key_manager/models.dart';
import 'package:starrail_ui/views/dialog.dart';

class Util {
  static void showDialog({
    required String title,
    String? message,
  }) {
    SRDialog.showMessage(
      context: Get.context!,
      message: message ?? "",
      title: title,
    );
  }

  static void saveKeyConfig(UserSetting setting, File file) {
    file.writeAsStringSync(json.encode(setting.toJson()));
  }

  static UserSetting loadKeyConfig(File file) {
    return UserSetting.fromJson(json.decode(file.readAsStringSync()));
  }

  static String decodeGbk(File file) {
    Uint8List bytes = file.readAsBytesSync();
    return gbk.decode(bytes);
  }

  static List<int> encodeGbk(String content) {
    return gbk.encode(content);
  }
}

class KeyMapping {
  static final _keyMapping = <LogicalKeyboardKey, int>{
    // row 0
    LogicalKeyboardKey.digit1: 49,
    LogicalKeyboardKey.digit2: 50,
    LogicalKeyboardKey.digit3: 51,
    LogicalKeyboardKey.digit4: 52,
    LogicalKeyboardKey.digit5: 53,
    LogicalKeyboardKey.digit6: 54,
    LogicalKeyboardKey.digit7: 55,
    LogicalKeyboardKey.digit8: 56,
    LogicalKeyboardKey.digit9: 57,
    LogicalKeyboardKey.digit0: 48,
    LogicalKeyboardKey.minus: 45,
    // row 1
    LogicalKeyboardKey.keyQ: 113,
    LogicalKeyboardKey.keyW: 119,
    LogicalKeyboardKey.keyE: 101,
    LogicalKeyboardKey.keyR: 114,
    LogicalKeyboardKey.keyT: 116,
    LogicalKeyboardKey.keyY: 121,
    LogicalKeyboardKey.keyU: 117,
    LogicalKeyboardKey.keyI: 105,
    LogicalKeyboardKey.keyO: 111,
    LogicalKeyboardKey.keyP: 112,
    LogicalKeyboardKey.bracketLeft: 91,
    // row 2
    LogicalKeyboardKey.keyA: 97,
    LogicalKeyboardKey.keyS: 115,
    LogicalKeyboardKey.keyD: 100,
    LogicalKeyboardKey.keyF: 102,
    LogicalKeyboardKey.keyG: 103,
    LogicalKeyboardKey.keyH: 104,
    LogicalKeyboardKey.keyJ: 106,
    LogicalKeyboardKey.keyK: 107,
    LogicalKeyboardKey.keyL: 108,
    LogicalKeyboardKey.semicolon: 59,
    LogicalKeyboardKey.quoteSingle: 39,
    // row 3
    LogicalKeyboardKey.keyZ: 122,
    LogicalKeyboardKey.keyX: 120,
    LogicalKeyboardKey.keyC: 99,
    LogicalKeyboardKey.keyV: 118,
    LogicalKeyboardKey.keyB: 98,
    LogicalKeyboardKey.keyN: 110,
    LogicalKeyboardKey.keyM: 109,
    LogicalKeyboardKey.comma: 44,
    LogicalKeyboardKey.period: 46,
    LogicalKeyboardKey.slash: 47,
    // row numpad
    LogicalKeyboardKey.numpad0: 256,
    LogicalKeyboardKey.numpad1: 257,
    LogicalKeyboardKey.numpad2: 258,
    LogicalKeyboardKey.numpad3: 259,
    LogicalKeyboardKey.numpad4: 260,
    LogicalKeyboardKey.numpad5: 261,
    LogicalKeyboardKey.numpad6: 262,
    LogicalKeyboardKey.numpad7: 263,
    LogicalKeyboardKey.numpad8: 264,
    LogicalKeyboardKey.numpad9: 265,
    LogicalKeyboardKey.numpadDecimal: 266,
    // control area
    LogicalKeyboardKey.insert: 277,
    LogicalKeyboardKey.home: 278,
    LogicalKeyboardKey.pageUp: 280,
    LogicalKeyboardKey.delete: 127,
    LogicalKeyboardKey.end: 279,
    LogicalKeyboardKey.pageDown: 281,
    LogicalKeyboardKey.equal: 61,
    LogicalKeyboardKey.numpadDivide: 267,
    LogicalKeyboardKey.numpadMultiply: 268,
    LogicalKeyboardKey.numpadSubtract: 269,
    LogicalKeyboardKey.numpadAdd: 270,
  };
  static final Map<int, int> _mapping =
      _keyMapping.map((key, value) => MapEntry(key.keyId, value));
  static final Map<int, LogicalKeyboardKey> _reversedMapping =
      _keyMapping.map((key, value) => MapEntry(value, key));

  static LogicalKeyboardKey? getKeyboardKeyName(int? mugenKeyCode) {
    return _reversedMapping[mugenKeyCode];
  }

  static int getMugenKeyCode(int keyId) {
    int? mapping = _mapping[keyId];
    var key = LogicalKeyboardKey.findKeyByKeyId(keyId);
    int result = mapping ?? keyId;
    if (result > 300) {
      debugPrint("warning: '${key?.keyLabel}': $result");
    } else if (mapping == null) {
      debugPrint("warning: '${key?.keyLabel}': no mapping");
    } else if (result != keyId) {
      debugPrint(
        "warning: '${key?.keyLabel}': mapping value is $mapping but keyId is $keyId",
      );
    }
    return result;
  }
}
