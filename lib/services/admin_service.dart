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
      // Correctly check for the role within the 'profile' map
      return userData?['profile']?['role'] == 'admin';
    } catch (e) {
      debugPrint('Error checking admin status: $e');
      return false;
    }
  }

  // Get a single user by UID
  Future<Profile?> getUser(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      
      if (!userDoc.exists) {
        debugPrint('User with UID $uid not found');
        return null;
      }

      final userData = userDoc.data();
      if (userData == null || userData['profile'] == null) {
        debugPrint('User profile data not found for UID $uid');
        return null;
      }

      return Profile.fromMap(userData['profile']);
    } catch (e) {
      debugPrint('Error getting user: $e');
      rethrow;
    }
  }

  // Get a single user with additional metadata (isBlocked, etc.)
  Future<Map<String, dynamic>?> getUserWithMetadata(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      
      if (!userDoc.exists) {
        debugPrint('User with UID $uid not found');
        return null;
      }

      final userData = userDoc.data();
      if (userData == null) {
        debugPrint('User data not found for UID $uid');
        return null;
      }

      return {
        'uid': uid,
        'profile': userData['profile'] != null 
            ? Profile.fromMap(userData['profile'])
            : null,
        'isBlocked': userData['isBlocked'] ?? false,
        'createdAt': userData['createdAt'],
        'lastLoginAt': userData['lastLoginAt'],
        // Add any other metadata fields you need
      };
    } catch (e) {
      debugPrint('Error getting user with metadata: $e');
      rethrow;
    }
  }

  // Get user by email (useful for admin searches)
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('profile.email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        debugPrint('User with email $email not found');
        return null;
      }

      final doc = querySnapshot.docs.first;
      final userData = doc.data();

      return {
        'uid': doc.id,
        'profile': userData['profile'] != null 
            ? Profile.fromMap(userData['profile'])
            : null,
        'isBlocked': userData['isBlocked'] ?? false,
        'createdAt': userData['createdAt'],
        'lastLoginAt': userData['lastLoginAt'],
      };
    } catch (e) {
      debugPrint('Error getting user by email: $e');
      rethrow;
    }
  }

  // Check if user exists
  Future<bool> userExists(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      return userDoc.exists;
    } catch (e) {
      debugPrint('Error checking if user exists: $e');
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

  // Get all users with metadata (for admin management)
  Stream<List<Map<String, dynamic>>> getAllUsersWithMetadata() {
    return _firestore
        .collection('users')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data();
              return {
                'uid': doc.id,
                'profile': data['profile'] != null 
                    ? Profile.fromMap(data['profile'])
                    : null,
                'isBlocked': data['isBlocked'] ?? false,
                'createdAt': data['createdAt'],
                'lastLoginAt': data['lastLoginAt'],
              };
            })
            .toList());
  }

  // Update user role
  Future<void> updateUserRole(String uid, String role) async {
    try {
      // Correctly update the role within the 'profile' map
      await _firestore.collection('users').doc(uid).update({
        'profile.role': role,
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