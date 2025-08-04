import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:laptop_harbour/models/discount.dart';
import 'package:laptop_harbour/models/reviews.dart';
import 'package:laptop_harbour/models/specs.dart';

class Laptop {
  final Discount? discount;
  final List<String> tags;
  final String title;
  final Specs specs;
  final double rating;
  final List<Reviews> reviews;
  final double price;
  final String image;
  final String categoryId;
  Laptop({
    this.discount,
    required this.tags,
    required this.title,
    required this.specs,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.image,
    required this.categoryId,
  });

  Laptop copyWith({
    Discount? discount,
    List<String>? tags,
    String? title,
    Specs? specs,
    double? rating,
    List<Reviews>? reviews,
    double? price,
    String? image,
    String? categoryId,
  }) {
    return Laptop(
      discount: discount ?? this.discount,
      tags: tags ?? this.tags,
      title: title ?? this.title,
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
      'discount': discount?.toMap(),
      'tags': tags,
      'title': title,
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
      discount: map['discount'] != null ? Discount.fromMap(map['discount'] as Map<String,dynamic>) : null,
      tags: List<String>.from((map['tags'] as List<String>)),
      title: map['title'] as String,
      specs: Specs.fromMap(map['specs'] as Map<String,dynamic>),
      rating: map['rating'] as double,
      import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:laptop_harbour/models/discount.dart';
import 'package:laptop_harbour/models/reviews.dart';
import 'package:laptop_harbour/models/specs.dart';

class Laptop {
  final Discount? discount;
  final List<String> tags;
  final String title;
  final String brand;
  final Specs specs;
  final double rating;
  final List<Reviews> reviews;
  final double price;
  final String image;
  final String categoryId;
  Laptop({
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
  });

  Laptop copyWith({
    Discount? discount,
    List<String>? tags,
    String? title,
    String? brand,
    Specs? specs,
    double? rating,
    List<Reviews>? reviews,
    double? price,
    String? image,
    String? categoryId,
  }) {
    return Laptop(
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
      discount: map['discount'] != null
          ? Discount.fromMap(map['discount'] as Map<String, dynamic>)
          : null,
      tags: List<String>.from((map['tags'] as List<dynamic>)),
      title: map['title'] as String,
      brand: map['brand'] as String,
      specs: Specs.fromMap(map['specs'] as Map<String, dynamic>),
      rating: map['rating'] as double,
      reviews: List<Reviews>.from(
        (map['reviews'] as List<dynamic>).map<Reviews>(
          (x) => Reviews.fromMap(x as Map<String, dynamic>),
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
    return 'Laptop(discount: $discount, tags: $tags, title: $title, brand: $brand, specs: $specs, rating: $rating, reviews: $reviews, price: $price, image: $image, categoryId: $categoryId)';
  }

  @override
  bool operator ==(covariant Laptop other) {
    if (identical(this, other)) return true;

    return other.discount == discount &&
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
    return discount.hashCode ^
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

      price: map['price'] as double,
      image: map['image'] as String,
      categoryId: map['categoryId'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Laptop.fromJson(String source) => Laptop.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Laptop(discount: $discount, tags: $tags, title: $title, specs: $specs, rating: $rating, reviews: $reviews, price: $price, image: $image, categoryId: $categoryId)';
  }

  @override
  bool operator ==(covariant Laptop other) {
    if (identical(this, other)) return true;
  
    return 
      other.discount == discount &&
      listEquals(other.tags, tags) &&
      other.title == title &&
      other.specs == specs &&
      other.rating == rating &&
      listEquals(other.reviews, reviews) &&
      other.price == price &&
      other.image == image &&
      other.categoryId == categoryId;
  }

  @override
  int get hashCode {
    return discount.hashCode ^
      tags.hashCode ^
      title.hashCode ^
      specs.hashCode ^
      rating.hashCode ^
      reviews.hashCode ^
      price.hashCode ^
      image.hashCode ^
      categoryId.hashCode;
  }
}