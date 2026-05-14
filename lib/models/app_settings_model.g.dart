// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppSettingsModelImpl _$$AppSettingsModelImplFromJson(
  Map<String, dynamic> json,
) => _$AppSettingsModelImpl(
  isDarkMode: json['isDarkMode'] as bool? ?? true,
  notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
  backupEmail: json['backupEmail'] as String? ?? '',
  appVersion: json['appVersion'] as String? ?? '1.0.0',
);

Map<String, dynamic> _$$AppSettingsModelImplToJson(
  _$AppSettingsModelImpl instance,
) => <String, dynamic>{
  'isDarkMode': instance.isDarkMode,
  'notificationsEnabled': instance.notificationsEnabled,
  'backupEmail': instance.backupEmail,
  'appVersion': instance.appVersion,
};
