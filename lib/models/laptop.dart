// ignore_for_file: public_member_api_docs, sort_constructors_first
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
    Discount? discount,
    List<String>? tags,
    String? title,
    Specs? specs,
    double? rating,
    List<Reviews>? reviews,
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
      'discount': discount?.toMap(),
      'tags': tags,
      'title': title,
      'specs': specs.toMap(),
      'rating': rating,
      'reviews': reviews.map((x) => x.toMap()).toList(),
      'price': price,
      'oldPrice': oldPrice,
      'image': image,
    };
  }

  factory Laptop.fromMap(Map<String, dynamic> map) {
    return Laptop(
      discount: map['discount'] != null ? Discount.fromMap(map['discount'] as Map<String,dynamic>) : null,
      tags: List<String>.from((map['tags'] as List<String>)),
      title: map['title'] as String,
      specs: Specs.fromMap(map['specs'] as Map<String,dynamic>),
      rating: map['rating'] as double,
      reviews: List<Reviews>.from((map['reviews'] as List<dynamic>).map<Reviews>(
        (x) => Reviews.fromMap(x as Map<String, dynamic>),
      )),
      price: map['price'] as double,
      oldPrice: map['oldPrice'] as double,
      image: map['image'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Laptop.fromJson(String source) => Laptop.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Laptop(discount: $discount, tags: $tags, title: $title, specs: $specs, rating: $rating, reviews: $reviews, price: $price, oldPrice: $oldPrice, image: $image)';
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