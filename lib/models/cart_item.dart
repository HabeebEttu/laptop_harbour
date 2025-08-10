import 'dart:convert';

import 'package:laptop_harbour/models/laptop.dart';

class CartItem {
  final Laptop item;
  final int quantity;
  
  CartItem({
    required this.item,
    required this.quantity,
  });

  CartItem copyWith({
    Laptop? item,
    int? quantity,
  }) {
    return CartItem(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'item': item.toMap(),
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      item: Laptop.fromMap(map['item'] as Map<String,dynamic>),
      quantity: map['quantity'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory CartItem.fromJson(String source) => CartItem.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'CartItem(item: $item, quantity: $quantity)';

  @override
  bool operator ==(covariant CartItem other) {
    if (identical(this, other)) return true;
  
    return 
      other.item == item &&
      other.quantity == quantity;
  }

  @override
  int get hashCode => item.hashCode ^ quantity.hashCode;
}
