import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/foundation.dart';
import 'package:laptop_harbour/models/order.dart' as model_order;
import 'package:laptop_harbour/services/email_service.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EmailService _emailService = EmailService();

  Future<void> placeOrder(model_order.Order order) async {
    try {
      final WriteBatch batch = _firestore.batch();

      // Create order document data
      final orderData = order.toMap();

      // Place order in user's collection
      final userOrderRef = _firestore
          .collection('users')
          .doc(order.userId)
          .collection('orders')
          .doc(order.orderId);
      batch.set(userOrderRef, orderData);

      // Place order in global orders collection for admin
      final globalOrderRef = _firestore.collection('orders').doc(order.orderId);
      batch.set(globalOrderRef, {
        ...orderData,
        'customerName':
            '${order.shippingAddress['firstName']} ${order.shippingAddress['lastName']}',
        'customerEmail': order.shippingAddress['email'],
        'customerPhone': order.shippingAddress['phone'],
      });

      // Clear the user's cart
      final cartRef = _firestore
          .collection('users')
          .doc(order.userId)
          .collection('cart')
          .doc('current');
      batch.delete(cartRef);

      await batch.commit();

      await _emailService.sendEmail(
        order.shippingAddress['email']!,
        'Order Confirmation #${order.orderId}',
        '<h1>Thank you for your order!</h1><p>Your order has been placed successfully.</p>',
      );
    } catch (e) {
      debugPrint('Error placing order: $e');
      rethrow;
    }
  }

  Stream<List<model_order.Order>> getUserOrders(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('orders')
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => model_order.Order.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> updateOrderStatus(String userId, String orderId, String status,
      {String? trackingNumber,
      String? courierService,
      DateTime? estimatedDeliveryDate}) async {
    try {
      // Update order in user's collection
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .doc(orderId)
          .update({
        'status': status,
        'trackingNumber': trackingNumber,
        'courierService': courierService,
        'estimatedDeliveryDate': estimatedDeliveryDate != null
            ? Timestamp.fromDate(estimatedDeliveryDate)
            : null,
      });

      // Update order in global orders collection
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
        'trackingNumber': trackingNumber,
        'courierService': courierService,
        'estimatedDeliveryDate': estimatedDeliveryDate != null
            ? Timestamp.fromDate(estimatedDeliveryDate)
            : null,
      });

      final order = await _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .doc(orderId)
          .get();
      final orderData = order.data() as Map<String, dynamic>;
      await _emailService.sendEmail(
        orderData['shippingAddress']['email'],
        'Order Status Update #${orderData['orderId']}',
        '<h1>Your order status has been updated!</h1><p>Your order is now: $status</p>',
      );
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<model_order.Order>> getAllOrders() {
    return _firestore
        .collection('orders')
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => model_order.Order.fromFirestore(doc))
            .toList());
  }

  Stream<model_order.Order> getOrderStream(String userId, String orderId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .map((snapshot) => model_order.Order.fromFirestore(snapshot));
  }
}
