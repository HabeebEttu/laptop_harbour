// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Specs {
  final String processor;
  final String ram;
  final String storage;
  final String display;
  final String? graphicsCard;

  Specs({
    required this.processor,
    required this.ram,
    required this.storage,
    required this.display,
    this.graphicsCard,
  });


  Specs copyWith({
    String? processor,
    String? ram,
    String? storage,
    String? display,
    String? graphicsCard,
  }) {
    return Specs(
      processor: processor ?? this.processor,
      ram: ram ?? this.ram,
      storage: storage ?? this.storage,
      display: display ?? this.display,
      graphicsCard: graphicsCard ?? this.graphicsCard,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'processor': processor,
      'ram': ram,
      'storage': storage,
      'display': display,
      'graphicsCard': graphicsCard,
    };
  }

  factory Specs.fromMap(Map<String, dynamic> map) {
    return Specs(
      processor: map['processor'] as String,
      ram: map['ram'] as String,
      storage: map['storage'] as String,
      display: map['display'] as String,
      graphicsCard: map['graphicsCard'] != null ? map['graphicsCard'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Specs.fromJson(String source) => Specs.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Specs(processor: $processor, ram: $ram, storage: $storage, display: $display, graphicsCard: $graphicsCard)';
  }

  @override
  bool operator ==(covariant Specs other) {
    if (identical(this, other)) return true;
  
    return 
      other.processor == processor &&
      other.ram == ram &&
      other.storage == storage &&
      other.display == display &&
      other.graphicsCard == graphicsCard;
  }

  @override
  int get hashCode {
    return processor.hashCode ^
      ram.hashCode ^
      storage.hashCode ^
      display.hashCode ^
      graphicsCard.hashCode;
  }
}
