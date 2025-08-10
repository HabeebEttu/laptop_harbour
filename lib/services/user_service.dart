import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:laptop_harbour/models/laptop.dart';
import 'package:laptop_harbour/models/profile.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser(String uid, String email,String firstname,String lastname,String phoneNumber) async {
    try {
      final newProfile = Profile(
        uid: uid,
        email: email,
        firstName: firstname,
        lastName: lastname,
        phoneNumber: phoneNumber,
        profilePic: 'https://spjnqtaztbkogiiismza.supabase.co/storage/v1/object/sign/profile-pics/default%20image/default.jpeg?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV8yZmFkNjg5ZS1iM2E1LTQ2N2MtYWUyNS05ODZmZDk1ZDBjMDciLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJwcm9maWxlLXBpY3MvZGVmYXVsdCBpbWFnZS9kZWZhdWx0LmpwZWciLCJpYXQiOjE3NTQ2NTYxNzIsImV4cCI6MjA3MDAxNjE3Mn0.6f06qEQ4MuGWyFarkItG5FdFTWbqNc1W5QdCz0bhgEg',
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
  Future<void> addToWishList(String uid, Laptop laptop) async {
    try {
      await _firestore.collection('users').doc(uid).collection('wishlist').doc(laptop.id).set(laptop.toMap());
    } catch (e) {
      debugPrint('Error adding to wishlist: $e');
      rethrow;
    }
  }

  Future<void> removeFromWishList(String uid, String laptopId) async {
    try {
      await _firestore.collection('users').doc(uid).collection('wishlist').doc(laptopId).delete();
    } catch (e) {
      debugPrint('Error removing from wishlist: $e');
      rethrow;
    }
  }

  Stream<List<Laptop>> getWishlist(String uid) {
    return _firestore.collection('users').doc(uid).collection('wishlist').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Laptop.fromMap(doc.data())).toList();
    });
  }
}
