//services/user_data_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../models/user_data.dart';

class UserDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Box<UserData> _userDataBox = Hive.box<UserData>('userData');

  Future<UserData?> fetchUserData(String phoneSerialNumber) async {
    try {
      return _userDataBox.get(phoneSerialNumber);
    } catch (error) {
      print("Error fetching user data from cache: $error");
      return null;
    }
  }

  Future<UserData?> fetchUserDataFromFirebase(String phoneSerialNumber) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection("users")
          .where("phoneSerialNumber", isEqualTo: phoneSerialNumber)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = querySnapshot.docs.first;
        UserData userData = UserData.fromMap(userDoc.data() as Map<String, dynamic>)..id = userDoc.id;
        
        await _userDataBox.put(phoneSerialNumber, userData);
        
        return userData;
      } else {
        print("No user found with this phone serial number");
        return null;
      }
    } catch (error) {
      print("Error fetching user data from Firebase: $error");
      rethrow;
    }
  }

  Future<void> updateLocalCache(String phoneSerialNumber, Map<String, dynamic> userData) async {
    try {
      UserData newData = UserData.fromMap(userData);
      await _userDataBox.put(phoneSerialNumber, newData);
    } catch (error) {
      print("Error updating local cache: $error");
      rethrow;
    }
  }

  Future<bool> checkUserExistsInFirebase(String phoneSerialNumber) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection("users")
          .where("phoneSerialNumber", isEqualTo: phoneSerialNumber)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (error) {
      print("Error checking user existence in Firebase: $error");
      rethrow;
    }
  }

  Future<void> insertUserToFirebase(UserData userData) async {
    try {
      await _firestore.collection("users").add(userData.toMap());
    } catch (error) {
      print("Error inserting user to Firebase: $error");
      rethrow;
    }
  }
}