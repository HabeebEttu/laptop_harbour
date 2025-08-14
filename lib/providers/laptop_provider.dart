import 'dart:async';

import 'package:flutter/material.dart';
import 'package:laptop_harbour/models/laptop.dart';
import 'package:laptop_harbour/services/laptop_service.dart';

class LaptopProvider with ChangeNotifier {
  final LaptopService _laptopService = LaptopService();
  final _laptopsController = StreamController<List<Laptop>>.broadcast();
  List<Laptop>? _cachedLaptops;
  String _searchQuery = '';
  String? _selectedCategoryId;
  double? _minPrice;
  double? _maxPrice;
  String _sortCriterion = 'none';
  bool _isLoading = false;
  String? _error;

  StreamSubscription? _laptopSubscription;

  LaptopProvider() {
    fetchLaptops();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;

  Stream<List<Laptop>> getLaptopsStream() {
    if (_cachedLaptops != null) {
      
      return Stream.value(_cachedLaptops!).asBroadcastStream()
        ..listen((_) {}); 
    }
    return _laptopsController.stream;
  }

  List<Laptop>? getLaptops() => _cachedLaptops;

  Future<void> fetchLaptops() async {
    
    if (_cachedLaptops != null && _cachedLaptops!.isNotEmpty) {
      final filteredLaptops = _applyFilters(_cachedLaptops!);
      _laptopsController.add(filteredLaptops);
    }

    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final initialLaptops = await _laptopService.getAllLaptops();
      _cachedLaptops = initialLaptops;
      final filteredLaptops = _applyFilters(initialLaptops);
      _laptopsController.add(filteredLaptops);

      _laptopService.getLaptops().listen(
        (laptops) {
          _cachedLaptops = laptops;
          final filteredLaptops = _applyFilters(laptops);
          _laptopsController.add(filteredLaptops);
        },
        onError: (e) {
          _error = e.toString();
          _laptopsController.addError(e);
          notifyListeners();
        },
      );
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
    _cachedLaptops = null;
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
    _cachedLaptops = null;
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
    _cachedLaptops = null;
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
    if (_cachedLaptops != null) {
      final filteredLaptops = _applyFilters(_cachedLaptops!);
      _laptopsController.add(filteredLaptops);
    } else {
      fetchLaptops();
    }
  }

  void setSelectedCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    if (_cachedLaptops != null) {
      final filteredLaptops = _applyFilters(_cachedLaptops!);
      _laptopsController.add(filteredLaptops);
    } else {
      fetchLaptops();
    }
  }

  void setPriceRange(double? min, double? max) {
    _minPrice = min;
    _maxPrice = max;
    if (_cachedLaptops != null) {
      final filteredLaptops = _applyFilters(_cachedLaptops!);
      _laptopsController.add(filteredLaptops);
    } else {
      fetchLaptops();
    }
  }

  void setSortCriterion(String criterion) {
    _sortCriterion = criterion;
    if (_cachedLaptops != null) {
      final filteredLaptops = _applyFilters(_cachedLaptops!);
      _laptopsController.add(filteredLaptops);
    } else {
      fetchLaptops();
    }
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategoryId = null;
    _minPrice = null;
    _maxPrice = null;
    _sortCriterion = 'none';
    if (_cachedLaptops != null) {
      final filteredLaptops = _applyFilters(_cachedLaptops!);
      _laptopsController.add(filteredLaptops);
    } else {
      fetchLaptops();
    }
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
