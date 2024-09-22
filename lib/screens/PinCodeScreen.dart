//PinCodeScreen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_data_provider.dart';

class PinCodeScreen extends StatefulWidget {
  const PinCodeScreen({super.key});

  @override
  _PinCodeScreenState createState() => _PinCodeScreenState();
}

class _PinCodeScreenState extends State<PinCodeScreen> {
  String _enteredPin = '';
  final _pinLength = 4;
  late UserDataProvider _userDataProvider;

  @override
  void initState() {
    super.initState();
    _userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    try {
      await _userDataProvider.initializeUserData();
    } catch (error) {
      print("Error initializing user data: $error");
    }
  }

  void _handleNumberPress(String number) {
    if (_enteredPin.length < _pinLength) {
      setState(() {
        _enteredPin += number;
      });
      if (_enteredPin.length == _pinLength) {
        _verifyPin();
      }
    }
  }

  void _verifyPin() async {
    final userData = _userDataProvider.userData;

    if (userData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User data not loaded. Please try again.')),
      );
      return;
    }

    if (_enteredPin == userData.normalPassword) {
      Navigator.pushReplacementNamed(context, '/base');
    } else if (_enteredPin == userData.specialPassword) {
      Navigator.pushReplacementNamed(context, '/filtered');
    } else {
      setState(() {
        _enteredPin = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect PIN. Please try again.')),
      );
    }
  }

  void _handleBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue[700]!, Colors.blue[900]!],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Enter PIN',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pinLength,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index < _enteredPin.length ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    if (index == 9) {
                      return Container(); // Empty space
                    }
                    if (index == 10) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () => _handleNumberPress('0'),
                        child: const Text(
                          '0',
                          style: TextStyle(fontSize: 24, color: Colors.black),
                        ),
                      );
                    }
                    if (index == 11) {
                      return IconButton(
                        icon: const Icon(Icons.backspace, color: Colors.white),
                        onPressed: _handleBackspace,
                      );
                    }
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () => _handleNumberPress((index + 1).toString()),
                      child: Text(
                        (index + 1).toString(),
                        style: const TextStyle(fontSize: 24, color: Colors.black),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}