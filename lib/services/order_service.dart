import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/foundation.dart';
import 'package:laptop_harbour/models/order.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Order>> getUserOrders(String userId) async {
    try {
      final snapshot = await _firestore.collection('users').doc(userId).collection('orders').orderBy('orderDate', descending: true).get();
      return snapshot.docs.map((doc) => Order.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('Error fetching user orders: $e');
      return [];
    }
  }

  Future<void> placeOrder(String userId, Order order) async {
    try {
      await _firestore.collection('users').doc(userId).collection('orders').doc(order.id).set(order.toMap());
    } catch (e) {
      debugPrint('Error placing order: $e');
      rethrow;
    }
  }
}
