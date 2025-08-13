// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:laptop_harbour/models/cart_item.dart';

class Cart {
  final String userId;
  final List<CartItem> items;

  Cart({
    required this.userId,
    required this.items,
  });

  Cart copyWith({
    String? userId,
    List<CartItem>? items,
  }) {
    return Cart(
      userId: userId ?? this.userId,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'items': items.map((x) => x.toMap()).toList(),
    };
  }

  factory Cart.fromMap(Map<String, dynamic> map) {
    return Cart(
      userId: map['userId'] as String,
      items: List<CartItem>.from((map['items'] as List<dynamic>).map<CartItem>((x) => CartItem.fromMap(x as Map<String,dynamic>),),),
    );
  }

  String toJson() => json.encode(toMap());

  factory Cart.fromJson(String source) =>
      Cart.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Cart(userId: $userId, items: $items)';

  @override
  bool operator ==(covariant Cart other) {
    if (identical(this, other)) return true;
  
    return 
      other.userId == userId &&
      listEquals(other.items, items);
  }

  @override
  int get hashCode => userId.hashCode ^ items.hashCode;

  double get totalPrice {
    return items.fold(0.0, (sum, item) => sum + (item.item.price * item.quantity));
  }
}
