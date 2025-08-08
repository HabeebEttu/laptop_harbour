import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laptop_harbour/models/laptop.dart';

class LaptopService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection = 'laptops';

  // Create
  Future<DocumentReference> createLaptop(Laptop laptop) async {
    return await _firestore.collection(collection).add(laptop.toMap());
  }

  // Read
  Stream<List<Laptop>> getLaptops() {
    return _firestore.collection(collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Laptop.fromMap({...data, 'id': doc.id});
      }).toList();
    });
  }

  Future<List<Laptop>> getAllLaptops() async {
    final querySnapshot = await _firestore.collection(collection).get();
    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return Laptop.fromMap({...data, 'id': doc.id});
    }).toList();
  }

  // Read Single Laptop
  Future<Laptop?> getLaptop(String id) async {
    final doc = await _firestore.collection(collection).doc(id).get();
    if (!doc.exists) return null;
    return Laptop.fromMap({...doc.data()!, 'id': doc.id});
  }

  // Update
  Future<void> updateLaptop(String id, Laptop laptop) async {
    await _firestore.collection(collection).doc(id).update(laptop.toMap());
  }

  // Delete
  Future<void> deleteLaptop(String id) async {
    await _firestore.collection(collection).doc(id).delete();
  }

  // Search Laptops
  Stream<List<Laptop>> searchLaptops(String query) {
    return _firestore
        .collection(collection)
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: '$query\uf8ff')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Laptop.fromMap({...data, 'id': doc.id});
      }).toList();
    });
  }

  
  Stream<List<Laptop>> getLaptopsByCategory(String categoryId) {
    return _firestore
        .collection(collection)
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Laptop.fromMap({...data, 'id': doc.id});
      }).toList();
    });
  }


  Stream<List<Laptop>> getLaptopsByPriceRange(double minPrice, double maxPrice) {
    return _firestore
        .collection(collection)
        .where('price', isGreaterThanOrEqualTo: minPrice)
        .where('price', isLessThanOrEqualTo: maxPrice)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Laptop.fromMap({...data, 'id': doc.id});
      }).toList();
    });
  }


  Stream<List<Laptop>> getFeaturedLaptops() {
    return _firestore
        .collection(collection)
        .where('isFeatured', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Laptop.fromMap({...data, 'id': doc.id});
      }).toList();
    });
  }

 
  Stream<List<Laptop>> getTopRatedLaptops() {
    return _firestore
        .collection(collection)
        .orderBy('rating', descending: true)
        .limit(5)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Laptop.fromMap({...data, 'id': doc.id});
      }).toList();
    });
  }
}