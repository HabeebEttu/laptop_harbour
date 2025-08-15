import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:laptop_harbour/models/profile.dart';
import 'package:laptop_harbour/models/order.dart' as model_order;




class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if a user is an admin
  Future<bool> isAdmin(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      final userData = userDoc.data();
      return userData?['role'] == 'admin';
    } catch (e) {
      debugPrint('Error checking admin status: $e');
      return false;
    }
  }

  // Get all users
  Stream<List<Profile>> getAllUsers() {
    return _firestore
        .collection('users')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Profile.fromMap(doc.data()['profile']))
            .toList());
  }

  // Update user role
  Future<void> updateUserRole(String uid, String role) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'role': role,
      });
    } catch (e) {
      debugPrint('Error updating user role: $e');
      rethrow;
    }
  }

  // Block/Unblock user
  Future<void> updateUserStatus(String uid, bool isBlocked) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'isBlocked': isBlocked,
      });
    } catch (e) {
      debugPrint('Error updating user status: $e');
      rethrow;
    }
  }

  // Get all orders for admin
  Stream<List<model_order.Order>> getAllOrders() {
    return _firestore
        .collection('orders')
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => model_order.Order.fromFirestore(doc)).toList());
  }

  // Update order status by admin
  Future<void> updateOrderStatus(
    String orderId,
    String userId,
    String status, {
    String? trackingNumber,
    String? courierService,
    DateTime? estimatedDeliveryDate,
  }) async {
    try {
      final updateData = {
        'status': status,
        if (trackingNumber != null) 'trackingNumber': trackingNumber,
        if (courierService != null) 'courierService': courierService,
        if (estimatedDeliveryDate != null)
          'estimatedDeliveryDate': Timestamp.fromDate(estimatedDeliveryDate),
      };

      // Update in global orders collection
      await _firestore.collection('orders').doc(orderId).update(updateData);

      // Update in user's orders collection
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .doc(orderId)
          .update(updateData);
    } catch (e) {
      debugPrint('Error updating order status: $e');
      rethrow;
    }
  }

  // Delete order (admin only)
  Future<void> deleteOrder(String orderId, String userId) async {
    try {
      // Delete from global orders collection
      await _firestore.collection('orders').doc(orderId).delete();

      // Delete from user's orders collection
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .doc(orderId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting order: $e');
      rethrow;
    }
  }

  // Get admin dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final usersCount = await _firestore.collection('users').count().get();
      final ordersCount = await _firestore.collection('orders').count().get();
      
      final ordersSnapshot = await _firestore.collection('orders').get();
      double totalRevenue = 0;
      for (var doc in ordersSnapshot.docs) {
        totalRevenue += (doc.data()['totalPrice'] as num).toDouble();
      }

      final pendingOrders = await _firestore
          .collection('orders')
          .where('status', isEqualTo: 'Pending')
          .count()
          .get();

      return {
        'totalUsers': usersCount.count,
        'totalOrders': ordersCount.count,
        'totalRevenue': totalRevenue,
        'pendingOrders': pendingOrders.count,
      };
    } catch (e) {
      debugPrint('Error getting dashboard stats: $e');
      rethrow;
    }
  }
}
