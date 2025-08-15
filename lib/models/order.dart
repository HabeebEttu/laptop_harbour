// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:laptop_harbour/models/cart_item.dart';

class Order {
  final String orderId;
  final String userId;
  final List<CartItem> items;
  final double totalPrice;
  final DateTime orderDate;
  final Map<String, String> shippingAddress;
  final String status;
  final DateTime? estimatedDeliveryDate;
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
    this.estimatedDeliveryDate,
    this.trackingNumber,
    this.courierService,
  });

  factory Order.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    DateTime parseTimestamp(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      throw FormatException('Invalid timestamp format: $value');
    }

    return Order(
      orderId: doc.id,
      userId: data['userId'],
      items: (data['items'] as List)
          .map((item) => CartItem.fromMap(item))
          .toList(),
      totalPrice: (data['totalPrice'] as num).toDouble(),
      orderDate: parseTimestamp(data['orderDate']),
      shippingAddress: Map<String, String>.from(data['shippingAddress']),
      status: data['status'],
      estimatedDeliveryDate: data['estimatedDeliveryDate'] != null
          ? parseTimestamp(data['estimatedDeliveryDate'])
          : null,
      trackingNumber: data['trackingNumber'],
      courierService: data['courierService'],
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'orderId': orderId,
      'userId': userId,
      'items': items.map((x) => x.toMap()).toList(),
      'totalPrice': totalPrice,
      'orderDate': Timestamp.fromDate(orderDate),
      'shippingAddress': shippingAddress,
      'status': status,
      'estimatedDeliveryDate': estimatedDeliveryDate != null
          ? Timestamp.fromDate(estimatedDeliveryDate!)
          : null,
      'trackingNumber': trackingNumber,
      'courierService': courierService,
    };
  }

  Order copyWith({
    String? orderId,
    String? userId,
    List<CartItem>? items,
    double? totalPrice,
    DateTime? orderDate,
    Map<String, String>? shippingAddress,
    String? status,
    DateTime? estimatedDeliveryDate,
    String? trackingNumber,
    String? courierService,
  }) {
    return Order(
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      orderDate: orderDate ?? this.orderDate,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      status: status ?? this.status,
      estimatedDeliveryDate: estimatedDeliveryDate ?? this.estimatedDeliveryDate,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      courierService: courierService ?? this.courierService,
    );
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) => Order.fromMap(json.decode(source) as Map<String, dynamic>);

  factory Order.fromMap(Map<String, dynamic> map) {
    DateTime parseTimestamp(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      throw FormatException('Invalid timestamp format: $value');
    }

    return Order(
      orderId: map['orderId'] as String,
      userId: map['userId'] as String,
      items: List<CartItem>.from((map['items'] as List).map<CartItem>((x) => CartItem.fromMap(x as Map<String,dynamic>),),),
      totalPrice: (map['totalPrice'] as num).toDouble(),
      orderDate: parseTimestamp(map['orderDate']),
      shippingAddress: Map<String, String>.from(map['shippingAddress']),
      status: map['status'] as String,
      estimatedDeliveryDate: map['estimatedDeliveryDate'] != null
          ? parseTimestamp(map['estimatedDeliveryDate'])
          : null,
      trackingNumber: map['trackingNumber'] as String?,
      courierService: map['courierService'] as String?,
    );
  }

  @override
  String toString() {
    return 'Order(orderId: $orderId, userId: $userId, items: $items, totalPrice: $totalPrice, orderDate: $orderDate, shippingAddress: $shippingAddress, status: $status, estimatedDeliveryDate: $estimatedDeliveryDate, trackingNumber: $trackingNumber, courierService: $courierService)';
  }

  @override
  bool operator ==(covariant Order other) {
    if (identical(this, other)) return true;
  
    return 
      other.orderId == orderId &&
      other.userId == userId &&
      listEquals(other.items, items) &&
      other.totalPrice == totalPrice &&
      other.orderDate == orderDate &&
      mapEquals(other.shippingAddress, shippingAddress) &&
      other.status == status &&
      other.estimatedDeliveryDate == estimatedDeliveryDate &&
      other.trackingNumber == trackingNumber &&
      other.courierService == courierService;
  }

  @override
  int get hashCode {
    return orderId.hashCode ^
      userId.hashCode ^
      items.hashCode ^
      totalPrice.hashCode ^
      orderDate.hashCode ^
      shippingAddress.hashCode ^
      status.hashCode ^
      estimatedDeliveryDate.hashCode ^
      trackingNumber.hashCode ^
      courierService.hashCode;
  }
}