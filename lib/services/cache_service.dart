// lib/services/cache_service.dart

import 'dart:async';
import 'package:hive/hive.dart';
import '../models/user_data.dart';

class CacheService {
  late Box<UserData> _userDataBox;
  final Map<String, UserData> _memoryCache = {};
  final List<Future<void>> _updateQueue = [];

  Future<void> init() async {
    _userDataBox = await Hive.openBox<UserData>('userData');
    _loadMemoryCache();
  }

  void _loadMemoryCache() {
    for (var key in _userDataBox.keys) {
      _memoryCache[key.toString()] = _userDataBox.get(key)!;
    }
  }

  Future<UserData?> getUserData(String serialNumber) async {
    return _memoryCache[serialNumber] ?? _userDataBox.get(serialNumber);
  }

  Future<void> saveUserData(UserData userData) async {
    _memoryCache[userData.phoneSerialNumber] = userData;
    _queueUpdate(() => _userDataBox.put(userData.phoneSerialNumber, userData));
  }

  Future<void> updateUserData(UserData userData) async {
    _memoryCache[userData.phoneSerialNumber] = userData;
    _queueUpdate(() => _userDataBox.put(userData.phoneSerialNumber, userData));
  }

  void _queueUpdate(Future<void> Function() updateFunction) {
    _updateQueue.add(updateFunction());
    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_updateQueue.isNotEmpty) {
      await Future.wait(_updateQueue);
      _updateQueue.clear();
    }
  }

  Future<void> forceSync() async {
    await _processQueue();
  }
}