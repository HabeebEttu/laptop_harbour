import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:laptop_harbour/pages/address_page.dart';
import 'package:laptop_harbour/providers/cart_provider.dart';
import 'package:laptop_harbour/providers/order_provider.dart';
import 'package:laptop_harbour/providers/user_provider.dart';
import 'package:provider/provider.dart';

/// Custom exception for payment-related errors.
class PaymentException implements Exception {
  final String message;
  PaymentException(this.message);

  @override
  String toString() => 'PaymentException: $message';
}

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();

  bool sameAsShipping = true;
  String paymentMethod = 'card';
  bool _isLoading = false;
  NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: '₦',
    decimalDigits: 2,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userProfile = userProvider.userProfile;
    if (userProfile != null) {
      _nameController.text =
          '${userProfile.firstName} ${userProfile.lastName}';
      _streetController.text = userProfile.address ?? '';
      _cityController.text = userProfile.city ?? '';
      _stateController.text = userProfile.country ?? '';
      _zipController.text = userProfile.postalCode ?? '';
      _phoneController.text = userProfile.phoneNumber;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _phoneController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Order'),
        content: const Text('Are you sure you want to place this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Simulate payment
      await _simulatePayment();

      // 2. Prepare shipping address
      final shippingAddress = {
        'name': _nameController.text,
        'street': _streetController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'zipCode': _zipController.text,
        'phone': _phoneController.text,
      };

      // 3. Place the order
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      await orderProvider.placeOrder(
        cartProvider.cart!,
        shippingAddress,
      );

      // 4. Show success message and navigate
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order placed successfully!')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
      if (!context.mounted) return;
      Navigator.of(context).pushNamed('/orders');
    } on PaymentException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment Failed: ${e.message}')),
      );
    } on PlatformException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Network Error: ${e.message ?? 'Please check your connection.'}')),
      );
    } catch (e) {
      // Handle other errors
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _simulatePayment() async {
    // Simulate a network call to a payment gateway
    await Future.delayed(const Duration(seconds: 2));
    // In a real app, this would come from a payment gateway SDK.
    // For demonstration, we'll randomly throw an error.
    if (DateTime.now().second % 2 != 0) {
      // Fail roughly 50% of the time
      throw PaymentException('Insufficient funds.');
    }
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
    final cart = cartProvider.cart;

    if (cart == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final subtotal = cart.totalPrice;
    const shipping = 0.0;
    final tax = subtotal * 0.07; // 7% tax
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: AbsorbPointer(
                absorbing: _isLoading,
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
                            validator: (v) => v!.isEmpty
                                ? 'Please enter street address'
                                : null,
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
                                  validator: (v) =>
                                      v!.isEmpty ? 'Enter state' : null,
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
                            onPressed: () async {
                              final selectedAddress =
                                  await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const AddressPage(),
                                ),
                              );

                              if (selectedAddress != null &&
                                  selectedAddress is Address) {
                                _streetController.text = selectedAddress.line1;
                                _cityController.text = selectedAddress.city;
                                _stateController.text = selectedAddress.state;
                                _zipController.text = selectedAddress.zip;
                              }
                            },
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
                            onChanged: (val) =>
                                setState(() => sameAsShipping = val),
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
                            onChanged: (val) => setState(
                                () => paymentMethod = val.toString()),
                            title: const Text('Credit/Debit Card'),
                          ),
                          if (paymentMethod == 'card')
                            Column(
                              children: [
                                TextFormField(
                                  controller: _cardNumberController,
                                  decoration: _inputDecoration(
                                    'Card Number',
                                  ).copyWith(hintText: '**** **** **** 1234'),
                                  validator: (v) {
                                    if (v!.isEmpty) {
                                      return 'Please enter card number';
                                    }
                                    if (!RegExp(r'^\d{16}$').hasMatch(v)) {
                                      return 'Please enter a valid 16-digit card number';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _expiryDateController,
                                        decoration: _inputDecoration('MM/YY'),
                                        validator: (v) {
                                          if (v!.isEmpty) {
                                            return 'Please enter expiry date';
                                          }
                                          if (!RegExp(r'^\d{2}\/\d{2}$')
                                              .hasMatch(v)) {
                                            return 'Please enter a valid MM/YY date';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _cvvController,
                                        decoration: _inputDecoration('CVV'),
                                        validator: (v) {
                                          if (v!.isEmpty) {
                                            return 'Please enter CVV';
                                          }
                                          if (!RegExp(r'^\d{3}$')
                                              .hasMatch(v)) {
                                            return 'Please enter a valid 3-digit CVV';
                                          }
                                          return null;
                                        },
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
                          _summaryRow(
                              'Subtotal', currencyFormatter.format(subtotal)),
                          _summaryRow(
                            'Shipping',
                            shipping == 0 ? 'Free' : '\$shipping',
                          ),
                          _summaryRow(
                              'Estimated Tax', currencyFormatter.format(tax)),
                          const Divider(),
                          _summaryRow(
                            'Total',
                            currencyFormatter.format(total),
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
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
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
            onPressed: _isLoading ? null : _placeOrder,
            child: Text(
              '${currencyFormatter.format(total)} • Place Your Order',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
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