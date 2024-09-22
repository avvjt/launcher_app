// lib/firebase/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_data.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserData?> fetchUserData(String serialNumber) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('phoneSerialNumber', isEqualTo: serialNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return UserData.fromMap(querySnapshot.docs.first.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
    return null;
  }

  Future<void> createUser(UserData userData) async {
    try {
      await _firestore.collection('users').doc(userData.id).set(userData.toMap());
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  Future<void> updateUserData(UserData userData) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userData.id).get();
      
      // If document exists, check the version before updating
      if (doc.exists) {
        UserData existingData = UserData.fromMap(doc.data() as Map<String, dynamic>);
        
        // Only update if the incoming version is greater than the existing version
        if (existingData.version < userData.version) {
          await _firestore.collection('users').doc(userData.id).update(userData.toMap());
        }
      } 
      // If document doesn't exist, create it
      else {
        await _firestore.collection('users').doc(userData.id).set(userData.toMap());
      }
    } catch (e) {
      print('Error updating user data: $e');
      rethrow;
    }
  }
}
