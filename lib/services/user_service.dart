import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:laptop_harbour/models/profile.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser(String uid, String email) async {
    try {
      final newProfile = Profile(
        uid: uid,
        email: email,
        firstName: '',
        lastName: '',
        phoneNumber: '',
        address: '',
        city: '',
        postalCode: '',
        country: '',
      );

      await _firestore.collection('users').doc(uid).set({'profile': newProfile.toMap()});
    } catch (e) {
      debugPrint('Error creating user document: $e');
      rethrow;
    }
  }

  Future<Profile?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null && doc.data()!['profile'] != null) {
        return Profile.fromMap(doc.data()!['profile']);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }

  Future<void> updateUserProfile(Profile profile) async {
    try {
      await _firestore.collection('users').doc(profile.uid).update({
        'profile': profile.toMap(),
      });
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }
}
