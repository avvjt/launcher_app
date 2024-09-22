//screens/ban_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:android_intent_plus/android_intent.dart';

class BanScreen extends StatelessWidget {
  const BanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Prevent going back
    return WillPopScope(
      onWillPop: () async {
        await deactivateLauncher();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.red[900],
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.block,
                    size: 100,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'ACCESS DENIED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Your access to this app has been revoked by the administrator.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () async {
                      await deactivateLauncher();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red[900],
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    child: Text('Exit App'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> deactivateLauncher() async {
    final intent = const AndroidIntent(
      action: 'android.settings.HOME_SETTINGS',
    );
    await intent.launch();
  }
}