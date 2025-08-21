import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laptop_harbour/models/order.dart';
import 'package:laptop_harbour/providers/admin_provider.dart';
import 'package:laptop_harbour/providers/user_provider.dart';
import 'package:laptop_harbour/services/order_service.dart';
import 'package:provider/provider.dart';

class AdminOrderDetailsPage extends StatefulWidget {
  final Order order; // Replace with your Order model

  const AdminOrderDetailsPage({super.key, required this.order});

  @override
  State<AdminOrderDetailsPage> createState() => _AdminOrderDetailsPageState();
}

class _AdminOrderDetailsPageState extends State<AdminOrderDetailsPage>
    with SingleTickerProviderStateMixin {
  late String _selectedStatus;
  final _trackingNumberController = TextEditingController();
  final _courierServiceController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;

  final OrderService _orderService = OrderService();

  final Map<String, Color> _statusColors = {
    'Processing': Colors.orange,
    'Shipped': Colors.blue,
    'Delivered': Colors.green,
    'Cancelled': Colors.red,
  };

  final Map<String, IconData> _statusIcons = {
    'Processing': Icons.hourglass_empty,
    'Shipped': Icons.local_shipping,
    'Delivered': Icons.check_circle,
    'Cancelled': Icons.cancel,
  };

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.order.status ?? 'Processing';
    _trackingNumberController.text = widget.order.trackingNumber ?? '';
    _courierServiceController.text = widget.order.courierService ?? '';

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _trackingNumberController.dispose();
    _courierServiceController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _updateOrder() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {

      
      await _orderService.updateOrderStatus(
        widget.order.userId,
        widget.order.orderId,
        _selectedStatus,
        trackingNumber: _trackingNumberController.text,
        courierService: _courierServiceController.text,
      );
      

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Order updated successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Failed to update order: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Order Details'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            onPressed: () {
              // Handle print functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Print functionality coming soon'),
                ),
              );
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Header Card
              _buildOrderHeaderCard(),
              const SizedBox(height: 16),

              // Customer Info Card
              _buildCustomerInfoCard(),
              const SizedBox(height: 16),

              // Order Items Card
              _buildOrderItemsCard(),
              const SizedBox(height: 16),

              // Shipping Address Card
              _buildShippingAddressCard(),
              const SizedBox(height: 16),

              // Order Status Management Card
              _buildStatusManagementCard(),
              const SizedBox(height: 24),

              // Update Button
              _buildUpdateButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderHeaderCard() {
    final status = _selectedStatus;
    final statusColor = _statusColors[status] ?? Colors.grey;
    final statusIcon = _statusIcons[status] ?? Icons.info;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              statusColor.withOpacity(0.1),
              statusColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${widget.order.orderId}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Status: $status',
                        style: TextStyle(
                          fontSize: 14,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(
                      ClipboardData(text: widget.order.orderId),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Order ID copied to clipboard'),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.copy,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Order Date',
                    widget.order.orderDate.toString() ,
                    Icons.calendar_today,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Total Amount',
                    '\$${widget.order.totalPrice.toStringAsFixed(2)}',
                    Icons.attach_money,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Customer Information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Customer ID', widget.order.userId),
            const SizedBox(height: 8),
            _buildInfoRow('Email', Provider.of<AdminProvider>(context).getUser(widget.order.userId).profile.email),
            const SizedBox(height: 8),
            _buildInfoRow('Phone', Provider.of<AdminProvider>(context).getUser(widget.order.userId).profile.phoneNumber),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Order Items',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Sample items - replace with your actual order items
            ...List.generate(
              2,
              (index) => _buildOrderItem(
                'Sample Laptop ${index + 1}',
                1,
                1299.99 + (index * 200),
              ),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${widget.order.totalPrice?.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(String title, int quantity, double price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
              Icons.laptop_mac,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Qty: $quantity',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${(price * quantity).toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingAddressCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Shipping Address',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.order.shippingAddress?['name'] ?? 'Customer Name',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.order.shippingAddress?['street'] ?? '123 Sample Street'}\n${widget.order.shippingAddress?['city'] ?? 'Sample City'}, ${widget.order.shippingAddress?['state'] ?? 'ST'} ${widget.order.shippingAddress?['zipCode'] ?? '12345'}\n${widget.order.shippingAddress?['country'] ?? 'Country'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withOpacity(0.8),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusManagementCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings_outlined,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Order Management',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Status Dropdown
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<String>(
                value: _selectedStatus,
                isExpanded: true,
                underline: const SizedBox.shrink(),
                icon: const Icon(Icons.keyboard_arrow_down),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedStatus = newValue!;
                  });
                },
                items: ['Processing', 'Shipped', 'Delivered', 'Cancelled']
                    .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            Icon(
                              _statusIcons[value],
                              color: _statusColors[value],
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(value),
                          ],
                        ),
                      );
                    })
                    .toList(),
              ),
            ),

            // Shipping Details (show only if status is "Shipped")
            if (_selectedStatus == 'Shipped') ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _trackingNumberController,
                decoration: InputDecoration(
                  labelText: 'Tracking Number',
                  prefixIcon: const Icon(Icons.track_changes),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _courierServiceController,
                decoration: InputDecoration(
                  labelText: 'Courier Service',
                  prefixIcon: const Icon(Icons.local_shipping),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _updateOrder,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.update),
        label: Text(_isLoading ? 'Updating...' : 'Update Order'),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Theme.of(context).primaryColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
