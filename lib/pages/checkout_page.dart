import 'package:flutter/material.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360; 

    return Scaffold(
      appBar: AppBar(title: const Text("Checkout"), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
          child: Column(
            children: [
              _buildCard(
                title: "Shipping Information",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      "Full Name",
                      "e.g. John Doe",
                      isSmallScreen,
                    ),
                    _buildTextField(
                      "Street Address",
                      "e.g. 123 Main St",
                      isSmallScreen,
                    ),
                    _buildTextField("City", "e.g. New York", isSmallScreen),
                    _buildTextField("State", "e.g. NY", isSmallScreen),
                    _buildTextField("ZIP Code", "e.g. 10001", isSmallScreen),
                    _buildTextField(
                      "Phone Number",
                      "e.g. +1 555 123 4567",
                      isSmallScreen,
                    ),
                  ],
                ),
              ),
              _buildCard(
                title: "Billing Information",
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Same as shipping address",
                      style: TextStyle(fontSize: 16),
                    ),
                    Switch(
                      value: true, // default ON
                      onChanged: (value) {
                        // handle toggle change here
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildCard(
                title: "Payment Card",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      "Cardholder Name",
                      "e.g. John Doe",
                      isSmallScreen,
                    ),
                    _buildTextField(
                      "Card Number",
                      "e.g. 1234 5678 9012 3456",
                      isSmallScreen,
                    ),
                    _buildTextField("Expiration Date", "MM/YY", isSmallScreen),
                    _buildTextField("CVV", "e.g. 123", isSmallScreen),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildCard(
                title: "Order Summary",
                child: Column(
                  children: [
                    _buildSummaryRow("Subtotal", "\$120.00"),
                    _buildSummaryRow("Shipping", "\$10.00"),
                    _buildSummaryRow("Estimated Tax", "\$8.50"),
                    const Divider(),
                    _buildSummaryRow("Total", "\$138.50", isTotal: true),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          // Place order action here
                        },
                        child: const Text(
                          "Place Your Order",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Card builder for sections
  static Widget _buildCard({required String title, required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  // Text field with label above
  static Widget _buildTextField(String label, String hint, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 13 : 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Row for order summary values
  static Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
