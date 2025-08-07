import 'package:flutter/material.dart';
import 'package:laptop_harbour/models/order.dart';
import 'package:laptop_harbour/services/order_service.dart';
import 'package:laptop_harbour/providers/auth_provider.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();
  List<Order> _orders = [];
  AuthProvider _authProvider;

  List<Order> get orders => _orders;

  OrderProvider(this._authProvider) {
    _authProvider.addListener(_onAuthStateChanged);
    _onAuthStateChanged(); // Initial check
  }

  void _onAuthStateChanged() async {
    if (_authProvider.user != null) {
      await fetchOrders(_authProvider.user!.uid);
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

  Future<void> fetchOrders(String userId) async {
    _orders = (await _orderService.getUserOrders(userId)).cast<Order>();
    notifyListeners();
  }

  Future<void> placeOrder(Order order) async {
    if (_authProvider.user == null) return;
    try {
      await _orderService.placeOrder(_authProvider.user!.uid, order);
      await fetchOrders(_authProvider.user!.uid); // Re-fetch orders to update state
    } catch (e) {
      debugPrint('Error placing order in OrderProvider: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthStateChanged);
    super.dispose();
  }
}
