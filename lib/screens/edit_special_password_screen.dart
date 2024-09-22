import 'package:flutter/material.dart';
import 'edit_password_form.dart';

class EditSpecialPasswordScreen extends StatelessWidget {
  const EditSpecialPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[700],
      body: const SafeArea(
        child: EditPasswordForm(passwordType: PasswordType.special),
      ),
    );
  }
}