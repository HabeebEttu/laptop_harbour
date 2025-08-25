import 'package:flutter/material.dart';
import 'package:laptop_harbour/models/order.dart';
import 'package:laptop_harbour/pages/admin/admin_order_details_page.dart';
import 'package:laptop_harbour/services/order_service.dart';
import 'package:laptop_harbour/widgets/order_card.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'processing':
        return Icons.sync;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  List<Order> _filterOrders(List<Order> orders) {
    List<Order> filteredOrders = orders;

    // Apply status filter
    if (_selectedFilter != 'All') {
      filteredOrders = filteredOrders
          .where((order) => order.status.toLowerCase() == _selectedFilter.toLowerCase())
          .toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filteredOrders = filteredOrders
          .where((order) =>
              order.orderId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              order.status.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return filteredOrders;
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search orders by ID or status...',
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled'];
    
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          
          return Container(
            margin: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              backgroundColor: Colors.grey[200],
              selectedColor: Theme.of(context).primaryColor,
              elevation: isSelected ? 4 : 1,
              pressElevation: 2,
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order, bool isTablet) {
    return OrderCard(order: order, isAdmin: true);
  }

  Widget _buildMobileLayout(Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Order #${order.orderId}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(order.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getStatusColor(order.status).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getStatusIcon(order.status),
                    size: 14,
                    color: _getStatusColor(order.status),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    order.status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(order.status),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\${order.totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Row(
              children: [
                Text(
                  'View Details',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabletLayout(Order order) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order #${order.orderId}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '\${order.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _getStatusColor(order.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getStatusColor(order.status).withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getStatusIcon(order.status),
                  size: 16,
                  color: _getStatusColor(order.status),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    order.status,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(order.status),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Theme.of(context).primaryColor,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _selectedFilter != 'All'
                ? 'No orders match your criteria'
                : 'No orders found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedFilter != 'All'
                ? 'Try adjusting your search or filter'
                : 'Orders will appear here when customers place them',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isNotEmpty || _selectedFilter != 'All') ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedFilter = 'All';
                  _searchController.clear();
                });
              },
              child: const Text('Clear Filters'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Unable to load orders. Please check your connection and try again.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                // Trigger rebuild to retry
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Orders',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 2,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: StreamBuilder<List<Order>>(
        stream: OrderService().getAllOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading orders...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Column(
              children: [
                _buildSearchBar(),
                _buildFilterChips(),
                const SizedBox(height: 20),
                Expanded(child: _buildEmptyState()),
              ],
            );
          }

          final filteredOrders = _filterOrders(snapshot.data!);
          final isTablet = MediaQuery.of(context).size.width > 600;

          return Column(
            children: [
              _buildSearchBar(),
              _buildFilterChips(),
              const SizedBox(height: 16),
              if (filteredOrders.isEmpty)
                Expanded(child: _buildEmptyState())
              else
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return _buildOrderCard(order, isTablet);
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}