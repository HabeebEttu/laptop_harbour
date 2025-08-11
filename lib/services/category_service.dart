import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laptop_harbour/models/category.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = 'categories';

  Future<DocumentReference> createCategory(Category category) async {
    return await _firestore.collection(collection).add(category.toMap());
  }

  Stream<List<Category>> getCategories() {
    return _firestore.collection(collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Category.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<Category?> getCategory(String id) async {
    final doc = await _firestore.collection(collection).doc(id).get();
    if (!doc.exists) return null;
    return Category.fromMap(doc.data()!, doc.id);
  }
}
