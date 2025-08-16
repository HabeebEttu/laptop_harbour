import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laptop_harbour/models/order.dart';
import 'package:laptop_harbour/providers/auth_provider.dart';
import 'package:laptop_harbour/services/order_service.dart';
import 'package:provider/provider.dart';

class OrderDetailsPage extends StatelessWidget {
  final Order order;
  const OrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return StreamBuilder<Order>(
      stream: OrderService().getOrderStream(authProvider.user!.uid, order.orderId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('Order not found.')),
          );
        }

        final updatedOrder = snapshot.data!;
        final estimatedDelivery = updatedOrder.estimatedDeliveryDate != null
            ? DateFormat.yMMMd().format(updatedOrder.estimatedDeliveryDate!)
            : 'Not available';

        final List<String> steps = [
          'Pending',
          'Processing',
          'Shipped',
          'Delivered',
          'Cancelled'
        ];
        int currentStep = steps.indexOf(updatedOrder.status);

        return Scaffold(
          appBar: AppBar(
            title: const Text("Order Tracking"),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.shopping_bag, color: Colors.blue, size: 28),
                            const SizedBox(width: 10),
                            Text(
                              "Order #${updatedOrder.orderId.substring(0, 8)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Estimated Delivery: $estimatedDelivery",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.support_agent),
                            label: const Text("Contact Support"),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.local_shipping,
                              color: Colors.blue,
                              size: 28,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Order Progress",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ...List.generate(steps.length, (index) {
                          return buildStep(
                            context,
                            steps[index],
                            index <= currentStep,
                            isLast: index == steps.length - 1 || index >= currentStep,
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildStep(BuildContext context, String title, bool completed, {required bool isLast}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(
              completed ? Icons.check_circle : Icons.radio_button_unchecked,
              color: completed ? Theme.of(context).primaryColor : Colors.grey,
              size: 28,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: completed ? Theme.of(context).primaryColor : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: completed ? FontWeight.bold : FontWeight.normal,
                  color: completed ? Colors.black : Colors.grey,
                ),
          ),
        ),
      ],
    );
  }
}