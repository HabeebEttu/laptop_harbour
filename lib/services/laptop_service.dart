import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laptop_harbour/models/laptop.dart';
import 'package:laptop_harbour/models/review.dart';

class LaptopService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'laptops';

  // Get all laptops as stream
  Stream<List<Laptop>> getLaptops() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            try {
              return Laptop.fromFirestore(doc);
            } catch (e) {
              debugPrint('Error parsing laptop document ${doc.id}: $e');
              // Return a default laptop or skip this document
              throw Exception('Error parsing laptop ${doc.id}: $e');
            }
          }).toList();
        });
  }

  // Get laptop by ID
  Future<Laptop?> getLaptopById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Laptop.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting laptop by ID: $e');
      rethrow;
    }
  }

  // Create new laptop
  Future<String> createLaptop(Laptop laptop) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(laptop.toMap());
      debugPrint('Laptop created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('Error creating laptop: $e');
      rethrow;
    }
  }

  // Update existing laptop
  Future<void> updateLaptop(String id, Laptop laptop) async {
    try {
      final updatedLaptop = laptop.copyWith(id: id);

      await _firestore
          .collection(_collection)
          .doc(id)
          .update(updatedLaptop.toMap());

      debugPrint('Laptop updated: $id');
    } catch (e) {
      debugPrint('Error updating laptop: $e');
      rethrow;
    }
  }

  // Delete laptop
  Future<void> deleteLaptop(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      debugPrint('Laptop deleted: $id');
    } catch (e) {
      debugPrint('Error deleting laptop: $e');
      rethrow;
    }
  }

  // Get laptops by category
  Stream<List<Laptop>> getLaptopsByCategory(String categoryId) {
    return _firestore
        .collection(_collection)
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Laptop.fromFirestore(doc)).toList();
        });
  }

  // Search laptops
  Stream<List<Laptop>> searchLaptops(String query) {
    return _firestore
        .collection(_collection)
        .orderBy('title')
        .startAt([query])
        .endAt([query + '\uf8ff'])
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Laptop.fromFirestore(doc)).toList();
        });
  }

  // Get laptops with price range filter
  Stream<List<Laptop>> getLaptopsInPriceRange(
    double minPrice,
    double maxPrice,
  ) {
    return _firestore
        .collection(_collection)
        .where('price', isGreaterThanOrEqualTo: minPrice)
        .where('price', isLessThanOrEqualTo: maxPrice)
        .orderBy('price')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Laptop.fromFirestore(doc)).toList();
        });
  }

  // Get top rated laptops
  Stream<List<Laptop>> getTopRatedLaptops({int limit = 10}) {
    return _firestore
        .collection(_collection)
        .orderBy('rating', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Laptop.fromFirestore(doc)).toList();
        });
  }

  // Get laptops by brand
  Stream<List<Laptop>> getLaptopsByBrand(String brand) {
    return _firestore
        .collection(_collection)
        .where('brand', isEqualTo: brand)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Laptop.fromFirestore(doc)).toList();
        });
  }

  // Add review to laptop
  Future<void> addReview(String laptopId, Review review) async {
    try {
      await _firestore.collection(_collection).doc(laptopId).update({
        'reviews': FieldValue.arrayUnion([review.toMap()]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Optionally recalculate average rating
      await _updateAverageRating(laptopId);

      debugPrint('Review added to laptop: $laptopId');
    } catch (e) {
      debugPrint('Error adding review: $e');
      rethrow;
    }
  }

  // Update average rating based on reviews
  Future<void> _updateAverageRating(String laptopId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(laptopId).get();
      if (doc.exists) {
        final laptop = Laptop.fromFirestore(doc);
        if (laptop.reviews.isNotEmpty) {
          final averageRating =
              laptop.reviews
                  .map((review) => review.rating)
                  .reduce((a, b) => a + b) /
              laptop.reviews.length;

          await _firestore.collection(_collection).doc(laptopId).update({
            'rating': averageRating,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      debugPrint('Error updating average rating: $e');
    }
  }

  // Batch operations
  Future<void> batchCreateLaptops(List<Laptop> laptops) async {
    try {
      final batch = _firestore.batch();

      for (final laptop in laptops) {
        final docRef = _firestore.collection(_collection).doc();
        batch.set(docRef, laptop.toMap());
      }

      await batch.commit();
      debugPrint('Batch created ${laptops.length} laptops');
    } catch (e) {
      debugPrint('Error in batch create: $e');
      rethrow;
    }
  }

  // Get laptops count
  Future<int> getLaptopsCount() async {
    try {
      final snapshot = await _firestore.collection(_collection).count().get();
      final count = snapshot.count;
      return count!;
    } catch (e) {
      debugPrint('Error getting laptops count: $e');
      return 0;
    }
  }

  // Get laptops with pagination
  Stream<List<Laptop>> getLaptopsWithPagination({
    int limit = 10,
    DocumentSnapshot? lastDocument,
  }) {
    Query query = _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Laptop.fromFirestore(doc)).toList();
    });
  }
}
