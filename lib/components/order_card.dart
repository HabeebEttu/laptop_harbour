import 'package:flutter/material.dart';
class OrderCard extends StatelessWidget {
  const OrderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section with order number and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order LH-2024-001234',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
              _StatusBadge(text: 'Delivered', color: Colors.green),
            ],
          ),
          SizedBox(height: 12.0),

          // Order details section with placed date and total
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16.0, color: Colors.grey),
              SizedBox(width: 8.0),
              Text('Placed 1/20/2024', style: TextStyle(color: Colors.grey)),
              Spacer(),
              Icon(Icons.credit_card, size: 16.0, color: Colors.grey),
              SizedBox(width: 8.0),
              Text('Total \$2399.00', style: TextStyle(color: Colors.grey)),
            ],
          ),
          SizedBox(height: 20.0),

          // Buttons section
          Row(
            children: [
              Expanded(
                child: _CustomButton(
                  icon: Icons.remove_red_eye_outlined,
                  text: 'View Details',
                ),
              ),
              SizedBox(width: 10.0),
              Expanded(
                child: _CustomButton(icon: Icons.sync, text: 'Track'),
              ),
            ],
          ),
          SizedBox(height: 20.0),

          // Item details section
          _OrderItem(
            imageUrl: 'assets/images/laptop1.jpg',
            productName: 'MacBook Pro 16-...',
            vendor: 'Apple',
            sku: 'MBP16-M3PRO-18GB-512',
            price: '\$2,399',
            quantity: '1',
          ),
          SizedBox(height: 20.0),

          // Order progress section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order Progress',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
              Text(
                'Delivered',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0),
          _CustomProgressBar(
            progress: 1.0, // Progress of 1.0 represents 100% (delivered)
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: color, size: 16.0),
          const SizedBox(width: 6.0),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomButton extends StatelessWidget {
  final IconData icon;
  final String text;

  const _CustomButton({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        // Handle button press
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black87,
        side: const BorderSide(color: Colors.black12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20.0),
          const SizedBox(width: 8.0),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _OrderItem extends StatelessWidget {
  final String imageUrl;
  final String productName;
  final String vendor;
  final String sku;
  final String price;
  final String quantity;

  const _OrderItem({
    required this.imageUrl,
    required this.productName,
    required this.vendor,
    required this.sku,
    required this.price,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.asset(
            imageUrl,
            width: 80.0,
            height: 80.0,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                productName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.0,
                ),
              ),
              Text(vendor, style: const TextStyle(color: Colors.grey)),
              Text('SKU: $sku', style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              price,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            Text('Qty: $quantity', style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ],
    );
  }
}

class _CustomProgressBar extends StatelessWidget {
  final double progress;
  final Color color;

  const _CustomProgressBar({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: color.withOpacity(0.1),
        valueColor: AlwaysStoppedAnimation<Color>(color),
        minHeight: 10.0,
      ),
    );
  }
}
