import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:laptop_harbour/models/cart.dart';
import 'package:laptop_harbour/models/profile.dart';
import 'package:laptop_harbour/models/user.dart';

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

      final newCart = Cart(
        userId: uid,
        items: [],
      );

      final newUser = User(
        profile: newProfile,
        cart: newCart,
        orders: [],
      );

      await _firestore.collection('users').doc(uid).set(newUser.toMap());
    } catch (e) {
      debugPrint('Error creating user document: $e');
      rethrow;
    }
  }

  Future<Profile?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
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
