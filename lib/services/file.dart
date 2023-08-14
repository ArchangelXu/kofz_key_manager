import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kofz_key_manager/services/preferences.dart';
import 'package:universal_io/io.dart';

class FileService extends GetxService {
  static FileService get to => Get.find();

  String get _lastDirectory =>
      KeyValueService.to.getString(KeyValueService.keyLastSelectedDir) ??
      (Platform.isWindows ? "C:\\" : "/");

  Future<File?> selectFile(String ext) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      initialDirectory: _lastDirectory,
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: [ext],
    );
    String? path = result?.files[0].path;
    _saveLastDirectory(path);
    return path == null ? null : File(path);
  }

  Future<Directory?> selectDir() async {
    String? path = await FilePicker.platform.getDirectoryPath(
      initialDirectory: _lastDirectory,
    );
    _saveLastDirectory(path);
    return path == null ? null : Directory(path);
  }

  Future<void> _saveLastDirectory(String? path) async {
    debugPrint("path=$path");
    if (path == null) {
      return;
    }
    String directory = path.substring(0, path.lastIndexOf("/"));
    await KeyValueService.to
        .putString(KeyValueService.keyLastSelectedDir, directory);
  }
}
