import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kofz_key_manager/services/file.dart';
import 'package:starrail_ui/views/buttons/normal.dart';
import 'package:starrail_ui/views/input/text.dart';

import 'system_logic.dart';

class SystemPage extends StatelessWidget {
  const SystemPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<SystemLogic>();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInput(
                  controller: logic.configDirController,
                  label: "按键保存目录",
                ),
              ),
              const SizedBox(width: 16),
              SRButton.text(
                onPress: () async {
                  Directory? dir = await FileService.to.selectDir();
                  if (dir == null) {
                    return;
                  }
                  logic.updateConfigDir(dir.path);
                },
                text: "选择...",
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInput(
                  controller: logic.mugenFileController,
                  label: "mugen.cfg路径",
                ),
              ),
              const SizedBox(width: 16),
              SRButton.text(
                highlightType: SRButtonHighlightType.highlighted,
                onPress: () async {
                  File? file = await FileService.to.selectFile("cfg");
                  if (file == null) {
                    return;
                  }
                  logic.load(file.path);
                },
                text: "载入",
              ),
              const SizedBox(width: 8),
              SRButton.text(
                highlightType: SRButtonHighlightType.highlighted,
                onPress: logic.save,
                text: "保存",
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInput(
                  controller: logic.masterVolumeController,
                  label: "主音量",
                  onChanged: logic.updateMasterVolume,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInput(
                  controller: logic.bgmVolumeController,
                  label: "音乐音量",
                  onChanged: logic.updateBgmVolume,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInput(
                  controller: logic.efxVolumeController,
                  label: "音效音量",
                  onChanged: logic.updateEfxVolume,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    ValueChanged<String>? onChanged,
    bool enabled = true,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        const SizedBox(width: 8),
        Expanded(
          child: SRTextField(
            controller: controller,
            enabled: enabled,
            showClearButton: false,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
