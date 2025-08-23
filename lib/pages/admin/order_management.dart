import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laptop_harbour/models/order.dart';
import 'package:laptop_harbour/providers/admin_provider.dart';
import 'package:laptop_harbour/services/admin_service.dart';
import 'package:provider/provider.dart';

class OrderManagementPage extends StatefulWidget {
  const OrderManagementPage({super.key});

  @override
  State<OrderManagementPage> createState() => _OrderManagementPageState();
}

class _OrderManagementPageState extends State<OrderManagementPage> {
  final AdminService _adminService = AdminService();
  String _selectedStatus = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _statusFilters = [
    'All',
    'Pending',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Order Management',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (!adminProvider.isAdmin) {
            return Center(
              child: Card(
                margin: const EdgeInsets.all(24),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Access Denied',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You do not have permission to access this page',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Column(
            children: [
              // Search and Filter Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText:
                            'Search by order ID, customer name, or email...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Status Filter
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _statusFilters.length,
                        itemBuilder: (context, index) {
                          final status = _statusFilters[index];
                          final isSelected = _selectedStatus == status;

                          return Padding(
                            padding: EdgeInsets.only(
                              right: index < _statusFilters.length - 1 ? 8 : 0,
                            ),
                            child: FilterChip(
                              label: Text(
                                status,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : null,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : null,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedStatus = status;
                                });
                              },
                              selectedColor: Theme.of(context).primaryColor,
                              checkmarkColor: Colors.white,
                              backgroundColor: Colors.grey[200],
                              side: BorderSide.none,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Orders List
              Expanded(
                child: StreamBuilder<List<Order>>(
                  stream: _adminService.getAllOrders(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Loading orders...'),
                          ],
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Card(
                          margin: const EdgeInsets.all(24),
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red[300],
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Something went wrong',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'An error occurred while fetching orders. Please try again later.',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () => setState(() {}),
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No orders found',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Orders will appear here when customers place them',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      );
                    }

                    // Filter orders
                    List<Order> filteredOrders = snapshot.data!;

                    // Status filter
                    if (_selectedStatus != 'All') {
                      filteredOrders = filteredOrders
                          .where((order) => order.status == _selectedStatus)
                          .toList();
                    }

                    // Search filter
                    if (_searchQuery.isNotEmpty) {
                      filteredOrders = filteredOrders.where((order) {
                        final orderId = order.orderId.toLowerCase();
                        final customerName =
                            '${order.shippingAddress['firstName'] ?? ''} ${order.shippingAddress['lastName'] ?? ''}'
                                .toLowerCase();
                        final email = (order.shippingAddress['email'] ?? '')
                            .toLowerCase();

                        return orderId.contains(_searchQuery) ||
                            customerName.contains(_searchQuery) ||
                            email.contains(_searchQuery);
                      }).toList();
                    }

                    if (filteredOrders.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No matching orders found',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your search or filters',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        setState(() {});
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];
                          return _buildOrderCard(
                            order,
                            adminProvider,
                            isTablet,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(
    Order order,
    AdminProvider adminProvider,
    bool isTablet,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.orderId.substring(0, 8)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat(
                        'MMM dd, yyyy • hh:mm a',
                      ).format(order.orderDate),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor(order.status).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      order.status,
                      style: TextStyle(
                        color: _getStatusColor(order.status),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    NumberFormat.currency(
                      locale: 'en_US',
                      symbol: '₦',
                    ).format(order.totalPrice),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          children: [_buildOrderDetails(order, adminProvider, isTablet)],
        ),
      ),
    );
  }

  Widget _buildOrderDetails(
    Order order,
    AdminProvider adminProvider,
    bool isTablet,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Customer Information
        _buildSectionHeader('Customer Information', Icons.person_outline),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildInfoRow(
                'Name',
                '${order.shippingAddress['firstName'] ?? ''} ${order.shippingAddress['lastName'] ?? ''}',
                Icons.account_circle_outlined,
              ),
              const Divider(height: 24),
              _buildInfoRow(
                'Email',
                order.shippingAddress['email'] ?? 'N/A',
                Icons.email_outlined,
              ),
              const Divider(height: 24),
              _buildInfoRow(
                'Phone',
                order.shippingAddress['phone'] ?? 'N/A',
                Icons.phone_outlined,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Order Items
        _buildSectionHeader('Order Items', Icons.shopping_cart_outlined),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: order.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == order.items.length - 1;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: isLast
                      ? null
                      : Border(bottom: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.laptop,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.item.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Quantity: ${item.quantity}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      NumberFormat.currency(
                        locale: 'en_US',
                        symbol: '₦',
                      ).format(item.item.price * item.quantity),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 24),

        // Status Update Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.update, color: Theme.of(context).primaryColor),
              const SizedBox(width: 12),
              const Text(
                'Update Status:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButton<String>(
                  value: order.status,
                  underline: const SizedBox(),
                  items: _statusFilters
                      .where((status) => status != 'All')
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(
                            status,
                            style: TextStyle(
                              color: _getStatusColor(status),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (newStatus) async {
                    if (newStatus != null && newStatus != order.status) {
                      _showUpdateConfirmation(
                        context,
                        order,
                        newStatus,
                        adminProvider,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  void _showUpdateConfirmation(
    BuildContext context,
    Order order,
    String newStatus,
    AdminProvider adminProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Update Order Status'),
        content: Text(
          'Are you sure you want to change the status from "${order.status}" to "$newStatus"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await adminProvider.updateOrderStatus(
                order.orderId,
                order.userId,
                newStatus,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Order status updated to $newStatus'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Processing':
        return Colors.blue;
      case 'Shipped':
        return Colors.purple;
      case 'Delivered':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
