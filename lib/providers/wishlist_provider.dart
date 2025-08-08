import 'package:flutter/material.dart';
import 'package:laptop_harbour/models/laptop.dart';

class WishlistProvider with ChangeNotifier {
  final List<Laptop> _wishlist = [];

  List<Laptop> get wishlist => _wishlist;

  void addToWishlist(Laptop laptop) {
    _wishlist.add(laptop);
    notifyListeners();
  }

  void removeFromWishlist(Laptop laptop) {
    _wishlist.remove(laptop);
    notifyListeners();
  }
}
