//check_password_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_data_provider.dart';

class CheckPasswordScreen extends StatefulWidget {
  const CheckPasswordScreen({super.key});

  @override
  _CheckPasswordScreenState createState() => _CheckPasswordScreenState();
}

class _CheckPasswordScreenState extends State<CheckPasswordScreen> {
  bool showNormalPassword = false;
  bool showSpecialPassword = false;

  void togglePasswordVisibility(String passwordType) {
    setState(() {
      if (passwordType == 'normal') {
        showNormalPassword = !showNormalPassword;
      } else if (passwordType == 'special') {
        showSpecialPassword = !showSpecialPassword;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[700],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<UserDataProvider>(
            builder: (context, userDataProvider, child) {
              final userData = userDataProvider.userData;
              
              if (userData == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Check Passwords',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _buildPasswordCard('Normal Password', userData.normalPassword,
                      showNormalPassword, () => togglePasswordVisibility('normal')),
                  const SizedBox(height: 16),
                  _buildPasswordCard(
                      'Special Password',
                      userData.specialPassword,
                      showSpecialPassword,
                      () => togglePasswordVisibility('special')),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue[700],
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordCard(String title, String? password, bool showPassword,
      VoidCallback onToggle) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.blue[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  showPassword ? (password ?? '') : '••••••••',
                  style: TextStyle(
                    color: showPassword ? Colors.black : Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: onToggle,
                  child: Text(
                    showPassword ? 'Hide' : 'Show',
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}