import 'dart:convert';

class Discount {
  final double value;
  final DateTime expiryDate;

  Discount({
    required this.value,
    required this.expiryDate,
  });

  Discount copyWith({
    double? value,
    DateTime? expiryDate,
  }) {
    return Discount(
      value: value ?? this.value,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'value': value,
      'expiryDate': expiryDate.millisecondsSinceEpoch,
    };
  }

  factory Discount.fromMap(Map<String, dynamic> map) {
    return Discount(
      value: map['value'] as double,
      expiryDate: DateTime.fromMillisecondsSinceEpoch(map['expiryDate'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory Discount.fromJson(String source) =>
      Discount.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Discount(value: $value, expiryDate: $expiryDate)';

  @override
  bool operator ==(covariant Discount other) {
    if (identical(this, other)) return true;

    return other.value == value && other.expiryDate == expiryDate;
  }

  @override
  int get hashCode => value.hashCode ^ expiryDate.hashCode;
}