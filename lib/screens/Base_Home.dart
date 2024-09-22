//Base_Home
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';

import 'package:launcher_app/screens/PinCodeScreen.dart';
import 'package:provider/provider.dart';
import 'package:launcher_app/screens/home_screen.dart';

class BaseHomeScreen extends StatefulWidget {
  const BaseHomeScreen({super.key});

  @override
  _BaseHomeScreenState createState() => _BaseHomeScreenState();
}

class _BaseHomeScreenState extends State<BaseHomeScreen> with WidgetsBindingObserver {

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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen(), settings: const RouteSettings(arguments: {'refresh': false})),
              );
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.75,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: allApps.length,
        itemBuilder: (context, index) {
          Application app = allApps[index];
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
                    child: (app is ApplicationWithIcon)? Image.memory(app.icon, fit: BoxFit.cover):Container()

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