import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _keyDarkMode = 'dark_mode';
  static const _keyLogoPath = 'company_logo_path';
  static const _keyCompanyName = 'company_name';

  Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, value);
  }

  Future<String?> getLogoPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLogoPath);
  }

  Future<void> setLogoPath(String? path) async {
    final prefs = await SharedPreferences.getInstance();
    if (path == null) {
      await prefs.remove(_keyLogoPath);
    } else {
      await prefs.setString(_keyLogoPath, path);
    }
  }

  Future<String> getCompanyName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCompanyName) ?? '';
  }

  Future<void> setCompanyName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCompanyName, name);
  }
}
