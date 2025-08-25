import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laptop_harbour/models/order.dart';
import 'package:laptop_harbour/providers/auth_provider.dart';
import 'package:laptop_harbour/services/order_service.dart';
import 'package:provider/provider.dart';

class AdminOrderDetailsPage extends StatefulWidget {
  final Order order;
  const AdminOrderDetailsPage({super.key, required this.order});

  @override
  State<AdminOrderDetailsPage> createState() => _AdminOrderDetailsPageState();
}

class _AdminOrderDetailsPageState extends State<AdminOrderDetailsPage> {
  late String _currentStatus;
  final _trackingNumberController = TextEditingController();
  final _courierServiceController = TextEditingController();
  DateTime? _estimatedDeliveryDate;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.order.status;
    _trackingNumberController.text = widget.order.trackingNumber ?? '';
    _courierServiceController.text = widget.order.courierService ?? '';
    _estimatedDeliveryDate = widget.order.estimatedDeliveryDate;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return StreamBuilder<Order>(
      stream: OrderService().getOrderStream(
        widget.order.userId,
        widget.order.orderId,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading order details...'),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Order Details"),
              centerTitle: true,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading order',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Order Details"),
              centerTitle: true,
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text('Order not found'),
                ],
              ),
            ),
          );
        }

        final updatedOrder = snapshot.data!;
        _currentStatus = updatedOrder.status;
        _trackingNumberController.text = updatedOrder.trackingNumber ?? '';
        _courierServiceController.text = updatedOrder.courierService ?? '';
        _estimatedDeliveryDate = updatedOrder.estimatedDeliveryDate;
        final estimatedDelivery = updatedOrder.estimatedDeliveryDate != null
            ? DateFormat.yMMMd().format(updatedOrder.estimatedDeliveryDate!)
            : 'Not available';

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            title: const Text("Order Details"),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Theme.of(context).colorScheme.surface,
            surfaceTintColor: Colors.transparent,
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              // Force refresh the stream
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(isTablet ? 24 : 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isTablet ? 800 : double.infinity,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildOrderHeader(
                      context,
                      updatedOrder,
                      estimatedDelivery,
                      isTablet,
                    ),
                    const SizedBox(height: 20),
                    _buildOrderStatusDropdown(context, updatedOrder),
                    const SizedBox(height: 20),
                    _buildOrderProgress(context, updatedOrder, isTablet),
                    const SizedBox(height: 20),
                    _buildOrderItems(context, updatedOrder, isTablet),
                    const SizedBox(height: 20),
                    _buildDeliveryInfo(context, updatedOrder, isTablet),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderHeader(
    BuildContext context,
    Order order,
    String estimatedDelivery,
    bool isTablet,
  ) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.05),
              Theme.of(context).primaryColor.withOpacity(0.02),
            ],
          ),
        ),
        padding: EdgeInsets.all(isTablet ? 24 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.shopping_bag,
                    color: Theme.of(context).primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Order #${order.orderId.substring(0, 8)}",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildStatusChip(context, order.status),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, size: 20, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    "Estimated Delivery: $estimatedDelivery",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
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

  Widget _buildStatusChip(BuildContext context, String status) {
    Color getStatusColor(String status) {
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

    final color = getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildOrderProgress(BuildContext context, Order order, bool isTablet) {
    final List<String> steps = [
      'Pending',
      'Processing',
      'Shipped',
      'Delivered',
    ];
    int currentStep = steps.indexOf(order.status);

    // Handle cancelled orders
    if (order.status == 'Cancelled') {
      return _buildCancelledOrder(context, isTablet);
    }

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24 : 20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.local_shipping,
                    color: Theme.of(context).primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  "Order Progress",
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...List.generate(steps.length, (index) {
              return _buildStep(
                context,
                steps[index],
                index <= currentStep,
                isLast: index == steps.length - 1,
                isTablet: isTablet,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelledOrder(BuildContext context, bool isTablet) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.red.withOpacity(0.05),
              Colors.red.withOpacity(0.02),
            ],
          ),
        ),
        padding: EdgeInsets.all(isTablet ? 24 : 20),
        child: Column(
          children: [
            Icon(Icons.cancel, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              "Order Cancelled",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "This order has been cancelled. If you have any questions, please contact our support team.",
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(
    BuildContext context,
    String title,
    bool completed, {
    required bool isLast,
    required bool isTablet,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : (isTablet ? 24 : 20)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: completed
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                  border: Border.all(
                    color: completed
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: Icon(
                  completed ? Icons.check : Icons.circle,
                  color: completed ? Colors.white : Colors.grey.shade400,
                  size: 16,
                ),
              ),
              if (!isLast)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 2,
                  height: isTablet ? 40 : 32,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: completed
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: completed
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: completed ? Colors.black87 : Colors.grey.shade600,
                    ),
                  ),
                  if (completed && title == 'Shipped')
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Tracking number: LH${widget.order.orderId.substring(0, 6).toUpperCase()}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems(BuildContext context, Order order, bool isTablet) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.inventory_2,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  "Order Summary",
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildOrderItemsList(context, order),
            const SizedBox(height: 20),
            _buildPriceSummary(context, order),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsList(BuildContext context, Order order) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: order.items.length,
      separatorBuilder: (context, index) => Divider(
        color: Colors.grey.shade200,
        height: 20,
      ),
      itemBuilder: (context, index) {
        final item = order.items[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.item.image,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Qty: ${item.quantity}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                NumberFormat.currency(symbol: '₦')
                    .format(item.item.price * item.quantity),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPriceSummary(BuildContext context, Order order) {
    final subtotal = order.items.fold(
      0.0,
      (sum, item) => sum + (item.item.price * item.quantity),
    );
    final shipping = order.totalPrice > subtotal ? order.totalPrice - subtotal : 0.0;

    return Column(
      children: [
        const Divider(height: 20),
        _buildPriceRow('Subtotal', subtotal),
        const SizedBox(height: 8),
        _buildPriceRow('Shipping', shipping),
        const SizedBox(height: 8),
        const Divider(height: 20),
        _buildPriceRow(
          'Total',
          order.totalPrice,
          isTotal: true,
        ),
      ],
    );
  }

  Widget _buildPriceRow(String title, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 18 : 16,
            color: isTotal ? Colors.black : Colors.grey.shade700,
          ),
        ),
        Text(
          NumberFormat.currency(symbol: '₦').format(amount),
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 18 : 16,
            color: isTotal ? Colors.black : Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryInfo(BuildContext context, Order order, bool isTablet) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  "Delivery Address",
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${order.shippingAddress['firstName']}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${order.shippingAddress['street']},${order.shippingAddress['city']}, ${order.shippingAddress['state']} - ${order.shippingAddress['zipCode']}",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Contact: ${order.shippingAddress['phone']}",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusDropdown(BuildContext context, Order order) {
    final List<String> statusOptions = [
      'Pending',
      'Processing',
      'Shipped',
      'Delivered',
      'Cancelled'
    ];

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update Order Status',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _currentStatus,
              items: statusOptions.map((String status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _currentStatus = newValue;
                  });
                }
              },
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _trackingNumberController,
              decoration: const InputDecoration(
                labelText: 'Tracking Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _courierServiceController,
              decoration: const InputDecoration(
                labelText: 'Courier Service',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _estimatedDeliveryDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (selectedDate != null) {
                  setState(() {
                    _estimatedDeliveryDate = selectedDate;
                  });
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Estimated Delivery Date',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _estimatedDeliveryDate != null
                      ? DateFormat.yMMMd().format(_estimatedDeliveryDate!)
                      : 'Select a date',
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await OrderService().updateOrderStatus(
                      order.userId,
                      order.orderId,
                      _currentStatus,
                      trackingNumber: _trackingNumberController.text,
                      courierService: _courierServiceController.text,
                      estimatedDeliveryDate: _estimatedDeliveryDate,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Order status updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to update order status: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
