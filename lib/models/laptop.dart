import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:laptop_harbour/models/discount.dart';
import 'package:laptop_harbour/models/specs.dart';

class Laptop {
  final String? id;
  final Discount? discount;
  final List<String> tags;
  final String title;
  final String titleLowercase;
  final String brand;
  final String description;
  final Specs specs;
  final double rating;
  final double price;
  final String image;
  final String categoryId;
  bool isWishlisted;
  final DateTime? createdAt;
  final int stockAmount;

  Laptop({
    this.id,
    this.discount,
    required this.tags,
    required this.title,
    required this.brand,
    required this.description,
    required this.specs,
    required this.rating,
    // Removed: required this.reviews,
    required this.price,
    required this.image,
    required this.categoryId,
    this.isWishlisted = false,
    this.createdAt,
    required this.stockAmount,
  }) : titleLowercase = title.toLowerCase();

  Laptop copyWith({
    String? id,
    Discount? discount,
    List<String>? tags,
    String? title,
    String? brand,
    String? description,
    Specs? specs,
    double? rating,
    // Removed: List<Review>? reviews,
    double? price,
    String? image,
    String? categoryId,
    bool? isWishlisted,
    DateTime? createdAt,
    int? stockAmount,
  }) {
    return Laptop(
      id: id ?? this.id,
      discount: discount ?? this.discount,
      tags: tags ?? this.tags,
      title: title ?? this.title,
      brand: brand ?? this.brand,
      description: description ?? this.description,
      specs: specs ?? this.specs,
      rating: rating ?? this.rating,
      // Removed: reviews: reviews ?? this.reviews,
      price: price ?? this.price,
      image: image ?? this.image,
      categoryId: categoryId ?? this.categoryId,
      isWishlisted: isWishlisted ?? this.isWishlisted,
      createdAt: createdAt ?? this.createdAt,
      stockAmount: stockAmount ?? this.stockAmount,
    );
  }

  factory Laptop.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Laptop(
      id: doc.id,
      title: data['title'] ?? '',
      brand: data['brand'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      image: data['image'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      // Removed: reviews: (data['reviews'] as List<dynamic>?)?.map((review) => Review.fromMap(review)).toList() ?? [],
      tags: List<String>.from(data['tags'] ?? []),
      specs: Specs.fromMap(data['specs'] ?? {}),
      discount: data['discount'] != null
          ? Discount.fromMap(data['discount'])
          : null,
      categoryId: data['categoryId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      stockAmount: data['stockAmount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'discount': discount?.toMap(),
      'tags': tags,
      'title': title,
      'brand': brand,
      'description': description,
      'specs': specs.toMap(),
      'rating': rating,
      // Removed: 'reviews': reviews.map((x) => x.toMap()).toList(),
      'price': price,
      'image': image,
      'categoryId': categoryId,
      'isWishlisted': isWishlisted,
      'createdAt': createdAt,
      'stockAmount': stockAmount,
    };
  }

  factory Laptop.fromMap(Map<String, dynamic> map) {
    return Laptop(
      id: map['id'] != null ? map['id'] as String : null,
      discount: map['discount'] != null
          ? Discount.fromMap(map['discount'] as Map<String, dynamic>)
          : null,
      tags: List<String>.from(map['tags'] ?? []),
      title: map['title'] ?? '',
      brand: map['brand'] ?? '',
      description: map['description'] ?? '',
      specs: Specs.fromMap(map['specs'] ?? {}),
      rating: (map['rating'] ?? 0).toDouble(),
      price: (map['price'] ?? 0).toDouble(),
      image: map['image'] ?? '',
      categoryId: map['categoryId'] ?? '',
      isWishlisted: map['isWishlisted'] ?? false,
      createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : null,
      stockAmount: map['stockAmount'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Laptop.fromJson(String source) =>
      Laptop.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Laptop(id: $id, discount: $discount, tags: $tags, title: $title, brand: $brand, description: $description, specs: $specs, rating: $rating, price: $price, image: $image, categoryId: $categoryId, isWishlisted: $isWishlisted, createdAt: $createdAt, stockAmount: $stockAmount)';
  }

  @override
  bool operator ==(covariant Laptop other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.discount == discount &&
        listEquals(other.tags, tags) &&
        other.title == title &&
        other.brand == brand &&
        other.description == description &&
        other.specs == specs &&
        other.rating == rating &&
        // Removed: listEquals(other.reviews, reviews) &&
        other.price == price &&
        other.image == image &&
        other.categoryId == categoryId &&
        other.isWishlisted == isWishlisted &&
        other.createdAt == createdAt &&
        other.stockAmount == other.stockAmount;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        discount.hashCode ^
        tags.hashCode ^
        title.hashCode ^
        brand.hashCode ^
        description.hashCode ^
        specs.hashCode ^
        rating.hashCode ^
        // Removed: reviews.hashCode ^
        price.hashCode ^
        image.hashCode ^
        categoryId.hashCode ^
        isWishlisted.hashCode ^
        createdAt.hashCode ^
        stockAmount.hashCode;
  }
}
