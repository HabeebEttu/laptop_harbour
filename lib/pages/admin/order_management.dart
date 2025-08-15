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

  final List<String> _statusFilters = [
    'All',
    'Pending',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Filter by Status',
                border: InputBorder.none,
              ),
              items: _statusFilters
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
            ),
          ),
        ),
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, child) {
          if (!adminProvider.isAdmin) {
            return const Center(
              child: Text('You do not have permission to access this page'),
            );
          }

          return StreamBuilder<List<Order>>(
            stream: _adminService.getAllOrders(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No orders found'));
              }

              final orders = _selectedStatus == 'All'
                  ? snapshot.data!
                  : snapshot.data!
                      .where((order) => order.status == _selectedStatus)
                      .toList();

              return ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ExpansionTile(
                      title: Text('Order #${order.orderId.substring(0, 8)}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status: ${order.status}',
                            style: TextStyle(
                              color: _getStatusColor(order.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Date: ${DateFormat('MMM dd, yyyy').format(order.orderDate)}',
                          ),
                        ],
                      ),
                      trailing: Text(
                        NumberFormat.currency(
                          locale: 'en_US',
                          symbol: '₦',
                        ).format(order.totalPrice),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Customer Information',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('Name: ${order.shippingAddress['firstName'] ?? ''} ${order.shippingAddress['lastName'] ?? ''}'),
                              Text('Email: ${order.shippingAddress['email'] ?? 'N/A'}'),
                              Text('Phone: ${order.shippingAddress['phone'] ?? 'N/A'}'),
                              const Divider(),
                              const Text(
                                'Order Items',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...order.items.map((item) => ListTile(
                                    title: Text(item.item.title),
                                    subtitle: Text('Quantity: ${item.quantity}'),
                                    trailing: Text(
                                      NumberFormat.currency(
                                        locale: 'en_US',
                                        symbol: '₦',
                                      ).format(item.item.price * item.quantity),
                                    ),
                                  )),
                              const Divider(),
                              Row(
                                children: [
                                  const Text(
                                    'Update Status:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 16),
                                  DropdownButton<String>(
                                    value: order.status,
                                    items: _statusFilters
                                        .where((status) => status != 'All')
                                        .map((status) => DropdownMenuItem(
                                              value: status,
                                              child: Text(status),
                                            ))
                                        .toList(),
                                    onChanged: (newStatus) async {
                                      if (newStatus != null) {
                                        await adminProvider.updateOrderStatus(
                                          order.orderId,
                                          order.userId,
                                          newStatus,
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
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