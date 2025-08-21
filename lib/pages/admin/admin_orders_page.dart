import 'package:flutter/material.dart';
import 'package:laptop_harbour/models/order.dart';
import 'package:laptop_harbour/pages/order_details_page.dart';
import 'package:laptop_harbour/services/order_service.dart';

class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
      ),
      body: StreamBuilder<List<Order>>(
        stream: OrderService().getAllOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('An error occurred while fetching orders. Please try again later.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          final orders = snapshot.data!;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Order ID: ${order.orderId}'),
                  subtitle: Text('Status: ${order.status}'),
                  trailing: Text('Total: \$${order.totalPrice.toStringAsFixed(2)}'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                                                builder: (context) => OrderDetailsPage(order: order),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}