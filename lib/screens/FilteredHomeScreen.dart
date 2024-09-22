//FiltredHomeScreen.dart
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';

import 'package:launcher_app/screens/PinCodeScreen.dart';
import 'package:launcher_app/services/user_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:launcher_app/services/hidden_apps_service.dart';

class FilteredHomeScreen extends StatefulWidget {
  final bool filterHiddenApps;

  const FilteredHomeScreen({super.key, this.filterHiddenApps = false});

  @override
  _FilteredHomeScreenState createState() => _FilteredHomeScreenState();
}

class _FilteredHomeScreenState extends State<FilteredHomeScreen> with WidgetsBindingObserver {
  final HiddenAppsService _hiddenAppsService = HiddenAppsService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkForPinScreen();
    }
  }

  void _checkForPinScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PinCodeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Application> allApps = Provider.of<List<Application>>(context);
    final userDataProvider = Provider.of<UserDataProvider>(context);

    return Consumer<UserDataProvider>(
      builder: (context, userDataProvider, _) {
        final userData = userDataProvider.userData;
        if (userData == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<String> hiddenApps = userData.hiddenApps.values.where((app) => app.isNotEmpty).toList();
        final List<Application> filteredApps = allApps
            .where((app) => 
                !hiddenApps.contains(app.packageName) &&
                app.packageName != 'com.android.vending' 
            )
            .toList();

        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              const SizedBox(height: 80),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: filteredApps.length,
                  itemBuilder: (context, index) {
                    Application app = filteredApps[index];
                    return GestureDetector(
                      onTap: () => DeviceApps.openApp(app.packageName),
                      onLongPress: () => _showAppOptionsModal(context, app),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child:(app is ApplicationWithIcon)
                                  ? Image.memory(app.icon, fit: BoxFit.cover)
                                  : const Icon(Icons.android, size: 48),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            app.appName,
                            style: const TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAppOptionsModal(BuildContext context, Application app) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('App Info'),
                onTap: () {
                  Navigator.pop(context);
                  DeviceApps.openAppSettings(app.packageName);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Uninstall'),
                onTap: () {
                  Navigator.pop(context);
                  _uninstallApp(context, app);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _uninstallApp(BuildContext context, Application app) async {
    bool? wasUninstalled = await DeviceApps.uninstallApp(app.packageName);
    if (wasUninstalled == true) {
      Provider.of<List<Application>>(context, listen: false).removeWhere((a) => a.packageName == app.packageName);
    }
  }
}