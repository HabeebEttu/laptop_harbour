import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:laptop_harbour/models/profile.dart';
import 'package:laptop_harbour/services/auth_service.dart';
import 'package:laptop_harbour/services/user_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  User? _user;
  Profile? _userProfile;

  User? get user => _user;
  Profile? get userProfile => _userProfile;

  AuthProvider() {
    _authService.user.listen((user) async {
      _user = user;
      if (_user != null) {
        await fetchUserProfile();
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
  }

  Future<void> fetchUserProfile() async {
    if (_user != null) {
      _userProfile = await _userService.getUserProfile(_user!.uid);
      notifyListeners();
    }
  }

  Future<void> updateUserProfile(Profile profile) async {
    if (_user != null) {
      await _userService.updateUserProfile(profile);
      _userProfile = profile;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    _user = await _authService.signInWithEmailAndPassword(email, password);
    if (_user != null) {
      await fetchUserProfile();
    }
    notifyListeners();
  }

  Future<void> signUp(String email, String password) async {
    _user = await _authService.registerWithEmailAndPassword(email, password);
    if (_user != null) {
      await fetchUserProfile();
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _userProfile = null;
    notifyListeners();
  }
}
