// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSetting _$UserSettingFromJson(Map<String, dynamic> json) => UserSetting(
      json['p1'] as bool,
      json['player_name'] as String,
      Map<String, int?>.from(json['key_bindings'] as Map),
    );

Map<String, dynamic> _$UserSettingToJson(UserSetting instance) =>
    <String, dynamic>{
      'p1': instance.p1,
      'player_name': instance.playerName,
      'key_bindings': instance.keyBindings,
    };
