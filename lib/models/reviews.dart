// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Reviews {
  final String userId;
  final double rating;
  final String comment;
  final DateTime reviewDate;

  Reviews({
    required this.userId,
    required this.rating,
    required this.comment,
    required this.reviewDate,
  });

  Reviews copyWith({
    String? userId,
    double? rating,
    String? comment,
    DateTime? reviewDate,
  }) {
    return Reviews(
      userId: userId ?? this.userId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      reviewDate: reviewDate ?? this.reviewDate,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'rating': rating,
      'comment': comment,
      'reviewDate': reviewDate.millisecondsSinceEpoch,
    };
  }

  factory Reviews.fromMap(Map<String, dynamic> map) {
    return Reviews(
      userId: map['userId'] as String,
      rating: map['rating'] as double,
      comment: map['comment'] as String,
      reviewDate: DateTime.fromMillisecondsSinceEpoch(map['reviewDate'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory Reviews.fromJson(String source) =>
      Reviews.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Reviews(userId: $userId, rating: $rating, comment: $comment, reviewDate: $reviewDate)';
  }

  @override
  bool operator ==(covariant Reviews other) {
    if (identical(this, other)) return true;

    return other.userId == userId &&
        other.rating == rating &&
        other.comment == comment &&
        other.reviewDate == reviewDate;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        rating.hashCode ^
        comment.hashCode ^
        reviewDate.hashCode;
  }
}