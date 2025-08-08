import 'package:flutter/material.dart';
import 'package:laptop_harbour/models/laptop.dart';
import 'package:laptop_harbour/services/user_service.dart';

class WishlistProvider with ChangeNotifier {
  final UserService _userService = UserService();
  List<Laptop> _wishlist = [];
  String? _uid;

  List<Laptop> get wishlist => _wishlist;

  void setUser(String? uid) {
    _uid = uid;
    if (_uid != null) {
      _userService.getWishlist(_uid!).listen((wishlist) {
        _wishlist = wishlist;
        notifyListeners();
      });
    } else {
      _wishlist = [];
      notifyListeners();
    }
  }

  Future<void> addToWishlist(Laptop laptop) async {
    if (_uid != null) {
      await _userService.addToWishList(_uid!, laptop);
    }
  }

  Future<void> removeFromWishlist(Laptop laptop) async {
    if (_uid != null) {
      await _userService.removeFromWishList(_uid!, laptop.id!);
    }
  }

  bool isFavorite(Laptop laptop) {
    return _wishlist.any((item) => item.id == laptop.id);
  }
}