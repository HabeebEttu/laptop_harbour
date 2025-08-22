import 'dart:async';

import 'package:flutter/material.dart';
import 'package:laptop_harbour/models/laptop.dart';
import 'package:laptop_harbour/models/review.dart';
import 'package:laptop_harbour/services/laptop_service.dart';
import 'package:laptop_harbour/services/review_service.dart';

class LaptopProvider with ChangeNotifier {
  final LaptopService _laptopService = LaptopService();
  final ReviewService _reviewService = ReviewService(); // New: ReviewService instance
  final _filteredLaptopsController = StreamController<List<Laptop>>.broadcast();

  List<Laptop> _allLaptops = [];
  List<Laptop> _filteredLaptops =
      []; // Add this to track current filtered state
  String _searchQuery = '';
  String? _selectedCategoryId;
  double? _minPrice;
  double? _maxPrice;
  String _sortCriterion = 'none';
  bool _isLoading = false;
  String? _error;

  StreamSubscription? _laptopSubscription;

  LaptopProvider() {
    clearFilters(); // Clear all filters on initialization
    _fetchAndListenToLaptops();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  List<Laptop> get filteredLaptops =>
      _filteredLaptops; 

  bool get hasActiveFilters {
    return _searchQuery.isNotEmpty ||
        _selectedCategoryId != null ||
        _minPrice != null ||
        _maxPrice != null ||
        _sortCriterion != 'none';
  } 

  Stream<List<Laptop>> getLaptopsStream() {
    if (_filteredLaptops.isNotEmpty && !_isLoading) {
      _filteredLaptopsController.add(_filteredLaptops);
    }
    return _filteredLaptopsController.stream;
  }

  Future<List<Laptop>> getLaptopsList() async {
    // If we already have data and not loading, return immediately
    if (_allLaptops.isNotEmpty) {
      _applyFilters();
      return _filteredLaptops;
    }

    // Otherwise wait for the data to load
    if (_isLoading) {
      // Wait for loading to complete
      final completer = Completer<List<Laptop>>();

      void listener() {
        if (!_isLoading) {
          removeListener(listener);
          if (_error != null) {
            completer.completeError(_error!);
          } else {
            _applyFilters();
            completer.complete(_filteredLaptops);
          }
        }
      }

      addListener(listener);
      return completer.future;
    }

    // This should not happen if the provider is initialized correctly
    return [];
  }

  void _fetchAndListenToLaptops() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _laptopSubscription?.cancel();
    _laptopSubscription = _laptopService.getLaptops().listen(
      (laptops) {
        debugPrint('Received ${laptops.length} laptops from service');
        _allLaptops = laptops;
        _isLoading = false;
        _error = null; // Clear any previous errors
        _applyFilters();
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Error in laptop stream: $e');
        _error = e.toString();
        _isLoading = false;

        // Don't add error to stream controller immediately
        // Let the UI handle it through the provider state
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!_filteredLaptopsController.isClosed) {
            _filteredLaptopsController.addError(e);
          }
        });

        notifyListeners();
      },
      onDone: () {
        debugPrint('Laptop stream completed');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void _applyFilters() {
    List<Laptop> filteredLaptops = List.from(_allLaptops);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredLaptops = filteredLaptops.where((laptop) {
        final query = _searchQuery.toLowerCase();
        return laptop.title.toLowerCase().contains(query) ||
            laptop.brand.toLowerCase().contains(query) == true;
        // ||laptop.description?.toLowerCase().contains(query) == true;
      }).toList();
    }

    // Apply category filter
    if (_selectedCategoryId != null && _selectedCategoryId!.isNotEmpty) {
      filteredLaptops = filteredLaptops
          .where((laptop) => laptop.categoryId == _selectedCategoryId)
          .toList();
    }

    // Apply price range filter
    if (_minPrice != null && _maxPrice != null) {
      filteredLaptops = filteredLaptops
          .where(
            (laptop) =>
                laptop.price >= _minPrice! && laptop.price <= _maxPrice!,
          )
          .toList();
    }

    // Apply stock filter (only show laptops with stock > 0)
    filteredLaptops = filteredLaptops.where((laptop) => laptop.stockAmount > 0).toList();


    // Apply sorting
    switch (_sortCriterion) {
      case 'price_asc':
        filteredLaptops.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        filteredLaptops.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating':
        filteredLaptops.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'name':
        filteredLaptops.sort((a, b) => a.title.compareTo(b.title));
        break;
      default:
        // Keep original order
        break;
    }

    _filteredLaptops = filteredLaptops;

    // Add to stream controller if not closed
    if (!_filteredLaptopsController.isClosed) {
      _filteredLaptopsController.add(_filteredLaptops);
    }

    debugPrint(
      'Applied filters: ${_filteredLaptops.length} laptops after filtering',
    );
  }

  Future<void> addLaptop(Laptop laptop) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _laptopService.createLaptop(laptop);
      // Don't refetch immediately, let the stream handle updates
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateLaptop(String id, Laptop laptop) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _laptopService.updateLaptop(id, laptop);
      // Don't refetch immediately, let the stream handle updates
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteLaptop(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _laptopService.deleteLaptop(id);
      // Don't refetch immediately, let the stream handle updates
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      _applyFilters();
      notifyListeners(); // Notify listeners of the change
    }
  }

  void setSelectedCategory(String? categoryId) {
    if (_selectedCategoryId != categoryId) {
      _selectedCategoryId = categoryId;
      _applyFilters();
      notifyListeners(); // Notify listeners of the change
    }
  }

  void setPriceRange(double? min, double? max) {
    if (_minPrice != min || _maxPrice != max) {
      _minPrice = min;
      _maxPrice = max;
      _applyFilters();
      notifyListeners(); // Notify listeners of the change
    }
  }

  void setSortCriterion(String criterion) {
    if (_sortCriterion != criterion) {
      _sortCriterion = criterion;
      _applyFilters();
      notifyListeners(); // Notify listeners of the change
    }
  }

  void clearFilters() {
    bool hasChanges =
        _searchQuery.isNotEmpty ||
        _selectedCategoryId != null ||
        _minPrice != null ||
        _maxPrice != null ||
        _sortCriterion != 'none';

    if (hasChanges) {
      _searchQuery = '';
      _selectedCategoryId = null;
      _minPrice = null;
      _maxPrice = null;
      _sortCriterion = 'none';
      _applyFilters();
      notifyListeners();
    }
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  void refresh() {
    _fetchAndListenToLaptops();
  }

  Stream<List<Review>> getReviewsForLaptop(String laptopId) {
    return _reviewService.getReviews(laptopId);
  }

  Future<int> getReviewCountForLaptop(String laptopId) {
    return _reviewService.getReviewCount(laptopId);
  }

  @override
  void dispose() {
    debugPrint('Disposing LaptopProvider');
    _laptopSubscription?.cancel();
    _filteredLaptopsController.close();
    super.dispose();
  }
}
