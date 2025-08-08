import 'dart:convert';

class Review {
  final String userId;
  final double rating;
  final String comment;
  final DateTime reviewDate;

  Review({
    required this.userId,
    required this.rating,
    required this.comment,
    required this.reviewDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'rating': rating,
      'comment': comment,
      'reviewDate': reviewDate.toIso8601String(),
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      userId: map['userId'],
      rating: map['rating'].toDouble(),
      comment: map['comment'],
      reviewDate: DateTime.parse(map['reviewDate']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Review.fromJson(String source) => Review.fromMap(json.decode(source));
}
