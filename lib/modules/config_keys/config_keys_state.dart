import 'package:kofz_key_manager/models.dart';
import 'package:universal_io/io.dart';

class ConfigKeysState {
  UserState p1;
  UserState p2;

  ConfigKeysState({required this.p1, required this.p2});
}

class UserState {
  static const stateEmpty = 0;
  static const stateChanged = 1;
  static const stateSaved = 2;
  UserSetting setting;
  File? file;
  int state;

  UserState(this.setting, this.file, this.state);

  UserState.empty(bool p1)
      : state = stateEmpty,
        setting = UserSetting.empty(p1, "");
}
