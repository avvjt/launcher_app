//ready_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/user_data_provider.dart';
import 'package:provider/provider.dart';
import '../services/connectivity_service.dart';

class ReadyScreen extends StatelessWidget {
  const ReadyScreen({super.key});

  
  Future<void> handleFinish(BuildContext context, Map arguments) async {
    try {
      // Get the providers
      final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
      final connectivityService = Provider.of<ConnectivityService>(context, listen: false);

      // Get the device serial number
      String? serialNumber = await userDataProvider.getDeviceSerialNumber();

      // Check for network connectivity
      if (connectivityService.isConnected) {
        // Create user using UserDataProvider
        await userDataProvider.createUser(
          arguments['username'],
          serialNumber!,
          arguments['normalPassword'],
          arguments['specialPassword']
        );
      } else {
        // If offline, show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No internet connection. Please connect and try again.")),
        );
        return;
      }

      // Navigate to the pin code screen
      Navigator.of(context).pushReplacementNamed('/pin_code');
    } catch (error) {
      print('Error creating user: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;

    return Scaffold(
      backgroundColor: Colors.blue[700],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Your app is ready!',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SvgPicture.asset('assets/finish.svg', width: 80, height: 80),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => handleFinish(context, arguments),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                  child: Text('Finish'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}