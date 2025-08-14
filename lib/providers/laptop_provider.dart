import 'dart:async';

import 'package:flutter/material.dart';
import 'package:laptop_harbour/models/laptop.dart';
import 'package:laptop_harbour/services/laptop_service.dart';

class LaptopProvider with ChangeNotifier {
  final LaptopService _laptopService = LaptopService();
  final _laptopsController = StreamController<List<Laptop>>.broadcast();
  String _searchQuery = '';
  String? _selectedCategoryId;
  double? _minPrice;
  double? _maxPrice;
  String _sortCriterion = 'none';
  bool _isLoading = false;
  String? _error;

  LaptopProvider() {
    fetchLaptops();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;

  Stream<List<Laptop>> getLaptopsStream() => _laptopsController.stream;

  Future<void> fetchLaptops() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final laptopsStream = _laptopService.getLaptops();
      await for (final laptops in laptopsStream) {
        final filteredLaptops = _applyFilters(laptops);
        _laptopsController.add(filteredLaptops);
      }
    } catch (e) {
      _error = e.toString();
      _laptopsController.addError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Laptop> _applyFilters(List<Laptop> laptops) {
    List<Laptop> filteredLaptops = laptops;
    if (_searchQuery.isNotEmpty) {
      filteredLaptops = filteredLaptops.where((laptop) {
        return laptop.title.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    } else if (_selectedCategoryId != null) {
      filteredLaptops = filteredLaptops
          .where((laptop) => laptop.categoryId == _selectedCategoryId)
          .toList();
    } else if (_minPrice != null && _maxPrice != null) {
      filteredLaptops = filteredLaptops
          .where(
            (laptop) =>
                laptop.price >= _minPrice! && laptop.price <= _maxPrice!,
          )
          .toList();
    }

    if (_sortCriterion == 'price_asc') {
      filteredLaptops.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortCriterion == 'price_desc') {
      filteredLaptops.sort((a, b) => b.price.compareTo(a.price));
    } else if (_sortCriterion == 'rating') {
      filteredLaptops.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return filteredLaptops;
  }

  Future<void> addLaptop(Laptop laptop) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _laptopService.createLaptop(laptop);
      fetchLaptops(); // Refresh data after adding
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
      fetchLaptops(); // Refresh data after updating
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
      fetchLaptops(); // Refresh data after deleting
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchLaptops(); // Re-fetch with new query
  }

  void setSelectedCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    fetchLaptops(); // Re-fetch with new category
  }

  void setPriceRange(double? min, double? max) {
    _minPrice = min;
    _maxPrice = max;
    fetchLaptops(); // Re-fetch with new price range
  }

  void setSortCriterion(String criterion) {
    _sortCriterion = criterion;
    fetchLaptops(); // Re-fetch with new sort criterion
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategoryId = null;
    _minPrice = null;
    _maxPrice = null;
    _sortCriterion = 'none';
    fetchLaptops(); // Re-fetch after clearing filters
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _laptopsController.close();
    super.dispose();
  }
}
