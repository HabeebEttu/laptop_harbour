import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:laptop_harbour/models/laptop.dart';
import 'package:laptop_harbour/models/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> createUser(
    String uid,
    String email,
    String firstname,
    String lastname,
    String phoneNumber,
  ) async {
    try {
      final newProfile = Profile(
        uid: uid,
        email: email,
        firstName: firstname,
        lastName: lastname,
        phoneNumber: phoneNumber,
        profilePic:
            'https://spjnqtaztbkogiiismza.supabase.co/storage/v1/object/sign/profile-pics/default%20image/default.jpeg?token=eyJraWQiOiJzdG9yYWdlLXVybC1zaWduaW5nLWtleV8yZmFkNjg5ZS1iM2E1LTQ2N2MtYWUyNS05ODZmZDk1ZDBjMDciLCJhbGciOiJIUzI1NiJ9.eyJ1cmwiOiJwcm9maWxlLXBpY3MvZGVmYXVsdCBpbWFnZS9kZWZhdWx0LmpwZWciLCJpYXQiOjE3NTQ2NTYxNzIsImV4cCI6MjA3MDAxNjE3Mn0.6f06qEQ4MuGWyFarkItG5FdFTWbqNc1W5QdCz0bhgEg',
        address: '',
        city: '',
        postalCode: '',
        country: '',
      );

      await _firestore.collection('users').doc(uid).set({
        'profile': newProfile.toMap(),
      });
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

  Future<String> uploadProfilePicture(String uid, Uint8List imageBytes) async {
    try {
      final fileName = '$uid.jpg';

      await _supabase.storage
          .from('profile-pics')
          .uploadBinary(
            fileName,
            imageBytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      final signedUrl = await _supabase.storage
          .from('profile-pics')
          .createSignedUrl(
            fileName,
            60 * 60 * 24 * 365 * 10,
          ); // 10 years validity
      return signedUrl;
    } catch (e) {
      debugPrint('Error uploading profile picture to Supabase: $e');
      rethrow;
    }
  }

  Future<void> updateProfilePictureUrl(String uid, String imageUrl) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'profile.profilePic': imageUrl,
      });
    } catch (e) {
      debugPrint('Error updating profile picture URL: $e');
      rethrow;
    }
  }

  Future<void> addToWishList(String uid, Laptop laptop) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('wishlist')
          .doc(laptop.id)
          .set(laptop.toMap());
    } catch (e) {
      debugPrint('Error adding to wishlist: $e');
      rethrow;
    }
  }

  Future<void> removeFromWishList(String uid, String laptopId) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('wishlist')
          .doc(laptopId)
          .delete();
    } catch (e) {
      debugPrint('Error removing from wishlist: $e');
      rethrow;
    }
  }

  Future<void> clearWishList(String uid) async {
    try {
     
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('wishlist')
          .get();

      // Loop through each document and delete it.
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print(e);
      // You might want to handle the error more gracefully here, like throwing it or showing a user-friendly message.
    }
  }

  Stream<List<Laptop>> getWishlist(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Laptop.fromMap(doc.data()))
              .toList();
        });
  }

  Stream<List<Profile>> getAllUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Profile.fromMap(data['profile']);
      }).toList();
    });
  }

  Future<void> updateUserRole(String uid, String role) async {
    await _firestore.collection('users').doc(uid).update({
      'profile.role': role,
    });
  }

  Future<void> blockUser(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'profile.isBlocked': true,
    });
  }

  Future<void> unblockUser(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'profile.isBlocked': false,
    });
  }

  Future<void> saveFCMToken(String uid, String token) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'profile.fcmToken': token,
      });
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
      rethrow;
    }
  }
}
