import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laptop_harbour/models/review.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'reviews';

  
  Future<void> addReview(String laptopId, Review review) async {
    await _firestore
        .collection('laptops')
        .doc(laptopId)
        .collection(_collectionPath)
        .add(review.toMap());
  }

 
  Stream<List<Review>> getReviews(String laptopId) {
    return _firestore
        .collection('laptops')
        .doc(laptopId)
        .collection(_collectionPath)
        .orderBy('reviewDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Review.fromMap(doc.data())).toList();
    });
  }


  Future<void> updateLaptopRating(String laptopId) async {
    final reviewsSnapshot = await _firestore
        .collection('laptops')
        .doc(laptopId)
        .collection(_collectionPath)
        .get();

    if (reviewsSnapshot.docs.isEmpty) {
      await _firestore.collection('laptops').doc(laptopId).update({'rating': 0.0});
      return;
    }

    double totalRating = 0;
    for (var doc in reviewsSnapshot.docs) {
      totalRating += doc.data()['rating'] as double;
    }
    double averageRating = totalRating / reviewsSnapshot.docs.length;

    await _firestore.collection('laptops').doc(laptopId).update({
      'rating': averageRating,
    });
  }
}
