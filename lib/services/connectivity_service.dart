// services/connectivity_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isConnected = false;

  ConnectivityService() {
    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  bool get isConnected => _isConnected;

  Future<void> _initConnectivity() async {
    try {
      List<ConnectivityResult> results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      print("Couldn't check connectivity status: $e");
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    _isConnected = results.any((result) => result != ConnectivityResult.none);
    notifyListeners();
  }

  Future<bool> checkConnectivity() async {
    try {
      List<ConnectivityResult> results = await _connectivity.checkConnectivity();
      return results.any((result) => result != ConnectivityResult.none);
    } catch (e) {
      print("Error checking connectivity: $e");
      return false;
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}