//services_hidden_apps_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class HiddenAppsService {
  static const String _hiddenAppsKey = 'hiddenApps';
  static const platform = MethodChannel('com.example.launcher_app/app_data');

  Future<void> setHiddenApps(List<String> hiddenApps) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_hiddenAppsKey, hiddenApps);
  }

  Future<List<String>> getHiddenApps() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_hiddenAppsKey) ?? [];
  }

  Future<void> clearHiddenApps() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hiddenAppsKey);
  }

}