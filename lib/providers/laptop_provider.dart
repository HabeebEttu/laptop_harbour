import 'package:flutter/material.dart';
import 'package:laptop_harbour/models/laptop.dart';
import 'package:laptop_harbour/models/specs.dart';
import 'package:laptop_harbour/services/laptop_service.dart';

class LaptopProvider with ChangeNotifier {
  final LaptopService _laptopService = LaptopService();
  List<Laptop> _laptops = [];
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

  LaptopProvider() {
    _laptops = [
      Laptop(
        id: '1',
        title: 'HP Spectre x360',
        brand: 'HP',
        price: 1299.99,
        image: 'assets/images/laptop1.jpg',
        categoryId: 'premium',
        rating: 4.8,
        tags: ['premium', 'convertible', 'oled'],
        reviews: [],
        specs: Specs(
          processor: 'Intel Core i7-1165G7',
          ram: '16GB DDR4',
          storage: '1TB NVMe SSD',
          display: '13.3" 4K UHD OLED',
          graphicsCard: 'Intel Iris Xe Graphics',
        ),
      ),
      Laptop(
        id: '2',
        title: 'Dell XPS 15',
        brand: 'Dell',
        price: 1799.99,
        image: 'assets/images/laptop2.jpg',
        categoryId: 'premium',
        rating: 4.9,
        tags: ['premium', 'powerful', '4k'],
        reviews: [],
        specs: Specs(
          processor: 'Intel Core i9-11900H',
          ram: '32GB DDR4',
          storage: '2TB NVMe SSD',
          display: '15.6" 4K UHD+ OLED',
          graphicsCard: 'NVIDIA GeForce RTX 3050 Ti',
        ),
      ),
      Laptop(
        id: '3',
        title: 'MacBook Air M2',
        brand: 'Apple',
        price: 1199.00,
        image: 'assets/images/laptop3.jpg',
        categoryId: 'ultraportable',
        rating: 4.9,
        tags: ['ultraportable', 'm2', 'retina'],
        reviews: [],
        specs: Specs(
          processor: 'Apple M2',
          ram: '8GB unified memory',
          storage: '256GB SSD',
          display: '13.6" Liquid Retina display',
          graphicsCard: 'Apple 8-core GPU',
        ),
      ),
    ];
  }

  Stream<List<Laptop>> getLaptopsStream() {
    return Stream.value(_laptops);
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
