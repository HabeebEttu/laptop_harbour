import 'package:flutter/material.dart';
import 'package:laptop_harbour/providers/cart_provider.dart';
import 'package:laptop_harbour/providers/order_provider.dart';
import 'package:provider/provider.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'John Doe');
  final _streetController = TextEditingController(text: '123 Main Street');
  final _cityController = TextEditingController(text: 'Anytown');
  final _stateController = TextEditingController(text: 'CA');
  final _zipController = TextEditingController(text: '90210');
  final _phoneController = TextEditingController(text: '(555) 123-4567');

  bool sameAsShipping = true;
  String paymentMethod = 'card';

  @override
  void dispose() {
    _nameController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    final subtotal = 499.99;
    final shipping = 0.0;
    final tax = 35.0;
    final total = subtotal + shipping + tax;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Shipping Information
              _buildSection(
                title: 'Shipping Information',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration('Full Name'),
                      validator: (v) =>
                          v!.isEmpty ? 'Please enter full name' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _streetController,
                      decoration: _inputDecoration('Street Address'),
                      validator: (v) =>
                          v!.isEmpty ? 'Please enter street address' : null,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _cityController,
                            decoration: _inputDecoration('City'),
                            validator: (v) =>
                                v!.isEmpty ? 'Please enter city' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 80,
                          child: TextFormField(
                            controller: _stateController,
                            decoration: _inputDecoration('State'),
                            validator: (v) => v!.isEmpty ? 'Enter state' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _zipController,
                            decoration: _inputDecoration('Zip Code'),
                            validator: (v) =>
                                v!.isEmpty ? 'Enter zip code' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            decoration: _inputDecoration('Phone Number'),
                            validator: (v) =>
                                v!.isEmpty ? 'Enter phone number' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text('Change or Add Address'),
                    ),
                  ],
                ),
              ),

              // Billing Information
              _buildSection(
                title: 'Billing Information',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Same as Shipping',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Switch(
                      value: sameAsShipping,
                      onChanged: (val) => setState(() => sameAsShipping = val),
                    ),
                  ],
                ),
              ),

              // Payment Method
              _buildSection(
                title: 'Payment Method',
                child: Column(
                  children: [
                    RadioListTile(
                      value: 'card',
                      groupValue: paymentMethod,
                      onChanged: (val) =>
                          setState(() => paymentMethod = val.toString()),
                      title: const Text('Credit/Debit Card'),
                    ),
                    if (paymentMethod == 'card')
                      Column(
                        children: [
                          TextFormField(
                            decoration: _inputDecoration(
                              'Card Number',
                            ).copyWith(hintText: '**** **** **** 1234'),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  decoration: _inputDecoration('MM/YY'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  decoration: _inputDecoration('CVV'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    RadioListTile(
                      value: 'upi',
                      groupValue: paymentMethod,
                      onChanged: (val) =>
                          setState(() => paymentMethod = val.toString()),
                      title: const Text('UPI'),
                    ),
                    RadioListTile(
                      value: 'paypal',
                      groupValue: paymentMethod,
                      onChanged: (val) =>
                          setState(() => paymentMethod = val.toString()),
                      title: const Text('PayPal'),
                    ),
                  ],
                ),
              ),

              // Order Summary
              _buildSection(
                title: 'Order Summary',
                child: Column(
                  children: [
                    _summaryRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
                    _summaryRow(
                      'Shipping',
                      shipping == 0 ? 'Free' : '\$$shipping',
                    ),
                    _summaryRow('Estimated Tax', '\$${tax.toStringAsFixed(2)}'),
                    const Divider(),
                    _summaryRow(
                      'Total',
                      '\$${total.toStringAsFixed(2)}',
                      isBold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80), // space for bottom button
            ],
          ),
        ),
      ),

      // Bottom place order button
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              backgroundColor: Colors.blue.shade700,
            ),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final shippingAddress = {
                  'name': _nameController.text,
                  'street': _streetController.text,
                  'city': _cityController.text,
                  'state': _stateController.text,
                  'zipCode': _zipController.text,
                  'phone': _phoneController.text,
                };

                

                await orderProvider.placeOrder(
                  cartProvider.cart!,
                  shippingAddress,
                );
                await cartProvider.clearCart();

                if (!context.mounted) return;
                Navigator.of(context).popUntil((route) => route.isFirst);
                if (!context.mounted) return;
                Navigator.of(context).pushNamed('/orders');
              }
            },
            child: Text(
              '\$${total.toStringAsFixed(2)} • Place Your Order',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
