import 'package:flutter/material.dart';
import 'package:laptop_harbour/models/laptop.dart';
import 'package:laptop_harbour/services/laptop_service.dart';

class LaptopProvider with ChangeNotifier {
  final LaptopService _laptopService = LaptopService();
  final List<Laptop> _laptops = [];
  String _searchQuery = '';
  String? _selectedCategoryId;
  double? _minPrice;
  double? _maxPrice;
  bool _isLoading = false;
  String? _error;

  List<Laptop> get laptops => _laptops;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;

  Stream<List<Laptop>> getLaptopsStream() {
    if (_searchQuery.isNotEmpty) {
      return _laptopService.searchLaptops(_searchQuery);
    } else if (_selectedCategoryId != null) {
      return _laptopService.getLaptopsByCategory(_selectedCategoryId!);
    } else if (_minPrice != null && _maxPrice != null) {
      return _laptopService.getLaptopsByPriceRange(_minPrice!, _maxPrice!);
    } else {
      return _laptopService.getLaptops();
    }
  }

  Future<void> addLaptop(Laptop laptop) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _laptopService.createLaptop(laptop);
      _laptops.add(laptop);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> updateLaptop(String id, Laptop laptop) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _laptopService.updateLaptop(id, laptop);
      final index = _laptops.indexWhere((l) => l.id == id);
      if (index != -1) {
        _laptops[index] = laptop;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete
  Future<void> deleteLaptop(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _laptopService.deleteLaptop(id);
      _laptops.removeWhere((laptop) => laptop.id == id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }


  void setSelectedCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }


  void setPriceRange(double? min, double? max) {
    _minPrice = min;
    _maxPrice = max;
    notifyListeners();
  }


  void clearFilters() {
    _searchQuery = '';
    _selectedCategoryId = null;
    _minPrice = null;
    _maxPrice = null;
    notifyListeners();
  }


  void clearError() {
    _error = null;
    notifyListeners();
  }
}
