//utils/app_utils.dart
import 'package:flutter/services.dart';

class AppUtils {
  static const platform = MethodChannel('com.example.launcher_app/app_list');

  static Future<List<Map<String, dynamic>>> getInstalledApps() async {
    try {
      final List<dynamic> result =
          await platform.invokeMethod('getInstalledApps');
      return result.map((app) => _castMap(app)).toList();
    } on PlatformException catch (e) {
      print("Failed to get installed apps: '${e.message}'.");
      return [];
    }
  }

  static Map<String, dynamic> _castMap(dynamic item) {
    if (item is Map) {
      return item.map((key, value) {
        if (value is Map) {
          return MapEntry(key.toString(), _castMap(value));
        } else if (value is List) {
          return MapEntry(key.toString(), _castList(value));
        } else {
          return MapEntry(key.toString(), value);
        }
      });
    }
    return {};
  }

  static List<dynamic> _castList(List list) {
    return list.map((item) {
      if (item is Map) {
        return _castMap(item);
      } else if (item is List) {
        return _castList(item);
      } else {
        return item;
      }
    }).toList();
  }
}
