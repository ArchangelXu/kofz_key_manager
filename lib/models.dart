import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class UserSetting {
  final bool p1;
  String playerName;
  final Map<String, int?> keyBindings;

  UserSetting(this.p1, this.playerName, this.keyBindings);

  bool get allKeysSet => !keyBindings.values.contains(null);

  UserSetting.empty(this.p1, this.playerName)
      : keyBindings = [
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
        ].asMap().map((key, value) => MapEntry(value.mugenName, null));

  factory UserSetting.fromJson(Map<String, dynamic> json) =>
      _$UserSettingFromJson(json);

  Map<String, dynamic> toJson() => _$UserSettingToJson(this);

  @override
  String toString() {
    return 'UserSetting{p1: $p1, playerName: $playerName, keyBindings: $keyBindings}';
  }
}

class GameKey {
  final String label;
  final String mugenName;

  static GameKey get up => const GameKey._internal("上", "Jump");

  static GameKey get down => const GameKey._internal("下", "Crouch");

  static GameKey get left => const GameKey._internal("左", "Left");

  static GameKey get right => const GameKey._internal("右", "Right");

  static GameKey get a => const GameKey._internal("轻拳", "X");

  static GameKey get b => const GameKey._internal("轻脚", "A");

  static GameKey get c => const GameKey._internal("重拳", "Y");

  static GameKey get d => const GameKey._internal("重脚", "B");

  static GameKey get j => const GameKey._internal("爆豆", "Z");

  static GameKey get k => const GameKey._internal("重击", "C");

  static GameKey get start => const GameKey._internal("开始", "Start");
  static final List<GameKey> _all = [
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
  ];

  static GameKey fromMugenName(String name) =>
      _all.firstWhere((e) => e.mugenName == name);

  const GameKey._internal(this.label, this.mugenName);
}
