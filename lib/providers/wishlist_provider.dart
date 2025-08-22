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
    debugPrint('WishlistProvider: setUser called with uid: $uid');
    if (_uid == uid) {
      debugPrint('WishlistProvider: uid is the same, returning.');
      return;
    }
    _uid = uid;
    _wishlistSubscription?.cancel();

    if (_uid != null) {
      _loading = true;
      notifyListeners();
      debugPrint('WishlistProvider: Fetching wishlist for uid: $_uid');
      _wishlistSubscription = _userService.getWishlist(_uid!).listen((
        wishlist,
      ) {
        debugPrint('WishlistProvider: Received ${wishlist.length} items for uid: $_uid');
        _wishlist = wishlist;
        _loading = false;
        notifyListeners();
      }, onError: (error) {
        debugPrint('WishlistProvider: Error fetching wishlist: $error');
        _loading = false;
        notifyListeners();
      });
    } else {
      debugPrint('WishlistProvider: uid is null, clearing wishlist.');
      _wishlist = [];
      notifyListeners();
    }
  }

  Future<void> clearWishlist() async {
    if (_uid != null) {
      await _userService.clearWishList(_uid!);
    }
      _wishlist.clear();
      notifyListeners();
    
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

  Future<void> refreshWishlist() async {
    if (_uid != null) {
      _loading = true;
      notifyListeners();
      // Re-trigger the stream to fetch fresh data
      // This assumes getWishlist() in UserService will emit new data
      // or you might need a separate method in UserService to force a refresh
      _wishlistSubscription?.cancel(); // Cancel existing to ensure new fetch
      _wishlistSubscription = _userService.getWishlist(_uid!).listen((wishlist) {
        _wishlist = wishlist;
        _loading = false;
        notifyListeners();
      }, onError: (error) {
        debugPrint('WishlistProvider: Error refreshing wishlist: $error');
        _loading = false;
        notifyListeners();
      });
    } else {
      _wishlist = [];
      _loading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _wishlistSubscription?.cancel();
    super.dispose();
  }
}
