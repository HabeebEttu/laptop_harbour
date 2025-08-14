import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:laptop_harbour/models/discount.dart';
import 'package:laptop_harbour/models/review.dart';
import 'package:laptop_harbour/models/specs.dart';

class Laptop {
  final String? id;
  final Discount? discount;
  final List<String> tags;
  final String title;
  final String titleLowercase;
  final String brand;
  final Specs specs;
  final double rating;
  final List<Review> reviews;
  final double price;
  final String image;
  final String categoryId;
  Laptop({
    this.id,
    this.discount,
    required this.tags,
    required this.title,
    required this.brand,
    required this.specs,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.image,
    required this.categoryId,
  }) : titleLowercase = title.toLowerCase();

  Laptop copyWith({
    String? id,
    Discount? discount,
    List<String>? tags,
    String? title,
    String? brand,
    Specs? specs,
    double? rating,
    List<Review>? reviews,
    double? price,
    String? image,
    String? categoryId,
  }) {
    return Laptop(
      id: id ?? this.id,
      discount: discount ?? this.discount,
      tags: tags ?? this.tags,
      title: title ?? this.title,
      brand: brand ?? this.brand,
      specs: specs ?? this.specs,
      rating: rating ?? this.rating,
      reviews: reviews ?? this.reviews,
      price: price ?? this.price,
      image: image ?? this.image,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'discount': discount?.toMap(),
      'tags': tags,
      'title': title,
      'brand': brand,
      'specs': specs.toMap(),
      'rating': rating,
      'reviews': reviews.map((x) => x.toMap()).toList(),
      'price': price,
      'image': image,
      'categoryId': categoryId,
    };
  }

  factory Laptop.fromMap(Map<String, dynamic> map) {
    return Laptop(
      id: map['id'] != null ? map['id'] as String : null,
      discount: map['discount'] != null
          ? Discount.fromMap(map['discount'] as Map<String, dynamic>)
          : null,
      tags: List<String>.from((map['tags'] as List<dynamic>)),
      title: map['title'] as String,
      brand: map['brand'] as String,
      specs: Specs.fromMap(map['specs'] as Map<String, dynamic>),
      rating: map['rating'] as double,
      reviews: List<Review>.from(
        (map['reviews'] as List<dynamic>).map<Review>(
          (x) => Review.fromMap(x as Map<String, dynamic>),
        ),
      ),
      price: map['price'] as double,
      image: map['image'] as String,
      categoryId: map['categoryId'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Laptop.fromJson(String source) =>
      Laptop.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Laptop(id: $id, discount: $discount, tags: $tags, title: $title, brand: $brand, specs: $specs, rating: $rating, reviews: $reviews, price: $price, image: $image, categoryId: $categoryId)';
  }

  @override
  bool operator ==(covariant Laptop other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.discount == discount &&
        listEquals(other.tags, tags) &&
        other.title == title &&
        other.brand == brand &&
        other.specs == specs &&
        other.rating == rating &&
        listEquals(other.reviews, reviews) &&
        other.price == price &&
        other.image == image &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        discount.hashCode ^
        tags.hashCode ^
        title.hashCode ^
        brand.hashCode ^
        specs.hashCode ^
        rating.hashCode ^
        reviews.hashCode ^
        price.hashCode ^
        image.hashCode ^
        categoryId.hashCode;
  }
}
