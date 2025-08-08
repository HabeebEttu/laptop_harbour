// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:laptop_harbour/models/laptop.dart';

class Order {
  final String id;
  final List<Laptop> items;
  final String status;
  final DateTime orderDate;
  final DateTime estimatedDilveryDate;

  Order({
    required this.id,
    required this.items,
    required this.status,
    required this.orderDate,
    required this.estimatedDilveryDate,
  });

  Order copyWith({
    String? id,
    List<Laptop>? items,
    String? status,
    DateTime? orderDate,
    DateTime? estimatedDilveryDate,
  }) {
    return Order(
      id: id ?? this.id,
      items: items ?? this.items,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      estimatedDilveryDate: estimatedDilveryDate ?? this.estimatedDilveryDate,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'items': items.map((x) => x.toMap()).toList(),
      'status': status,
      'orderDate': orderDate.millisecondsSinceEpoch,
      'estimatedDilveryDate': estimatedDilveryDate.millisecondsSinceEpoch,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as String,
      items: List<Laptop>.from((map['items'] as List<dynamic>).map<Laptop>((x) => Laptop.fromMap(x as Map<String,dynamic>),),),
      status: map['status'] as String,
      orderDate: DateTime.fromMillisecondsSinceEpoch(map['orderDate'] as int),
      estimatedDilveryDate: DateTime.fromMillisecondsSinceEpoch(map['estimatedDilveryDate'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) => Order.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Order(id: $id, items: $items, status: $status, orderDate: $orderDate, estimatedDilveryDate: $estimatedDilveryDate)';
  }

  @override
  bool operator ==(covariant Order other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      listEquals(other.items, items) &&
      other.status == status &&
      other.orderDate == orderDate &&
      other.estimatedDilveryDate == estimatedDilveryDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      items.hashCode ^
      status.hashCode ^
      orderDate.hashCode ^
      estimatedDilveryDate.hashCode;
  }
}
