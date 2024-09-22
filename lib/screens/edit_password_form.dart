//edit_password_form.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/user_data_provider.dart';
import 'package:provider/provider.dart';

enum PasswordType { normal, special }

class EditPasswordForm extends StatefulWidget {
  final PasswordType passwordType;

  const EditPasswordForm({super.key, required this.passwordType});

  @override
  _EditPasswordFormState createState() => _EditPasswordFormState();
}

class _EditPasswordFormState extends State<EditPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.passwordType == PasswordType.normal
                  ? 'Normal Password'
                  : 'Special Password',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            _buildPasswordField('Old Password', _oldPasswordController),
            const SizedBox(height: 16),
            _buildPasswordField('New Password', _newPasswordController),
            const SizedBox(height: 16),
            _buildPasswordField('Confirm Password', _confirmPasswordController),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _updatePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
              ),
              child: const Text(
                'Update Password',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      obscureText: true,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a password';
        }
        if (value.length != 4) {
          return 'Password must be 4 digits';
        }
        return null;
      },
    );
  }

Future<void> _updatePassword() async {
  if (_formKey.currentState!.validate()) {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New password and confirm password do not match')),
      );
      return;
    }

    try {
      final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
      final userData = userDataProvider.userData;
      
      if (userData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User data not found')),
        );
        return;
      }

      final currentPassword = widget.passwordType == PasswordType.normal
          ? userData.normalPassword
          : userData.specialPassword;

      if (_oldPasswordController.text != currentPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect old password')),
        );
        return;
      }

      if (widget.passwordType == PasswordType.normal) {
        userData.normalPassword = _newPasswordController.text;
      } else {
        userData.specialPassword = _newPasswordController.text;
      }

      // Use updateUserData instead of saveUserData
      await userDataProvider.updateUserData(userData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully')),
      );

      Navigator.pop(context);
    } catch (error) {
      print('Error updating password: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update password')),
      );
    }
  }
}
}