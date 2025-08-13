import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:laptop_harbour/services/user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

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
      }
      return result.user;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
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
}
