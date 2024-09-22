//home_screen.dart
import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLauncherActive = false;
  bool _shouldSkipPinCode = false;
  static const platform = MethodChannel('com.example.launcher_app/launcher');

  @override
  void initState() {
    super.initState();
    _checkLauncherStatus();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showAlert());
  }

  void _showAlert() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.notifications_off, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Remember to set notifications to OFF in special mode.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 5),
        backgroundColor: Colors.blue[900],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<void> _checkLauncherStatus() async {
    try {
      final bool result = await platform.invokeMethod('isDefaultLauncher');
      setState(() {
        _isLauncherActive = result;
      });
    } on PlatformException catch (e) {
      print("Failed to check launcher status: '${e.message}'.");
    }
  }

  Future<void> _toggleLauncher(bool value) async {
    if (value) {
      _setAsDefaultLauncher();
    } else {
      _openDefaultLauncherSettings();
    }
  }

  void _setAsDefaultLauncher() async {
    final intent = const AndroidIntent(
      action: 'android.settings.HOME_SETTINGS',
    );
    await intent.launch();
  }

  void _openDefaultLauncherSettings() async {
    _shouldSkipPinCode = true;
    final intent = const AndroidIntent(
      action: 'android.settings.HOME_SETTINGS',
    );
    await intent.launch();

    if (_shouldSkipPinCode) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/pin_code'); 
    }
  }

  void _navigateToCheckPassword(BuildContext context) {
    Navigator.of(context).pushNamed('/check_password');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[700],
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.apps),
            onPressed: () {
              Navigator.pushNamed(context, '/base', arguments: {'refresh': false, 'isNormalPassword': true});
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Image.asset('assets/android.png', width: 80, height: 80),
              const SizedBox(height: 32),
              _buildToggleTile(
                title: 'Start Launcher',
                value: _isLauncherActive,
                onChanged: _toggleLauncher,
              ),
              _buildOptionTile(
                context: context,
                icon: 'assets/edit-icon.png',
                title: 'Edit Passwords',
                onTap: () => Navigator.of(context).pushNamed('/edit_passwords'),
              ),
              _buildOptionTile(
                context: context,
                icon: 'assets/check-icon.png',
                title: 'Check Password',
                onTap: () => _navigateToCheckPassword(context),
              ),
              _buildOptionTile(
                context: context,
                icon: 'assets/settings-icon.png',
                title: 'Manage Apps',
                onTap: () => Navigator.of(context).pushNamed('/manage_apps'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.blue[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue[700],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Image.asset(icon, width: 24, height: 24),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: Colors.blue[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}