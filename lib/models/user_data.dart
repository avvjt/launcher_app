//lib/models/user_data.dart
import 'dart:convert';
import 'package:hive/hive.dart';

part 'user_data.g.dart';

@HiveType(typeId: 0)
class UserData extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String username;

  @HiveField(2)
  String phoneSerialNumber;

  @HiveField(3)
  bool appAccess;

  @HiveField(4)
  String normalPassword;

  @HiveField(5)
  String specialPassword;

  @HiveField(6)
  Map<String, String> hiddenApps;

  @HiveField(7)
  int version;

  @HiveField(8)
  DateTime lastUpdated;

  UserData({
    required this.id,
    required this.username,
    required this.phoneSerialNumber,
    this.appAccess = true,
    required this.normalPassword,
    required this.specialPassword,
    this.hiddenApps = const {},
    this.version = 0,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'phoneSerialNumber': phoneSerialNumber,
      'appAccess': appAccess,
      'normalPassword': normalPassword,
      'specialPassword': specialPassword,
      'hiddenApps': hiddenApps,
      'version': version,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      phoneSerialNumber: map['phoneSerialNumber'] ?? '',
      appAccess: map['appAccess'] ?? true,
      normalPassword: map['normalPassword'] ?? '',
      specialPassword: map['specialPassword'] ?? '',
      hiddenApps: Map<String, String>.from(map['hiddenApps'] ?? {}),
      version: map['version'] ?? 0,
      lastUpdated: DateTime.parse(map['lastUpdated'] ?? DateTime.now().toIso8601String()),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserData.fromJson(String source) => UserData.fromMap(json.decode(source));

  void incrementVersion() {
    version++;
    lastUpdated = DateTime.now();
  }
}
