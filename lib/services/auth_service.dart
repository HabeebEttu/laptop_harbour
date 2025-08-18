import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:laptop_harbour/models/profile.dart';
import 'package:laptop_harbour/services/user_service.dart';
import 'package:laptop_harbour/services/cache_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();
  final CacheService _cacheService = CacheService();

  Stream<User?> get user => _auth.authStateChanges();

  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (result.user != null) {
        Profile? userProfile =
            await _userService.getUserProfile(result.user!.uid);
        if (userProfile != null) {
          await _cacheService.saveUser(userProfile);
        }
      }
      return result.user;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
    String firstname,
    String lastname,
    String phoneNumber,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (result.user != null) {
        await _userService.createUser(
          result.user!.uid,
          email,
          firstname,
          lastname,
          phoneNumber,
        );
        Profile? userProfile =
            await _userService.getUserProfile(result.user!.uid);
        if (userProfile != null) {
          await _cacheService.saveUser(userProfile);
        }
      }
      return result.user;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _cacheService.clearCache();
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      if (_auth.currentUser == null) {
        throw Exception('User is not currently signed in');
      }
      final cred = EmailAuthProvider.credential(
        email: _auth.currentUser!.email!,
        password: currentPassword,
      );
      await _auth.currentUser!.reauthenticateWithCredential(cred);
      await _auth.currentUser!.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        debugPrint('Current password is incorrect');
      } else {
        debugPrint('Error changing password ${e.code}');
      }
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      debugPrint("Attempting to send password reset email to: $email");
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint("Password reset email sent successfully.");
    } on FirebaseAuthException catch (e) {
      debugPrint(
          "Error sending password reset email: ${e.code} - ${e.message}");
      rethrow;
    } catch (e) {
      debugPrint("An unexpected error occurred: $e");
      rethrow;
    }
  }
}
