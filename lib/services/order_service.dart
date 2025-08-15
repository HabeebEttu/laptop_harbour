import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:laptop_harbour/models/order.dart' as model_order;

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> placeOrder(model_order.Order order) async {
    try {
      // Place order in user's collection
      await _firestore
          .collection('users')
          .doc(order.userId)
          .collection('orders')
          .doc(order.orderId)
          .set(order.toMap());

      // Place order in global orders collection for admin
      await _firestore.collection('orders').doc(order.orderId).set(order.toMap());
    } catch (e) {
      // It's a good practice to log errors or handle them as needed
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
        .map((snapshot) =>
            snapshot.docs.map((doc) => model_order.Order.fromFirestore(doc)).toList());
  }

  Future<void> updateOrderStatus(String userId, String orderId, String status,
      {String? trackingNumber, String? courierService, DateTime? estimatedDeliveryDate}) async {
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
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<model_order.Order>> getAllOrders() {
    return _firestore
        .collection('orders')
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => model_order.Order.fromFirestore(doc)).toList());
  }
}