class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
