import 'package:flutter/material.dart';
import 'package:laptop_harbour/models/cart.dart';
import 'package:laptop_harbour/models/order.dart';
import 'package:laptop_harbour/services/order_service.dart';
import 'package:laptop_harbour/providers/auth_provider.dart';
import 'package:uuid/uuid.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();
  List<Order> _orders = [];
  AuthProvider _authProvider;
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  OrderProvider(this._authProvider) {
    _authProvider.addListener(_onAuthStateChanged);
    _onAuthStateChanged();
  }

  void _onAuthStateChanged() {
    if (_authProvider.user != null) {
      fetchOrders();
    } else {
      _orders = [];
      notifyListeners();
    }
  }

  void updateAuth(AuthProvider auth) {
    if (_authProvider != auth) {
      _authProvider.removeListener(_onAuthStateChanged);
      _authProvider = auth;
      _authProvider.addListener(_onAuthStateChanged);
      _onAuthStateChanged();
    }
  }

  Future<void> fetchOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    if (_authProvider.user != null) {
      debugPrint('Fetching orders for user ID: ${_authProvider.user!.uid}'); // Add this line
      _orderService.getUserOrders(_authProvider.user!.uid).listen((orders) {
        _orders = orders;
        _isLoading = false;
        _error = null;
        notifyListeners();
      }, onError: (e) {
        _isLoading = false;
        _error = e.toString();
        notifyListeners();
      });
    } else {
      _orders = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> placeOrder(Cart cart, Map<String, String> shippingAddress) async {
    if (_authProvider.user == null) {
      throw Exception('User is not logged in');
    }
    _isLoading = true;
    notifyListeners();

    try {
      final newOrder = Order(
        orderId: const Uuid().v4(),
        userId: _authProvider.user!.uid,
        items: cart.items,
        totalPrice: cart.totalPrice,
        orderDate: DateTime.now(),
        shippingAddress: shippingAddress,
      );

      await _orderService.placeOrder(newOrder, cart);
      await fetchOrders();
    } catch (e) {
      // Re-throw the exception to be caught by the UI
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, String status, {String? trackingNumber, String? courierService, DateTime? estimatedDeliveryDate}) async {
    if (_authProvider.user == null) {
      throw Exception('User is not logged in');
    }
    _isLoading = true;
    notifyListeners();
    try {
      await _orderService.updateOrderStatus(
        _authProvider.user!.uid,
        orderId,
        status,
        trackingNumber: trackingNumber,
        courierService: courierService,
        estimatedDeliveryDate: estimatedDeliveryDate,
      );
      // Optionally, refresh orders after update
      await fetchOrders();
    } catch (e) {
      // Handle error
      debugPrint('Error updating order status: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthStateChanged);
    super.dispose();
  }
}
