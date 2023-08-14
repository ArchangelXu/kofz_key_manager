import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kofz_key_manager/models.dart';
import 'package:kofz_key_manager/modules/config_keys/config_keys_state.dart';
import 'package:kofz_key_manager/services/file.dart';
import 'package:kofz_key_manager/util.dart';
import 'package:starrail_ui/views/buttons/normal.dart';
import 'package:starrail_ui/views/card.dart';
import 'package:starrail_ui/views/input/text.dart';
import 'package:starrail_ui/views/progress/circular.dart';
import 'package:universal_io/io.dart';

import 'config_keys_logic.dart';

class ConfigKeysPage extends StatelessWidget {
  const ConfigKeysPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: SRCard(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: (UserSettingPage(p1: true)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: SRCard(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: (UserSettingPage(p1: false)),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (kDebugMode) TestKey(),
      ],
    );
  }
}

class UserSettingPage extends StatelessWidget {
  final bool p1;

  const UserSettingPage({super.key, required this.p1});

  void _onKeyChanged(String gameKey, int keyId) {
    final logic = Get.find<ConfigKeysLogic>();
    logic.updateKey(p1: p1, key: gameKey, keyId: keyId);
  }

  void _onSave() {
    final logic = Get.find<ConfigKeysLogic>();
    logic.save(p1: p1);
  }

  Future<void> _onLoad() async {
    File? file = await FileService.to.selectFile("json");
    if (file == null) {
      return;
    }
    final logic = Get.find<ConfigKeysLogic>();
    logic.load(file: file, p1: p1);
  }

  Widget _buildButton({
    required String text,
    required VoidCallback? onTap,
  }) {
    return SRButton.text(text: text, onPress: onTap);
  }

  Container _buildPlayerLabel() {
    var color = (p1 ? Colors.blueAccent : Colors.red);
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.75),
        border: Border.all(
          color: color,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Text(
        p1 ? "1P" : "2P",
        style: Get.textTheme.labelMedium?.copyWith(color: Colors.white),
      ),
    );
  }

  Widget _buildStateLabel() {
    final state = Get.find<ConfigKeysLogic>().state;
    var userState = p1 ? state.value.p1 : state.value.p2;
    int settingState = userState.state;
    Color color;
    String text;
    switch (settingState) {
      case UserState.stateChanged:
        {
          color = Colors.deepOrange;
          text = "未保存";
        }
      case UserState.stateSaved:
        {
          color = Colors.green;
          text = "已保存";
        }
      case UserState.stateEmpty:
      default:
        return const SizedBox.shrink();
    }
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.75),
        border: Border.all(
          color: color,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Text(
        text,
        style: Get.textTheme.labelMedium?.copyWith(color: Colors.white),
      ),
    );
  }

  Widget _buildKeys() {
    return Obx(() {
      return GridView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        children: [
          const SizedBox.shrink(),
          _buildKey(GameKey.up),
          const SizedBox.shrink(),
          _buildKey(GameKey.left),
          _buildKey(GameKey.down),
          _buildKey(GameKey.right),
          const SizedBox.shrink(),
          const SizedBox.shrink(),
          const SizedBox.shrink(),
          _buildKey(GameKey.a),
          _buildKey(GameKey.b),
          _buildKey(GameKey.k),
          _buildKey(GameKey.c),
          _buildKey(GameKey.d),
          _buildKey(GameKey.j),
          const SizedBox.shrink(),
          _buildKey(GameKey.start),
          const SizedBox.shrink(),
        ],
      );
    });
  }

  Widget _buildKey(GameKey key) {
    final state = Get.find<ConfigKeysLogic>().state;
    var userState = p1 ? state.value.p1 : state.value.p2;
    return GameKeySetting(
      gameKey: key,
      keyId: userState.setting.keyBindings[key.mugenName],
      onKeySet: (keyId, keyCode) => _onKeyChanged(key.mugenName, keyId),
    );
  }

  @override
  Widget build(BuildContext context) {
    var logic = Get.find<ConfigKeysLogic>();
    var state = logic.state;
    return Column(
      // mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _buildPlayerLabel(),
            const SizedBox(width: 16),
            const Text("玩家名"),
            const SizedBox(width: 8),
            Expanded(
              child: SRTextField(
                controller:
                    p1 ? logic.p1NameController : logic.p2NameController,
                onChanged: (value) =>
                    logic.updatePlayerName(p1: p1, value: value),
              ),
            ),
            const SizedBox(width: 24),
            Obx(() => _buildStateLabel()),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Spacer(),
            Obx(() {
              return _buildButton(
                text: "保存",
                onTap: [
                  UserState.stateSaved,
                  UserState.stateEmpty,
                ].contains((p1 ? state.value.p1 : state.value.p2).state)
                    ? null
                    : _onSave,
              );
            }),
            const SizedBox(width: 16),
            _buildButton(text: "载入", onTap: _onLoad),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Container(
            height: 1,
            color: Colors.black.withOpacity(0.1),
          ),
        ),
        _buildKeys(),
      ],
    );
  }
}

class TestKey extends StatefulWidget {
  const TestKey({super.key});

  @override
  State<TestKey> createState() => _TestKeyState();
}

class _TestKeyState extends State<TestKey> {
  int? keyId;
  String log = "";

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 160,
            child: XMKeyboardListener(
              labelText: "test",
              onKeySet: (keyId, keyCode) {
                log +=
                    "${(LogicalKeyboardKey.findKeyByKeyId(keyId)?.keyLabel ?? "-")} keyId=$keyId keyCode=$keyCode\n";
                setState(() {
                  this.keyId = keyId;
                });
              },
              keyText: keyId == null
                  ? "-"
                  : (LogicalKeyboardKey.findKeyByKeyId(keyId!)?.keyLabel ??
                      "-"),
            ),
          ),
          const SizedBox(width: 16),
          SRButton.text(
            highlightType: SRButtonHighlightType.highlighted,
            onPress: () {
              Clipboard.setData(ClipboardData(text: log));
              Util.showDialog(title: "copied");
            },
            text: "Save Log",
          ),
        ],
      ),
    );
  }
}

class GameKeySetting extends StatelessWidget {
  final GameKey gameKey;
  final int? keyId;
  final void Function(int keyId, int keyCode) onKeySet;

  const GameKeySetting({
    super.key,
    required this.gameKey,
    required this.keyId,
    required this.onKeySet,
  });

  @override
  Widget build(BuildContext context) {
    // return Container(
    //   width: 96,
    //   padding: const EdgeInsets.all(8.0),
    //   child: Column(
    //     mainAxisSize: MainAxisSize.min,
    //     children: [
    //       Text(gameKey.label),
    //       XMKeyboardListener(
    //         onKeySet: onKeySet,
    //         keyText: keyId == null
    //             ? "-"
    //             : (KeyMapping.getKeyboardKeyName(keyId!)?.keyLabel ?? "-"),
    //       ),
    //     ],
    //   ),
    // );
    return XMKeyboardListener(
      labelText: gameKey.label,
      onKeySet: onKeySet,
      keyText: keyId == null
          ? "-"
          : (KeyMapping.getKeyboardKeyName(keyId!)?.keyLabel ?? "-"),
    );
  }
}

class XMKeyboardListener extends StatefulWidget {
  final void Function(int keyId, int keyCode) onKeySet;
  final String labelText;
  final String keyText;

  const XMKeyboardListener({
    super.key,
    required this.onKeySet,
    required this.labelText,
    required this.keyText,
  });

  @override
  State<XMKeyboardListener> createState() => _XMKeyboardListenerState();
}

class _XMKeyboardListenerState extends State<XMKeyboardListener> {
  final FocusNode _node = FocusNode();

  bool _listen = false;
  String? _keyText;

  String get keyText => _keyText ?? widget.keyText;

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  Widget _buildButton() {
    // return ElevatedButton(
    //   style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
    //   onPressed: () {
    //     setState(() {
    //       _listen = true;
    //     });
    //     _node.requestFocus();
    //   },
    //   child: Text(
    //     _listen ? "请按键" : buttonText,
    //     // style: Get.textTheme.labelMedium?.copyWith(color: Colors.white),
    //   ),
    // );
    var buttonText = keyText.toLowerCase();
    if (buttonText.contains("numpad")) {
      buttonText = buttonText.replaceAll("numpad", "").trim();
      buttonText = "[$buttonText]";
    }
    buttonText = buttonText.toUpperCase();
    return SRButton.custom(
      expanded: true,
      onPress: () {
        setState(() {
          _listen = true;
        });
        _node.requestFocus();
      },
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(child: Center(child: Text(widget.labelText))),
          _listen
              ? const SRLoading(
                  size: 16, outerDotsRadius: 2, innerDotsRadius: 1)
              : ConstrainedBox(
                  constraints:
                      const BoxConstraints(minWidth: 16, maxHeight: 16),
                  child: Text(buttonText),
                ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _node,
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            setState(() {
              _listen = false;
            });
            return;
          }
          var character = event.character;
          var label = event.logicalKey.keyLabel;
          var keyId = event.logicalKey.keyId;
          dynamic data = event.data;
          debugPrint(
            "name=${event.logicalKey.debugName} character=$character label=$label keyId=$keyId keyCode=${data.keyCode}",
          );
          _node.unfocus();
          widget.onKeySet(event.logicalKey.keyId, data.keyCode);
          setState(() {
            _keyText = label;
            _listen = false;
          });
        }
      },
      child: _buildButton(),
    );
  }
}
