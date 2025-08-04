import 'dart:convert';

class Reviews {
  final String userId;
  final double rating;
  final String comment;
  Reviews({
    required this.userId,
    required this.rating,
    required this.comment,
  });

  Reviews copyWith({
    String? userId,
    double? rating,
    String? comment,
  }) {
    return Reviews(
      userId: userId ?? this.userId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'rating': rating,
      'comment': comment,
    };
  }

  factory Reviews.fromMap(Map<String, dynamic> map) {
    return Reviews(
      userId: map['userId'] as String,
      rating: map['rating'] as double,
      comment: map['comment'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Reviews.fromJson(String source) =>
      Reviews.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Reviews(userId: $userId, rating: $rating, comment: $comment)';

  @override
  bool operator ==(covariant Reviews other) {
    if (identical(this, other)) return true;

    return other.userId == userId &&
        other.rating == rating &&
        other.comment == comment;
  }

  @override
  int get hashCode => userId.hashCode ^ rating.hashCode ^ comment.hashCode;
}
