import 'dart:async';

import 'package:flutter/material.dart';
import 'package:laptop_harbour/models/laptop.dart';
import 'package:laptop_harbour/models/specs.dart';
import 'package:laptop_harbour/services/user_service.dart';

class WishlistProvider with ChangeNotifier {
  final UserService _userService = UserService();
  List<Laptop> _wishlist = [];
  String? _uid;
  StreamSubscription? _wishlistSubscription;

  List<Laptop> get wishlist => _wishlist;

  void setUser(String? uid) {
    if (_uid == uid) return;
    _uid = uid;
    _wishlistSubscription?.cancel();

    if (_uid != null) {
      _wishlistSubscription = _userService.getWishlist(_uid!).listen((wishlist) {
        _wishlist = wishlist;
        notifyListeners();
      });
    } else {
      _wishlist = [
        Laptop(
          id: '1',
          title: 'MacBook Pro 16-inch M3 Pro',
          brand: 'Apple',
          price: 2399,
          image: 'assets/images/laptop1.jpg',
          rating: 4.8,
          reviews: [],
          tags: ['Apple', 'Pro', 'High Performance'],
          specs: Specs(
              processor: 'Apple M3 Pro',
              ram: '18GB',
              storage: '512GB SSD',
              display: '16.2-inch Liquid Retina XDR'),
          categoryId: '1',
        ),
        Laptop(
          id: '2',
          title: 'HP Omen 16 Gaming Laptop',
          brand: 'HP',
          price: 1799,
          image: 'assets/images/laptop2.jpg',
          rating: 4.6,
          reviews: [],
          tags: ['HP', 'Gaming', 'RTX 4060'],
          specs: Specs(
              processor: 'Intel Core i7',
              ram: '16GB',
              storage: '1TB SSD',
              display: '16-inch'),
          categoryId: '1',
        ),
      ];
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
