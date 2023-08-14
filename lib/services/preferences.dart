import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class KeyValueService extends GetxService {
  static KeyValueService get to => Get.find();

  static const keyResolutionWidth = "keyResolutionWidth";
  static const keyResolutionHeight = "keyResolutionHeight";
  static const keyConfigDir = "keyConfigDir";
  static const keyMugenFilePath = "keyMugenFilePath";
  static const keyLastSelectedDir = "keyLastSelectedDir";

  final GetStorage _storage = GetStorage();

  bool hasKey(String key) {
    return _storage.hasData(key);
  }

  String? getString(String key) {
    var value = _storage.read<String>(key);
    return value;
  }

  int? getInt(String key) {
    var value = _storage.read<int>(key);
    return value;
  }

  double? getDouble(String key) {
    var value = _storage.read<double>(key);
    return value;
  }

  bool? getBool(String key) {
    var value = _storage.read<bool>(key);
    return value;
  }

  Future<void> putString(String key, String? value) async {
    if (value == null) {
      _storage.remove(key);
      return;
    }
    await _storage.write(key, value);
  }

  Future<void> putInt(String key, int? value) async {
    if (value == null) {
      _storage.remove(key);
      return;
    }
    await _storage.write(key, value);
  }

  Future<void> putDouble(String key, double? value) async {
    if (value == null) {
      _storage.remove(key);
      return;
    }
    await _storage.write(key, value);
  }

  Future<void> putBool(String key, bool? value) async {
    if (value == null) {
      _storage.remove(key);
      return;
    }
    await _storage.write(key, value);
  }
}
