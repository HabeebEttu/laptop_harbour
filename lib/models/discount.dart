// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Discount {
  final String type;
  final double value;
  final DateTime expiryDate;

  Discount({
    required this.type,
    required this.value,
    required this.expiryDate,
  });

  Discount copyWith({
    String? type,
    double? value,
    DateTime? expiryDate,
  }) {
    return Discount(
      type: type ?? this.type,
      value: value ?? this.value,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': type,
      'value': value,
      'expiryDate': expiryDate.millisecondsSinceEpoch,
    };
  }

  factory Discount.fromMap(Map<String, dynamic> map) {
    return Discount(
      type: map['type'] as String,
      value: map['value'] as double,
      expiryDate: DateTime.fromMillisecondsSinceEpoch(map['expiryDate'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory Discount.fromJson(String source) => Discount.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Discount(type: $type, value: $value, expiryDate: $expiryDate)';

  @override
  bool operator ==(covariant Discount other) {
    if (identical(this, other)) return true;
  
    return 
      other.type == type &&
      other.value == value &&
      other.expiryDate == expiryDate;
  }

  @override
  int get hashCode => type.hashCode ^ value.hashCode ^ expiryDate.hashCode;
}
