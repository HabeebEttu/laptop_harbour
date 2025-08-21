import 'package:flutter/material.dart';
import 'package:laptop_harbour/models/order.dart';
import 'package:laptop_harbour/models/profile.dart';
import 'package:laptop_harbour/services/admin_service.dart';
import 'package:laptop_harbour/providers/auth_provider.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _adminService = AdminService();
  AuthProvider _authProvider;
  AuthProvider get authProvider => _authProvider;

  bool _isAdmin = false;
  Map<String, dynamic>? _dashboardStats;
  List<Profile> _users = [];
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  AdminProvider(this._authProvider) {
    _authProvider.addListener(_onAuthStateChanged);
    _onAuthStateChanged();
  }

  void updateAuth(AuthProvider auth) {
    if (_authProvider != auth) {
      _authProvider.removeListener(_onAuthStateChanged);
      _authProvider = auth;
      _authProvider.addListener(_onAuthStateChanged);
      _onAuthStateChanged();
    }
  }

  bool get isAdmin => _isAdmin;
  Map<String, dynamic>? get dashboardStats => _dashboardStats;
  List<Profile> get users => _users;
  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _onAuthStateChanged() async {
    if (_authProvider.user != null) {
      await checkAdminStatus();
      if (_isAdmin) {
        listenToUsers();
        listenToOrders();
        fetchDashboardStats();
      }
    } else {
      _isAdmin = false;
      _users = [];
      _orders = [];
      _dashboardStats = null;
      notifyListeners();
    }
  }
  getUser(String uid) async {
    

  }
  Future<void> checkAdminStatus() async {
    if (_authProvider.user == null) return;
    _isAdmin = await _adminService.isAdmin(_authProvider.user!.uid);
    notifyListeners();
  }

  void listenToUsers() {
    _adminService.getAllUsers().listen(
      (users) {
        _users = users;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Error fetching users: $error';
        notifyListeners();
      },
    );
  }

  void listenToOrders() {
    _adminService.getAllOrders().listen(
      (orders) {
        _orders = orders;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Error fetching orders: $error';
        notifyListeners();
      },
    );
  }

  Future<void> fetchDashboardStats() async {
    try {
      _isLoading = true;
      notifyListeners();

      _dashboardStats = await _adminService.getDashboardStats();
      _error = null;
    } catch (e) {
      _error = 'Error fetching dashboard stats: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserRole(String uid, String role) async {
    try {
      await _adminService.updateUserRole(uid, role);
      _error = null;
    } catch (e) {
      _error = 'Error updating user role: $e';
      notifyListeners();
    }
  }

  Future<void> updateUserStatus(String uid, bool isBlocked) async {
    try {
      await _adminService.updateUserStatus(uid, isBlocked);
      _error = null;
    } catch (e) {
      _error = 'Error updating user status: $e';
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(
    String orderId,
    String userId,
    String status, {
    String? trackingNumber,
    String? courierService,
    DateTime? estimatedDeliveryDate,
  }) async {
    try {
      await _adminService.updateOrderStatus(
        orderId,
        userId,
        status,
        trackingNumber: trackingNumber,
        courierService: courierService,
        estimatedDeliveryDate: estimatedDeliveryDate,
      );
      _error = null;
    } catch (e) {
      _error = 'Error updating order status: $e';
      notifyListeners();
    }
  }

  Future<void> deleteOrder(String orderId, String userId) async {
    try {
      await _adminService.deleteOrder(orderId, userId);
      _error = null;
    } catch (e) {
      _error = 'Error deleting order: $e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthStateChanged);
    super.dispose();
  }
}
