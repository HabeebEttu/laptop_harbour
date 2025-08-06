// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:laptop_harbour/models/cart.dart';
import 'package:laptop_harbour/models/order.dart';
import 'package:laptop_harbour/models/profile.dart';

class User {
  
  final Profile profile;
  final Cart cart;
  final List<Order> orders;

  User({
    required this.profile,
    required this.cart,
    required this.orders,
  });

  User copyWith({
    Profile? profile,
    Cart? cart,
    List<Order>? orders,
  }) {
    return User(
      profile: profile ?? this.profile,
      cart: cart ?? this.cart,
      orders: orders ?? this.orders,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'profile': profile.toMap(),
      'cart': cart.toMap(),
      'orders': orders.map((x) => x.toMap()).toList(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      profile: Profile.fromMap(map['profile'] as Map<String,dynamic>),
      cart: Cart.fromMap(map['cart'] as Map<String,dynamic>),
            orders: List<Order>.from((map['orders'] as List<dynamic>).map<Order>((x) => Order.fromMap(x as Map<String,dynamic>),),),
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'User(profile: $profile, cart: $cart, orders: $orders)';

  @override
  bool operator ==(covariant User other) {
    if (identical(this, other)) return true;
  
    return 
      other.profile == profile &&
      other.cart == cart &&
      listEquals(other.orders, orders);
  }

  @override
  int get hashCode => profile.hashCode ^ cart.hashCode ^ orders.hashCode;
}
