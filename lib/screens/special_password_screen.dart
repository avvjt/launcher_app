import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SpecialPasswordScreen extends StatefulWidget {
  const SpecialPasswordScreen({super.key});

  @override
  _SpecialPasswordScreenState createState() => _SpecialPasswordScreenState();
}

class _SpecialPasswordScreenState extends State<SpecialPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String _errorText = '';

  void handleSetPassword() {
    if (_passwordController.text == _confirmPasswordController.text &&
        _passwordController.text.length == 4) {
      final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
      Navigator.of(context).pushNamed(
        '/ready',
        arguments: {
          ...arguments,
          'specialPassword': _passwordController.text,
        },
      );
    } else {
      setState(() {
        _errorText = "Passwords don't match or are not 4 digits";
      });
    }
  }

  void _validateInput(String value) {
    setState(() {
      if (value.length != 4) {
        _errorText = 'Password must be 4 digits';
      } else {
        _errorText = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Enter Special Password',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _passwordController,
                obscureText: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 4,
                onChanged: _validateInput,
                decoration: InputDecoration(
                  hintText: 'Enter 4-digit Special Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 4,
                onChanged: _validateInput,
                decoration: InputDecoration(
                  hintText: 'Confirm 4-digit Special Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorText,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: handleSetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: Text(
                  'Set Password',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}