import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laptop_harbour/models/cart_item.dart';

class Order {
  final String orderId;
  final String userId;
  final List<CartItem> items;
  final double totalPrice;
  final DateTime orderDate;
  final Map<String, String> shippingAddress;
  final String status;
  final String? trackingNumber;
  final String? courierService;

  Order({
    required this.orderId,
    required this.userId,
    required this.items,
    required this.totalPrice,
    required this.orderDate,
    required this.shippingAddress,
    this.status = 'Processing',
    this.trackingNumber,
    this.courierService,
  });

  factory Order.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Order(
      orderId: doc.id,
      userId: data['userId'],
      items: (data['items'] as List)
          .map((item) => CartItem.fromMap(item))
          .toList(),
      totalPrice: data['totalPrice'],
      orderDate: (data['orderDate'] as Timestamp).toDate(),
      shippingAddress: Map<String, String>.from(data['shippingAddress']),
      status: data['status'],
      trackingNumber: data['trackingNumber'],
      courierService: data['courierService'],
    );
  }

  factory Order.fromMap(Map<String, dynamic> data) {
    return Order(
      orderId: data['orderId'],
      userId: data['userId'],
      items: (data['items'] as List)
          .map((item) => CartItem.fromMap(item))
          .toList(),
      totalPrice: data['totalPrice'],
      orderDate: (data['orderDate'] as Timestamp).toDate(),
      shippingAddress: Map<String, String>.from(data['shippingAddress']),
      status: data['status'],
      trackingNumber: data['trackingNumber'],
      courierService: data['courierService'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalPrice': totalPrice,
      'orderDate': orderDate,
      'shippingAddress': shippingAddress,
      'status': status,
      'trackingNumber': trackingNumber,
      'courierService': courierService,
    };
  }
}