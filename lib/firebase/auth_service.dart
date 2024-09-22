//firebase/auth_service.dart
import 'firebase_setup.dart';

Future<void> signInUser() async {
  try {
    await auth.signInAnonymously();
  } catch (error) {
    print("Error signing in: $error");
    rethrow;
  }
}