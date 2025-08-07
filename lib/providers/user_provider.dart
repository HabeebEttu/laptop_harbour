import 'package:flutter/material.dart';

import 'package:laptop_harbour/models/profile.dart';
import 'package:laptop_harbour/services/user_service.dart';
import 'package:laptop_harbour/providers/auth_provider.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();
  Profile? _userProfile;
  AuthProvider _authProvider;

  UserProvider(this._authProvider) {
    _authProvider.addListener(_onAuthStateChanged);
    _onAuthStateChanged(); // Initial check
  }

  Profile? get userProfile => _userProfile;

  void _onAuthStateChanged() async {
    if (_authProvider.user != null) {
      await fetchUserProfile(_authProvider.user!.uid);
    } else {
      _userProfile = null;
      notifyListeners();
    }
  }

  void updateAuth(AuthProvider auth) {
    if (_authProvider != auth) {
      _authProvider.removeListener(_onAuthStateChanged);
      _authProvider = auth;
      _authProvider.addListener(_onAuthStateChanged);
      _onAuthStateChanged();
    }
  }

  Future<void> fetchUserProfile(String uid) async {
    _userProfile = await _userService.getUserProfile(uid);
    notifyListeners();
  }

  Future<void> updateUserProfile(Profile profile) async {
    try {
      await _userService.updateUserProfile(profile);
      _userProfile = profile;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating user profile in UserProvider: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthStateChanged);
    super.dispose();
  }
}
