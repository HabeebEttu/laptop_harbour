import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:laptop_harbour/services/auth_service.dart';
import 'package:laptop_harbour/services/user_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService(); 
  User? _user;

  User? get user => _user;

  AuthProvider() {
    _authService.user.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    _user = await _authService.signInWithEmailAndPassword(email, password);
    notifyListeners();
  }

  Future<void> signUp(
    String email,
    String password,
    String firstname,
    String lastname,
    String phoneNumber,
  ) async {
    try {
      _user = await _authService.registerWithEmailAndPassword(
          email, password, firstname, lastname, phoneNumber);
      if (_user != null) {
        await _userService.createUser(
            _user!.uid, email, firstname, lastname, phoneNumber);
      } else {
        throw Exception('Sign up failed');
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    notifyListeners();
  }
}
