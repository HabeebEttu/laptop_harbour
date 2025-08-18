import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:laptop_harbour/models/profile.dart';
import 'package:laptop_harbour/services/auth_service.dart';
import 'package:laptop_harbour/services/user_service.dart';
import 'package:laptop_harbour/services/cache_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final CacheService _cacheService = CacheService();
  User? _user;
  Profile? _userProfile;

  User? get user => _user;
  Profile? get userProfile => _userProfile;

  AuthProvider() {
    _loadUserFromCache();
    _authService.user.listen((user) {
      _user = user;
      if (user != null) {
        _userService.getUserProfile(user.uid).then((profile) {
          _userProfile = profile;
          if (profile != null) {
            _cacheService.saveUser(profile);
          }
          notifyListeners();
        });
      } else {
        _userProfile = null;
        _cacheService.clearCache();
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserFromCache() async {
    bool isAuthenticated = await _cacheService.isAuthenticated();
    if (isAuthenticated) {
      _userProfile = await _cacheService.getUser();
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    _user = await _authService.signInWithEmailAndPassword(email, password);
    if (_user != null) {
      _userProfile = await _userService.getUserProfile(_user!.uid);
    }
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
        email,
        password,
        firstname,
        lastname,
        phoneNumber,
      );
      if (_user != null) {
        _userProfile = await _userService.getUserProfile(_user!.uid);
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
    _user = null;
    _userProfile = null;
    notifyListeners();
  }

  Future<void> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    await _authService.changePassword(currentPassword, newPassword);
    notifyListeners();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }
}
