import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laptop_harbour/models/order.dart';

class OrderDetailsPage extends StatelessWidget {
  final Order order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Order Tracking',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Order ID: ',
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
                Text(
                  'LH-${order.orderId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.file_upload_outlined),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 18, color: Colors.black54),
                const SizedBox(width: 4),
                const Text(
                  'Estimated Delivery: ',
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
                Text(
                  DateFormat('MMMM dd, yyyy').format(
                    order.estimatedDeliveryDate ??
                        DateTime.now().add(const Duration(days: 7)),
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildProgressPoint(
                    'Confirmed',
                    Icons.check_circle_outline,
                    isCompleted: true,
                    isFirst: true,
                  ),
                  _buildProgressLine(true),
                  _buildProgressPoint(
                    'Packed',
                    Icons.inventory_2_outlined,
                    isCompleted: true,
                  ),
                  _buildProgressLine(true),
                  _buildProgressPoint(
                    'Shipped',
                    Icons.local_shipping_outlined,
                    isCompleted:
                        order.status == 'Shipped' ||
                        order.status == 'Delivered',
                  ),
                  _buildProgressLine(order.status == 'Delivered'),
                  _buildProgressPoint(
                    'Delivered',
                    Icons.home_outlined,
                    isCompleted: order.status == 'Delivered',
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              height: 48,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.support_agent, color: Colors.white),
                label: const Text(
                  'Contact Support',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(height: 24),
            // Bottom navigation icons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBottomNavItem(Icons.home_outlined),
                  _buildBottomNavItem(Icons.favorite_border),
                  _buildBottomNavItem(Icons.shopping_cart_outlined),
                  _buildBottomNavItem(Icons.settings_outlined),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressPoint(
    String label,
    IconData icon, {
    bool isCompleted = false,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final color = isCompleted ? Colors.blue : Colors.grey.shade300;
    final labelColor = isCompleted ? Colors.blue : Colors.grey;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(bool isCompleted) {
    return Expanded(
      child: Container(
        height: 2,
        color: isCompleted ? Colors.blue : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon) {
    return IconButton(
      icon: Icon(icon, size: 28, color: Colors.grey.shade600,
      ),
      onPressed: () {},
    );
  }
}
