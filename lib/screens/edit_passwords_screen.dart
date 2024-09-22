//edit_passwords_screen.dart
import 'package:flutter/material.dart';

class EditPasswordsScreen extends StatelessWidget {
  const EditPasswordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[700],
      body: SafeArea(
        child: Center(
          // Wrap with Center
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Use min to wrap content tightly
              children: [
                const Text(
                  'Edit Passwords',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                _buildPasswordButton(
                  context,
                  'Edit Normal Password',
                  '/edit_normal_password',
                ),
                const SizedBox(height: 16),
                _buildPasswordButton(
                  context,
                  'Edit Special Password',
                  '/edit_special_password',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordButton(
      BuildContext context, String title, String route) {
    return ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, route),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue[700],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      ),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
