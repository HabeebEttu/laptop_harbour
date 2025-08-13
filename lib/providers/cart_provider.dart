import 'package:flutter/material.dart';
import 'package:laptop_harbour/models/cart.dart';
import 'package:laptop_harbour/models/cart_item.dart';
import 'package:laptop_harbour/services/cart_service.dart';
import 'package:laptop_harbour/providers/auth_provider.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();
  Cart? _cart;
  AuthProvider _authProvider;

  Cart? get cart => _cart;

  CartProvider(this._authProvider) {
    _authProvider.addListener(_onAuthStateChanged);
    _onAuthStateChanged(); 
  }

  void _onAuthStateChanged() async {
    if (_authProvider.user != null) {
      await fetchCart(_authProvider.user!.uid);
    } else {
      // _cart = Cart(
      //   userId: 'dummy_user',
      //   items: [
      //     CartItem(
      //       item: Laptop(
      //         id: '1',
      //         title: 'MacBook Pro 16-inch M3 Pro',
      //         brand: 'Apple',
      //         price: 2399,
      //         image: 'assets/images/laptop1.jpg',
      //         rating: 4.8,
      //         reviews: [],
      //         tags: ['Apple', 'Pro', 'High Performance'],
      //         specs: Specs(processor: 'Apple M3 Pro', ram: '18GB', storage: '512GB SSD', display: '16.2-inch Liquid Retina XDR'),
      //         categoryId: '1',
      //       ),
      //       quantity: 1,
      //     ),
      //     CartItem(
      //       item: Laptop(
      //         id: '2',
      //         title: 'HP Omen 16 Gaming Laptop',
      //         brand: 'HP',
      //         price: 1799,
      //         image: 'assets/images/laptop2.jpg',
      //         rating: 4.6,
      //         reviews: [],
      //         tags: ['HP', 'Gaming', 'RTX 4060'],
      //         specs: Specs(processor: 'Intel Core i7', ram: '16GB', storage: '1TB SSD', display: '16-inch'),
      //         categoryId: '1',
      //       ),
      //       quantity: 2,
      //     ),
      //   ],
      // );
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

  Future<void> fetchCart(String userId) async {
    _cart = await _cartService.getUserCart(userId);
    notifyListeners();
  }

  Future<void> addOrUpdateItem(CartItem item) async {
    if (_authProvider.user == null) {
       if (_cart != null) {
        final index = _cart!.items.indexWhere((i) => i.item.id == item.item.id);
        if (index != -1) {
          _cart!.items[index] = item;
        } else {
          _cart!.items.add(item);
        }
        notifyListeners();
      }
      return;
    }
    try {
      await _cartService.addOrUpdateCartItem(_authProvider.user!.uid, item);
      await fetchCart(_authProvider.user!.uid); // Re-fetch cart to update state
    } catch (e) {
      debugPrint('Error adding/updating cart item in CartProvider: $e');
      rethrow;
    }
  }

  Future<void> removeItem(String laptopId) async {
    if (_authProvider.user == null) {
      if (_cart != null) {
        _cart!.items.removeWhere((item) => item.item.id == laptopId);
        notifyListeners();
      }
      return;
    }
    try {
      await _cartService.removeCartItem(_authProvider.user!.uid, laptopId);
      await fetchCart(_authProvider.user!.uid); // Re-fetch cart to update state
    } catch (e) {
      debugPrint('Error removing cart item in CartProvider: $e');
      rethrow;
    }
  }

  Future<void> clearCart() async {
    if (_authProvider.user == null) {
      if (_cart != null) {
        _cart!.items.clear();
        notifyListeners();
      }
      return;
    }
    try {
      await _cartService.clearCart(_authProvider.user!.uid);
      _cart = Cart(userId: _authProvider.user!.uid, items: []); // Clear locally
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing cart in CartProvider: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthStateChanged);
    super.dispose();
  }
}
