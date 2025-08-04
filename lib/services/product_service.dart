import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laptop_harbour/models/laptop.dart';

class ProductService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<List<Laptop>> getLaptops() async {
    try {
      final snapshot = await _firestore.collection('laptops').get();
      return snapshot.docs.map((doc) => Laptop.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error fetching laptops: $e');
      return [];
    }
  }
}
