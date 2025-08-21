// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final DateTime? createdAt;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.createdAt,
  });

  // Convert from Firestore document
  factory Category.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      icon: data['icon'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }

  @override
  bool operator ==(covariant Category other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.name == name &&
      other.description == description &&
      other.icon == icon &&
      other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      icon.hashCode ^
      createdAt.hashCode;
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, description: $description, icon: $icon, createdAt: $createdAt)';
  }

  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] != null ? map['description'] as String : null,
      icon: map['icon'] != null ? map['icon'] as String : null,
      createdAt: map['createdAt'] != null ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Category.fromJson(String source) => Category.fromMap(json.decode(source) as Map<String, dynamic>);
}
