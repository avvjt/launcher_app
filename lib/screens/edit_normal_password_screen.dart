import 'package:flutter/material.dart';
import 'edit_password_form.dart';

class EditNormalPasswordScreen extends StatelessWidget {
  const EditNormalPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[700],
      body: const SafeArea(
        child: EditPasswordForm(passwordType: PasswordType.normal),
      ),
    );
  }
}