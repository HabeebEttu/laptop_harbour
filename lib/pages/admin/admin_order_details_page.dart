
import 'package:flutter/material.dart';
import 'package:laptop_harbour/models/order.dart';
import 'package:laptop_harbour/services/order_service.dart';

class AdminOrderDetailsPage extends StatefulWidget {
  final Order order;

  const AdminOrderDetailsPage({super.key, required this.order});

  @override
  State<AdminOrderDetailsPage> createState() => _AdminOrderDetailsPageState();
}

class _AdminOrderDetailsPageState extends State<AdminOrderDetailsPage> {
  late String _selectedStatus;
  final _trackingNumberController = TextEditingController();
  final _courierServiceController = TextEditingController();
  final OrderService _orderService = OrderService();

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.order.status;
    _trackingNumberController.text = widget.order.trackingNumber ?? '';
    _courierServiceController.text = widget.order.courierService ?? '';
  }

  @override
  void dispose() {
    _trackingNumberController.dispose();
    _courierServiceController.dispose();
    super.dispose();
  }

  void _updateOrder() async {
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
        const SnackBar(content: Text('Order updated successfully!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update order: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: \${widget.order.orderId}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('User ID: \${widget.order.userId}'),
            const SizedBox(height: 8),
            Text('Order Date: \${widget.order.orderDate}'),
            const SizedBox(height: 8),
            Text('Total Price: \$\${widget.order.totalPrice.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...widget.order.items.map((cartItem) {
              final laptop = cartItem.item;
              return ListTile(
                title: Text(laptop.title),
                subtitle: Text('Quantity: \${cartItem.quantity}'),
                trailing: Text('\$\${(laptop.price * cartItem.quantity).toStringAsFixed(2)}'),
              );
            }),
            const SizedBox(height: 16),
            const Text('Shipping Address:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
                '${widget.order.shippingAddress['street']}\n${widget.order.shippingAddress['city']}, ${widget.order.shippingAddress['state']} ${widget.order.shippingAddress['zipCode']}\n${widget.order.shippingAddress['country']}'),
            const SizedBox(height: 24),
            DropdownButton<String>(
              value: _selectedStatus,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStatus = newValue!;
                });
              },
              items: <String>['Processing', 'Shipped', 'Delivered', 'Cancelled']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            if (_selectedStatus == 'Shipped') ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _trackingNumberController,
                decoration: const InputDecoration(labelText: 'Tracking Number'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _courierServiceController,
                decoration: const InputDecoration(labelText: 'Courier Service'),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateOrder,
                child: const Text('Update Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
