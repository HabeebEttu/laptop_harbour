import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laptop_harbour/models/category.dart';

class CategoryProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addCategory(Category category) async {
    await _firestore.collection('categories').add(category.toMap());
  }

  Future<Category> getCategory(String categoryId) async{
    final doc = await _firestore.collection('categories').doc(categoryId).get();
    return Category(id: categoryId, name: doc.data()?['name'] ?? '');
  }
  Stream<List<Category>> getCategories() {
    return _firestore.collection('categories').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Category(
          id: doc.id,
          name: doc.data()['name'] ?? '',
        );
      }).toList();
    });
  }
  
}
