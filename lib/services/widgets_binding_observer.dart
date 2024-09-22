import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  _AppLockScreenState createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> with WidgetsBindingObserver {
  static const lockAppChannel = MethodChannel('com.example.app_locker/lock_app');
  bool _isAppLocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App is backgrounded
      lockApp();
      setState(() {
        _isAppLocked = true;
      });
    } else if (state == AppLifecycleState.resumed && _isAppLocked) {
      // App is resumed - Unlock the app here (e.g., show login screen)
      print('App resumed - lock the app');
      authenticateUser();
    }
  }

  Future<void> lockApp() async {
    try {
      await lockAppChannel.invokeMethod('removeFromRecents', {'packageName': 'com.example.targetapp'});
    } on PlatformException catch (e) {
      print("Failed to lock the app: ${e.message}");
    }
  }

  Future<void> authenticateUser() async {
    // Prompt for biometric or password authentication here
    print('Authenticate the user here');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(_isAppLocked ? 'App is locked' : 'App is running'),
      ),
    );
  }
}
