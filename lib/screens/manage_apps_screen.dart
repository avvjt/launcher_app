//manage_apps_screen.dart
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import '../models/user_data.dart';
import '../services/user_data_provider.dart';
import 'package:provider/provider.dart';

class ManageAppsScreen extends StatefulWidget {
  const ManageAppsScreen({super.key});

  @override
  _ManageAppsScreenState createState() => _ManageAppsScreenState();
}

class _ManageAppsScreenState extends State<ManageAppsScreen> {
  Map<String, bool> _selectedApps = {};
  bool _isLoading = false;
  late UserDataProvider _userDataProvider;

  @override
  void initState() {
    super.initState();
    _userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _initializeUserData();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _initializeUserData() async {
    bool initialized = await _userDataProvider.initializeUserData();
    if (!initialized) {
      throw Exception("Failed to initialize user data");
    }

    UserData? userData = _userDataProvider.userData;

    if (userData != null) {
      setState(() {
        _selectedApps = Map.fromEntries(userData.hiddenApps.entries
            .where((entry) => entry.value.isNotEmpty)
            .map((entry) => MapEntry(entry.value, true)));
      });
    } else {
      throw Exception("User data not found");
    }
  }

  void _toggleApp(String packageName) {
    setState(() {
      if (_selectedApps.containsKey(packageName)) {
        _selectedApps.remove(packageName);
      } else if (_selectedApps.length < 7) {
        _selectedApps[packageName] = true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You can only select up to 7 apps')),
        );
      }
    });
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, String> hiddenApps = {};
      _selectedApps.keys.toList().asMap().forEach((index, packageName) {
        hiddenApps['app${index + 1}'] = packageName;
      });

      for (int i = _selectedApps.length + 1; i <= 7; i++) {
        hiddenApps['app$i'] = '';
      }

      UserData updatedUserData = _userDataProvider.userData!;
      updatedUserData.hiddenApps = hiddenApps;
      await _userDataProvider.updateUserData(updatedUserData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved successfully')),
      );
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save changes: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildAppIcon(Application app) {
  return(app is ApplicationWithIcon)
      ? Image.memory(app.icon, width: 40, height: 40)
      : const Icon(Icons.android, size: 40);
}

  @override
  Widget build(BuildContext context) {
    final List<Application> allApps = Provider.of<List<Application>>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Apps'),
        backgroundColor: Colors.blue[700],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: allApps.length,
                    itemBuilder: (context, index) {
                      final app = allApps[index];
                      final isSelected = _selectedApps[app.packageName] ?? false;
                      final isDisabled = !isSelected && _selectedApps.length >= 7;

                      return ListTile(
                        leading: _buildAppIcon(app),
                        title: Text(app.appName),
                        trailing: Switch(
                          value: isSelected,
                          onChanged: isDisabled ? null : (_) => _toggleApp(app.packageName),
                          activeTrackColor: Colors.lightBlueAccent,
                          activeColor: Colors.blue,
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white, // Set text color to white
                      fontSize: 18.0, // Increase font size
                      fontWeight: FontWeight.bold, // Make text bold
                    ),
                  ),
                ),
              ),

              ],
            ),
    );
  }
}