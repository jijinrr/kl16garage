import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings_model.freezed.dart';
part 'app_settings_model.g.dart';

@freezed
class AppSettingsModel with _$AppSettingsModel {
  const factory AppSettingsModel({
    @Default(true) bool isDarkMode,
    @Default(true) bool notificationsEnabled,
    @Default('') String backupEmail,
    @Default('1.0.0') String appVersion,
  }) = _AppSettingsModel;

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsModelFromJson(json);

  static AppSettingsModel defaults() => const AppSettingsModel();
}
