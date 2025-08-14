import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laptop_harbour/models/order.dart';

class OrderDetailsPage extends StatelessWidget {
  final Order order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.orderId.substring(0, 8)}',style: TextStyle(fontWeight: FontWeight.w800),),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildSummaryRow('Order Date', DateFormat.yMMMd().format(order.orderDate)),
            _buildSummaryRow('Total Price', '\$${order.totalPrice.toStringAsFixed(2)}'),
            _buildSummaryRow('Status', order.status),
            if (order.trackingNumber != null)
              _buildSummaryRow('Tracking Number', order.trackingNumber!),
            if (order.courierService != null)
              _buildSummaryRow('Courier', order.courierService!),
            const SizedBox(height: 24),
            const Text(
              'Shipping Address',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${order.shippingAddress['street']}\n${order.shippingAddress['city']}, ${order.shippingAddress['state']} ${order.shippingAddress['zipCode']}\n${order.shippingAddress['country']}',
            ),
            const SizedBox(height: 24),
            const Text(
              'Items',
              style: TextStyle(fontSize: 18,fontWeight:FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...order.items.map((cartItem) {
              final laptop = cartItem.item;
              return ListTile(
                leading: Image.network(laptop.image, width: 50, height: 50, fit: BoxFit.cover),
                title: Text(laptop.title),
                subtitle: Text('Quantity: ${cartItem.quantity}'),
                trailing: Text('\$${(laptop.price * cartItem.quantity).toStringAsFixed(2)}'),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
