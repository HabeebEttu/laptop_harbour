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
    _onAuthStateChanged(); // Initial check
  }

  void _onAuthStateChanged() async {
    if (_authProvider.user != null) {
      await fetchCart(_authProvider.user!.uid);
    } else {
      _cart = null;
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
    if (_authProvider.user == null) return;
    try {
      await _cartService.addOrUpdateCartItem(_authProvider.user!.uid, item);
      await fetchCart(_authProvider.user!.uid); // Re-fetch cart to update state
    } catch (e) {
      debugPrint('Error adding/updating cart item in CartProvider: $e');
      rethrow;
    }
  }

  Future<void> removeItem(String laptopId) async {
    if (_authProvider.user == null) return;
    try {
      await _cartService.removeCartItem(_authProvider.user!.uid, laptopId);
      await fetchCart(_authProvider.user!.uid); // Re-fetch cart to update state
    } catch (e) {
      debugPrint('Error removing cart item in CartProvider: $e');
      rethrow;
    }
  }

  Future<void> clearCart() async {
    if (_authProvider.user == null) return;
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
