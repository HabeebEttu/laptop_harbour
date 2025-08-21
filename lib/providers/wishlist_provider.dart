import 'dart:async';

import 'package:flutter/material.dart';
import 'package:laptop_harbour/models/laptop.dart';
import 'package:laptop_harbour/services/user_service.dart';

class WishlistProvider with ChangeNotifier {
  final UserService _userService = UserService();
  List<Laptop> _wishlist = [];
  String? _uid;
  StreamSubscription? _wishlistSubscription;
  bool _loading = false;
  List<Laptop> get wishlist => _wishlist;
  bool get loading => _loading;

  void setUser(String? uid) {
    if (_uid == uid) return;
    _uid = uid;
    _wishlistSubscription?.cancel();

    if (_uid != null) {
      _loading = true;
      notifyListeners();
      _wishlistSubscription = _userService.getWishlist(_uid!).listen((
        wishlist,
      ) {
        _wishlist = wishlist;
        _loading = false;
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
    } else {
      _wishlist.add(laptop);
      notifyListeners();
    }
  }

  Future<void> removeFromWishlist(Laptop laptop) async {
    if (_uid != null) {
      await _userService.removeFromWishList(_uid!, laptop.id!);
    } else {
      _wishlist.removeWhere((item) => item.id == laptop.id);
      notifyListeners();
    }
  }

  bool isFavorite(Laptop laptop) {
    return _wishlist.any((item) => item.id == laptop.id);
  }

  @override
  void dispose() {
    _wishlistSubscription?.cancel();
    super.dispose();
  }
}
