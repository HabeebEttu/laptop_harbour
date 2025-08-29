import 'package:flutter/material.dart';
import 'package:laptop_harbour/models/cart.dart';
import 'package:laptop_harbour/models/cart_item.dart';
import 'package:laptop_harbour/services/cart_service.dart';
import 'package:laptop_harbour/providers/auth_provider.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();
  Cart? _cart;
  AuthProvider _authProvider;
  bool _isLoading = false; // Adding a loading state

  Cart? get cart => _cart;
  bool get isLoading => _isLoading; // Getter for the loading state

  CartProvider(this._authProvider) {
    _authProvider.addListener(_onAuthStateChanged);
    _onAuthStateChanged();
  }

  // New method to handle auth state changes and cart fetching
  void _onAuthStateChanged() async {
    final userId = _authProvider.user?.uid;
    // Calling the new refresh method to handle fetching and loading state
    await refreshCart(userId);
  }

  //  refreshCart method
  Future<void> refreshCart(String? userId) async {
  
    if (userId == null) {
      _cart = Cart(userId: 'guest', items: []);
      notifyListeners();
      return;
    }

    try {
      // Setting loading to true and notify listeners to show a loading indicator
      _isLoading = true;
      notifyListeners();

      final fetchedCart = await _cartService.getUserCart(userId);
      _cart = fetchedCart ?? Cart(userId: userId, items: []);
    } catch (e) {
      debugPrint('Error refreshing cart: $e');
      _cart = Cart(userId: userId, items: []); // Ensure a valid cart on error
    } finally {
      // Set loading to false and notify listeners regardless of the outcome
      _isLoading = false;
      notifyListeners();
    }
  }

  // The rest of your methods...
  void updateAuth(AuthProvider auth) {
    if (_authProvider != auth) {
      _authProvider.removeListener(_onAuthStateChanged);
      // Use the new _authProvider variable directly
      // instead of a temporary variable `authProvider`
      _authProvider = auth;
      _authProvider.addListener(_onAuthStateChanged);
      _onAuthStateChanged();
    }
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
      await refreshCart(_authProvider.user!.uid); // Use the new method
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
      await refreshCart(_authProvider.user!.uid); // Use the new method
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
      await refreshCart(_authProvider.user!.uid); // Use the new method
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
