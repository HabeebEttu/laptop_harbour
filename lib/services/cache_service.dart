import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:laptop_harbour/models/profile.dart';

class CacheService {
  static const String _userKey = 'user_profile';
  static const String _isAuthenticatedKey = 'isAuthenticated';

  Future<void> saveUser(Profile user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toJson());
    await prefs.setString(_userKey, userJson);
    await prefs.setBool(_isAuthenticatedKey, true);
  }

  Future<Profile?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return Profile.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isAuthenticatedKey) ?? false;
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.setBool(_isAuthenticatedKey, false);
  }
}
