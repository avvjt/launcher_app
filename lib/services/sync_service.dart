// lib/services/sync_service.dart
import 'dart:async';
import '../firebase/firebase_service.dart';
import 'cache_service.dart';
import '../models/user_data.dart';

class SyncService {
  final FirebaseService _firebaseService;
  final CacheService _cacheService;
  Timer? _syncTimer;

  SyncService(this._firebaseService, this._cacheService);

  void startSync(String serialNumber) {
    _syncTimer = Timer.periodic(const Duration(seconds: 4), (_) => syncData(serialNumber));
  }

  void stopSync() {
    _syncTimer?.cancel();
  }

  Future<void> syncData(String serialNumber) async {
    try {
      UserData? cachedData = await _cacheService.getUserData(serialNumber);
      UserData? firebaseData = await _firebaseService.fetchUserData(serialNumber);

      if (firebaseData != null && cachedData != null) {
        if (firebaseData.version > cachedData.version) {
          // Firebase data is newer, update cache
          await _cacheService.updateUserData(firebaseData);
          print('Cache updated with newer Firebase data');
        } else if (cachedData.version > firebaseData.version) {
          // Cache is newer, update Firebase
          await _firebaseService.updateUserData(cachedData);
          print('Firebase updated with newer cached data');
        }
      } else if (firebaseData != null && cachedData == null) {
        // Firebase has data but cache is empty, update cache
        await _cacheService.saveUserData(firebaseData);
        print('Cache updated with Firebase data');
      } else if (cachedData != null && firebaseData == null) {
        // Cache has data but Firebase is empty, update Firebase
        await _firebaseService.createUser(cachedData);
        print('Firebase created with cached data');
      }

      // After sync, fetch the latest data from Firebase and update the cache
      UserData? latestFirebaseData = await _firebaseService.fetchUserData(serialNumber);
      if (latestFirebaseData != null) {
        await _cacheService.updateUserData(latestFirebaseData);
        print('Cache updated with latest Firebase data after sync');
      }
    } catch (e) {
      print('Error syncing data: $e');
    }
  }
}