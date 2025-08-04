import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laptop_harbour/models/laptop.dart';

class LaptopProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addLaptop(Laptop laptop) async {
    await _firestore.collection('laptops').add(laptop.toMap());
  }
}
