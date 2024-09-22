import 'dart:async';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:launcher_app/screens/Base_Home.dart';
import 'package:launcher_app/screens/FilteredHomeScreen.dart';
import 'package:launcher_app/screens/PinCodeScreen.dart';
import 'package:launcher_app/screens/home_screen.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:provider/provider.dart';
import 'models/user_data.dart';
import 'services/connectivity_service.dart';
import 'services/user_data_provider.dart';
import 'services/navigation_service.dart';
import 'services/cache_service.dart';
import 'firebase/firebase_service.dart';
import 'services/sync_service.dart';
import 'screens/welcome_screen.dart';
import 'screens/ban_screen.dart';
import 'screens/ready_screen.dart';
import 'screens/normal_password_screen.dart';
import 'screens/special_password_screen.dart';
import 'screens/edit_passwords_screen.dart';
import 'screens/edit_normal_password_screen.dart';
import 'screens/edit_special_password_screen.dart';
import 'screens/check_password_screen.dart';
import 'screens/manage_apps_screen.dart';
import 'package:launcher_app/screens/splash_screen.dart';
import 'package:local_auth/local_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyBHc5hrPRAe9CNgg-nfB7a0ElM4pCHGdyo",
        appId: "1:889234148695:android:6a81c294ce6d6f8e774212Rr",
        storageBucket: "lockscreenapp-281d1.appspot.com",
        projectId: "lockscreenapp-281d1",
        messagingSenderId: '889234148695'),
  );

  // Initialize Hive
  final appDocumentDirectory = await path_provider.getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDirectory.path);
  Hive.registerAdapter(UserDataAdapter());
  await Hive.openBox<UserData>('userData');

  // Initialize services
  final cacheService = CacheService();
  await cacheService.init();
  final firebaseService = FirebaseService();
  final syncService = SyncService(firebaseService, cacheService);
  final navigationService = NavigationService();

  // Fetch and cache installed apps
  List<Application> allApps = await DeviceApps.getInstalledApplications(
    includeAppIcons: true,
    includeSystemApps: true,
    onlyAppsWithLaunchIntent: true,
  );

  // Filter out the launcher app
  allApps = allApps.where((app) => app.packageName != 'com.example.launcher_app').toList();

  // Initialize UserDataProvider
  final userDataProvider = UserDataProvider(
    cacheService,
    firebaseService,
    syncService,
    navigationService,
  );

  // Perform an initial manual sync
  await userDataProvider.initializeUserData();

  // Set up periodic sync (every 5 seconds)
  Timer.periodic(const Duration(seconds: 5), (_) async {
    await userDataProvider.initializeUserData();
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
        Provider(create: (_) => navigationService),
        ChangeNotifierProvider.value(value: userDataProvider),
        Provider<List<Application>>.value(value: allApps),
        Provider<CacheService>.value(value: cacheService),
        Provider<FirebaseService>.value(value: firebaseService),
        Provider<SyncService>.value(value: syncService),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _authenticate(); // Start biometric authentication on app load
  }

  // Function to authenticate the user
  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to access the launcher app',
        options: const AuthenticationOptions(biometricOnly: true),
      );
    } catch (e) {
      print('Error using biometric authentication: $e');
    }

    if (!mounted) return;

    setState(() {
      _isAuthenticated = authenticated;
    });
  }

  @override
  Widget build(BuildContext context) {
    final navigationService = Provider.of<NavigationService>(context, listen: false);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Launcher App',
      navigatorKey: navigationService.navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Show LockScreen if not authenticated, else show the main app (SplashScreen)
      home: _isAuthenticated ? SplashScreen() : LockScreen(onAuthenticate: _authenticate),
      routes: {
        '/welcome': (context) => WelcomeScreen(),
        '/normal_password': (context) => NormalPasswordScreen(),
        '/base': (context) => AccessGate(child: BaseHomeScreen()),
        '/filtered': (context) => AccessGate(child: FilteredHomeScreen()),
        '/pin_code': (context) => PinCodeScreen(),
        '/special_password': (context) => SpecialPasswordScreen(),
        '/ready': (context) => ReadyScreen(),
        '/edit_passwords': (context) => AccessGate(child: const EditPasswordsScreen()),
        '/edit_normal_password': (context) => AccessGate(child: const EditNormalPasswordScreen()),
        '/edit_special_password': (context) => AccessGate(child: const EditSpecialPasswordScreen()),
        '/check_password': (context) => AccessGate(child: const CheckPasswordScreen()),
        '/home': (context) => AccessGate(child: HomeScreen()),
        '/manage_apps': (context) => AccessGate(child: ManageAppsScreen()),
        '/ban': (context) => BanScreen(),
      },
    );
  }
}

class LockScreen extends StatelessWidget {
  final VoidCallback onAuthenticate;

  const LockScreen({super.key, required this.onAuthenticate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Authentication Required')),
      body: Center(
        child: ElevatedButton(
          onPressed: onAuthenticate,
          child: const Text('Authenticate'),
        ),
      ),
    );
  }
}

class AccessGate extends StatelessWidget {
  final Widget child;

  const AccessGate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDataProvider>(
      builder: (context, userDataProvider, _) {
        if (userDataProvider.userData == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/welcome');
          });
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (!userDataProvider.userData!.appAccess) {
          return BanScreen();
        }
        return child;
      },
    );
  }
}
