// lib/services/user_data_provider.dart

import 'package:flutter/foundation.dart';
import '../models/user_data.dart';
import 'cache_service.dart';
import '../firebase/firebase_service.dart';
import 'sync_service.dart';
import 'navigation_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';

class UserDataProvider with ChangeNotifier {
  UserData? _userData;
  final CacheService _cacheService;
  final FirebaseService _firebaseService;
  final SyncService _syncService;
  final NavigationService _navigationService;
  String? _serialNumber;
  bool _isUpdating = false;

  UserDataProvider(
    this._cacheService,
    this._firebaseService,
    this._syncService,
    this._navigationService,
  );

  UserData? get userData => _userData;

  Future<void> addHiddenApp(String packageName, String appName) async {
    if (_userData != null) {
      _userData!.hiddenApps[packageName] = appName;
      _userData!.incrementVersion();
      await _updateUserDataAndSync();
    }
  }

  Future<void> removeHiddenApp(String packageName) async {
    if (_userData != null) {
      _userData!.hiddenApps.remove(packageName);
      _userData!.incrementVersion();
      await _updateUserDataAndSync();
    }
  }

  bool isAppHidden(String packageName) {
    return _userData?.hiddenApps.containsKey(packageName) ?? false;
  }

  Future<bool> initializeUserData() async {
    _serialNumber = await getDeviceSerialNumber();
    if (_serialNumber != null) {
      _userData = await _cacheService.getUserData(_serialNumber!);
      if (_userData == null) {
        _userData = await _firebaseService.fetchUserData(_serialNumber!);
        if (_userData != null) {
          await _cacheService.saveUserData(_userData!);
        }
      }
      if (_userData != null) {
        _syncService.startSync(_serialNumber!);
        return true;
      }
    }
    return false;
  }

  Future<void> createUser(
    String username,
    String serialNumber,
    String normalPassword,
    String specialPassword
  ) async {
    final userData = UserData(
      id: const Uuid().v4(),
      username: username,
      phoneSerialNumber: serialNumber,
      normalPassword: normalPassword,
      specialPassword: specialPassword,
    );
    userData.incrementVersion();
    await _firebaseService.createUser(userData);
    await _cacheService.saveUserData(userData);
    _userData = userData;
    _serialNumber = serialNumber;
    _syncService.startSync(serialNumber);
    notifyListeners();
  }

  Future<void> updateUserData(UserData userData) async {
    userData.incrementVersion();
    await _updateUserDataAndSync(userData: userData);
  }

  Future<void> setAppAccess(bool access) async {
    if (_userData != null) {
      _userData!.appAccess = access;
      _userData!.incrementVersion();
      await _updateUserDataAndSync();
    }
  }

  Future<String?> getDeviceSerialNumber() async {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
    return androidInfo.id;
  }

  Future<void> _updateUserDataAndSync({UserData? userData}) async {
    if (_isUpdating) return;
    _isUpdating = true;

    try {
      userData ??= _userData;
      if (userData != null && _serialNumber != null) {
        userData.incrementVersion();
        await _cacheService.updateUserData(userData);
        _userData = userData;
        notifyListeners();
        
        // Perform Firebase update in the background
        _firebaseService.updateUserData(userData).then((_) {
          _syncService.syncData(_serialNumber!);
        });
      }
    } finally {
      _isUpdating = false;
    }
  }

  Future<void> forceSyncToFirebase() async {
    if (_userData != null && _serialNumber != null) {
      await _cacheService.forceSync();
      await _firebaseService.updateUserData(_userData!);
      await _syncService.syncData(_serialNumber!);
    }
  }
}