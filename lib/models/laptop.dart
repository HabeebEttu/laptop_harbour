// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class Laptop {
  final String? discount;
  final List<String> tags;
  final String title;
  final List<String> specs;
  final double rating;
  final int reviews;
  final double price;
  final double oldPrice;
  final String image;
  Laptop({
    this.discount,
    required this.tags,
    required this.title,
    required this.specs,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.oldPrice,
    required this.image,
  });

  Laptop copyWith({
    String? discount,
    List<String>? tags,
    String? title,
    List<String>? specs,
    double? rating,
    int? reviews,
    double? price,
    double? oldPrice,
    String? image,
  }) {
    return Laptop(
      discount: discount ?? this.discount,
      tags: tags ?? this.tags,
      title: title ?? this.title,
      specs: specs ?? this.specs,
      rating: rating ?? this.rating,
      reviews: reviews ?? this.reviews,
      price: price ?? this.price,
      oldPrice: oldPrice ?? this.oldPrice,
      image: image ?? this.image,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'discount': discount,
      'tags': tags,
      'title': title,
      'specs': specs,
      'rating': rating,
      'reviews': reviews,
      'price': price,
      'oldPrice': oldPrice,
      'image': image,
    };
  }

  factory Laptop.fromMap(Map<String, dynamic> map) {
    return Laptop(
      discount: map['discount'] != null ? map['discount'] as String : null,
      tags: List<String>.from((map['tags'] as List<String>)),
      title: map['title'] as String,
      specs: List<String>.from((map['specs'] as List<String>)),
      rating: map['rating'] as double,
      reviews: map['reviews'] as int,
      price: map['price'] as double,
      oldPrice: map['oldPrice'] as double,
      image: map['image'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Laptop.fromJson(String source) =>
      Laptop.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Laptop(discount: $discount, tags: $tags, title: $title, specs: $specs, rating: $rating, reviews: $reviews, price: $price, oldPrice: $oldPrice, image: $image)';
  }

  @override
  bool operator ==(covariant Laptop other) {
    if (identical(this, other)) return true;

    return other.discount == discount &&
        listEquals(other.tags, tags) &&
        other.title == title &&
        listEquals(other.specs, specs) &&
        other.rating == rating &&
        other.reviews == reviews &&
        other.price == price &&
        other.oldPrice == oldPrice &&
        other.image == image;
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
        oldPrice.hashCode ^
        image.hashCode;
  }
}