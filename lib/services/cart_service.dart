import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:laptop_harbour/models/cart.dart';
import 'package:laptop_harbour/models/cart_item.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Cart?> getUserCart(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).collection('cart').doc('current').get();
      
      if (!doc.exists || doc.data() == null) {
        debugPrint('No cart found for user: $userId');
        return Cart(userId: userId, items: []);
      }

      final data = doc.data()!;
      // Ensure the data has the expected structure
      if (!data.containsKey('items')) {
        debugPrint('Cart data missing items array for user: $userId');
        return Cart(userId: userId, items: []);
      }

      try {
        return Cart.fromMap({'userId': userId, 'items': data['items'] ?? []});
      } catch (parseError) {
        debugPrint('Error parsing cart data: $parseError');
        // If there's an error parsing the cart, return an empty one
        return Cart(userId: userId, items: []);
      }
    } catch (e) {
      debugPrint('Error fetching user cart: $e');
      // Return an empty cart instead of null
      return Cart(userId: userId, items: []);
    }
  }

  Future<void> updateCart(String userId, Cart cart) async {
    try {
      await _firestore.collection('users').doc(userId).collection('cart').doc('current').set(cart.toMap());
    } catch (e) {
      debugPrint('Error updating cart: $e');
      rethrow;
    }
  }

  Future<void> addOrUpdateCartItem(String userId, CartItem item) async {
    try {
      final cartRef = _firestore.collection('users').doc(userId).collection('cart').doc('current');
      final doc = await cartRef.get();

      Cart currentCart;
      if (doc.exists) {
        currentCart = Cart.fromMap(doc.data()!);
      } else {
        currentCart = Cart(userId: userId, items: []);
      }

      final existingItemIndex = currentCart.items.indexWhere((i) => i.item.id == item.item.id);

      if (existingItemIndex != -1) {
        // Update existing item
        currentCart.items[existingItemIndex] = item;
      } else {
        // Add new item
        currentCart.items.add(item);
      }

      await cartRef.set(currentCart.toMap());
    } catch (e) {
      debugPrint('Error adding/updating cart item: $e');
      rethrow;
    }
  }

  Future<void> removeCartItem(String userId, String laptopId) async {
    try {
      final cartRef = _firestore.collection('users').doc(userId).collection('cart').doc('current');
      final doc = await cartRef.get();

      if (doc.exists) {
        Cart currentCart = Cart.fromMap(doc.data()!);
        currentCart.items.removeWhere((item) => item.item.id == laptopId);
        await cartRef.set(currentCart.toMap());
      }
    } catch (e) {
      debugPrint('Error removing cart item: $e');
      rethrow;
    }
  }

  Future<void> clearCart(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).collection('cart').doc('current').delete();
    } catch (e) {
      debugPrint('Error clearing cart: $e');
      rethrow;
    }
  }
}
