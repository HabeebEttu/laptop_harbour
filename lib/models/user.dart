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
    return {
      'profile': profile.toMap(),
      'cart': cart.toMap(),
      'orders': orders.map((x) => x.toMap()).toList(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      profile: Profile.fromMap(map['profile']),
      cart: Cart.fromMap(map['cart']),
      orders: map['orders'] != null
          ? List<Order>.from(map['orders']?.map((x) => Order.fromMap(x)))
          : [],
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  @override
  String toString() => 'User(profile: $profile, cart: $cart, orders: $orders)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.profile == profile &&
        other.cart == cart &&
        listEquals(other.orders, orders);
  }

  @override
  int get hashCode => profile.hashCode ^ cart.hashCode ^ orders.hashCode;
}