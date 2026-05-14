import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings_model.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider() {
    _load();
  }

  AppSettingsModel _settings = AppSettingsModel.defaults();

  AppSettingsModel get settings => _settings;
  bool get isDarkMode => _settings.isDarkMode;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _settings = _settings.copyWith(
      isDarkMode: prefs.getBool('dark_mode') ?? true,
      notificationsEnabled: prefs.getBool('notifications') ?? true,
    );
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _settings = _settings.copyWith(isDarkMode: !_settings.isDarkMode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _settings.isDarkMode);
    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    _settings = _settings.copyWith(
        notificationsEnabled: !_settings.notificationsEnabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', _settings.notificationsEnabled);
    notifyListeners();
  }
}
