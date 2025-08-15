import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laptop_harbour/models/order.dart';
import 'package:laptop_harbour/pages/order_details_page.dart';
import 'package:provider/provider.dart';
import 'package:laptop_harbour/providers/order_provider.dart';


class OrderCard extends StatelessWidget {
  final Order order;
  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: r'₦',
      decimalDigits: 2,
    );
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OrderDetailsPage(order: order),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Order ID + Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Order ID: ${order.orderId.substring(0, 8)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                Text(
                  order.status,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Order date
            Row(
              children: [
                const Text(
                  "Order Date:",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const Spacer(),
                Text(
                  DateFormat.yMMMd().format(order.orderDate),
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Total
            Row(
              children: [
                const Text(
                  "Total:",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const Spacer(),
                Text(
                  currencyFormatter.format(order.totalPrice),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Items + Arrow
            Row(
              children: [
                const Text(
                  "Items:",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const Spacer(),
                Text(
                  "${order.items.length} items",
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OrdersList extends StatelessWidget {
  const OrdersList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        if (orderProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (orderProvider.orders.isEmpty) {
          return const Center(child: Text('You have no orders yet.'));
        }
        return ListView.builder(
          itemCount: orderProvider.orders.length,
          itemBuilder: (context, index) {
            final order = orderProvider.orders[index];
            return OrderCard(order: order);
          },
        );
      },
    );
  }
}
