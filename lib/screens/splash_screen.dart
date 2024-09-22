// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:launcher_app/services/user_data_provider.dart';
import 'package:android_intent_plus/android_intent.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    await userDataProvider.initializeUserData();

    if (userDataProvider.userData == null) {
      Navigator.of(context).pushReplacementNamed('/welcome');
    } else if (!userDataProvider.userData!.appAccess) {
      await deactivateLauncher();
      Navigator.of(context).pushReplacementNamed('/ban');
    } else {
      Navigator.of(context).pushReplacementNamed('/base');
    }
  }

  Future<void> deactivateLauncher() async {
    final intent = const AndroidIntent(
      action: 'android.settings.HOME_SETTINGS',
    );
    await intent.launch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/launcher_app.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 30),
              const Text(
                'Launcher App',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 50),
              const SpinKitFadingCube(
                color: Colors.white,
                size: 50.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}