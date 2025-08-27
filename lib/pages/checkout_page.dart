import 'package:laptop_harbour/models/cart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:laptop_harbour/pages/address_page.dart';
import 'package:laptop_harbour/providers/cart_provider.dart';
import 'package:laptop_harbour/providers/order_provider.dart';
import 'package:laptop_harbour/providers/user_provider.dart';
import 'package:provider/provider.dart';
// Custom exception for payment-related errors.
class PaymentException implements Exception {
  final String message;
  PaymentException(this.message);

  @override
  String toString() => 'PaymentException: $message';
}

class CheckoutPage extends StatefulWidget {
  final Cart? cart;
  const CheckoutPage({super.key, this.cart});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // form controllers
  final _nameController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();

  // form focus nodes for better navigation
  final _nameFocus = FocusNode();
  final _streetFocus = FocusNode();
  final _cityFocus = FocusNode();
  final _stateFocus = FocusNode();
  final _zipFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _cardNumberFocus = FocusNode();
  final _expiryDateFocus = FocusNode();
  final _cvvFocus = FocusNode();

  bool sameAsShipping = true;
  String paymentMethod = 'card';
  bool _isLoading = false;
  bool _isFormValid = false;

  NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: '₦',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();


    _addFormListeners();
  }

  void _addFormListeners() {
    final controllers = [
      _nameController,
      _streetController,
      _cityController,
      _stateController,
      _zipController,
      _phoneController,
      _cardNumberController,
      _expiryDateController,
      _cvvController,
    ];

    for (final controller in controllers) {
      controller.addListener(_validateForm);
    }
  }

  void _validateForm() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

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
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();

    // Dispose controllers
    _nameController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _phoneController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();

    // dispose focus nodes
    _nameFocus.dispose();
    _streetFocus.dispose();
    _cityFocus.dispose();
    _stateFocus.dispose();
    _zipFocus.dispose();
    _phoneFocus.dispose();
    _cardNumberFocus.dispose();
    _expiryDateFocus.dispose();
    _cvvFocus.dispose();

    super.dispose();
  }

  Future<void> _placeOrder() async {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar('Please fill in all required fields correctly.');
      return;
    }

    
    HapticFeedback.mediumImpact();

    final confirmed = await _showConfirmationDialog();
    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      
      await _simulatePayment();

      
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final nameParts = _nameController.text.trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final shippingAddress = {
        'firstName': firstName,
        'lastName': lastName,
        'email': userProvider.userProfile?.email ?? '',
        'street': _streetController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'zipCode': _zipController.text.trim(),
        'phone': _phoneController.text.trim(),
      };

      // 3. Place the order - Use listen: false to avoid rebuild issues
      if (!mounted) return;
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final cart = widget.cart ?? cartProvider.cart!;
      await orderProvider.placeOrder(cart, shippingAddress);
      if (!mounted) return;
      HapticFeedback.heavyImpact();

  
      if (widget.cart == null) {
        cartProvider.clearCart();
      }

      await _showSuccessDialog();

      // navigate after all operations are complete
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/orders');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool?> _showConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Order'),
        content: const Text('Are you sure you want to place this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSuccessDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Order Placed Successfully!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'You will receive a confirmation email shortly.',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('View Orders'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _simulatePayment() async {
    await Future.delayed(const Duration(seconds: 2));
    
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Consumer<CartProvider>(
      
      builder: (context, cartProvider, child) {
        final cart = widget.cart ?? cartProvider.cart;
        final theme = Theme.of(context);
        if (cart == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Checkout')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final subtotal = cart.totalPrice;
        const shipping = 0.0;
        final tax = subtotal * 0.07;
        final total = subtotal + shipping + tax;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text('Checkout'),
            centerTitle: true,
            elevation: 0,
            backgroundColor: theme.appBarTheme.backgroundColor,
            foregroundColor: theme.appBarTheme.foregroundColor,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: Stack(
              children: [
                // Main content
                SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.all(isTablet ? 24 : 16),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: AbsorbPointer(
                      absorbing: _isLoading,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isTablet ? 800 : double.infinity,
                        ),
                        child: Column(
                          children: [
                            // Shipping Information
                            _buildSection(
                              title: 'Shipping Information',
                              icon: Icons.local_shipping_outlined,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _nameController,
                                    focusNode: _nameFocus,
                                    decoration: _inputDecoration('Full Name *'),
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (_) => FocusScope.of(
                                      context,
                                    ).requestFocus(_streetFocus),
                                    validator: (v) => v?.trim().isEmpty ?? true
                                        ? 'Please enter full name'
                                        : null,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _streetController,
                                    focusNode: _streetFocus,
                                    decoration: _inputDecoration(
                                      'Street Address *',
                                    ),
                                    textInputAction: TextInputAction.next,
                                    onFieldSubmitted: (_) => FocusScope.of(
                                      context,
                                    ).requestFocus(_cityFocus),
                                    validator: (v) => v?.trim().isEmpty ?? true
                                        ? 'Please enter street address'
                                        : null,
                                  ),
                                  const SizedBox(height: 12),
                                  if (isTablet)
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: TextFormField(
                                            controller: _cityController,
                                            focusNode: _cityFocus,
                                            decoration: _inputDecoration(
                                              'City *',
                                            ),
                                            textInputAction:
                                                TextInputAction.next,
                                            onFieldSubmitted: (_) =>
                                                FocusScope.of(
                                                  context,
                                                ).requestFocus(_stateFocus),
                                            validator: (v) =>
                                                v?.trim().isEmpty ?? true
                                                ? 'Please enter city'
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _stateController,
                                            focusNode: _stateFocus,
                                            decoration: _inputDecoration(
                                              'State *',
                                            ),
                                            textInputAction:
                                                TextInputAction.next,
                                            onFieldSubmitted: (_) =>
                                                FocusScope.of(
                                                  context,
                                                ).requestFocus(_zipFocus),
                                            validator: (v) =>
                                                v?.trim().isEmpty ?? true
                                                ? 'Enter state'
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _zipController,
                                            focusNode: _zipFocus,
                                            decoration: _inputDecoration(
                                              'Zip Code *',
                                            ),
                                            keyboardType: TextInputType.number,
                                            textInputAction:
                                                TextInputAction.next,
                                            onFieldSubmitted: (_) =>
                                                FocusScope.of(
                                                  context,
                                                ).requestFocus(_phoneFocus),
                                            validator: (v) =>
                                                v?.trim().isEmpty ?? true
                                                ? 'Enter zip code'
                                                : null,
                                          ),
                                        ),
                                      ],
                                    )
                                  else ...[
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: _cityController,
                                            focusNode: _cityFocus,
                                            decoration: _inputDecoration(
                                              'City *',
                                            ),
                                            textInputAction:
                                                TextInputAction.next,
                                            onFieldSubmitted: (_) =>
                                                FocusScope.of(
                                                  context,
                                                ).requestFocus(_stateFocus),
                                            validator: (v) =>
                                                v?.trim().isEmpty ?? true
                                                ? 'Please enter city'
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        SizedBox(
                                          width: 100,
                                          child: TextFormField(
                                            controller: _stateController,
                                            focusNode: _stateFocus,
                                            decoration: _inputDecoration(
                                              'State *',
                                            ),
                                            textInputAction:
                                                TextInputAction.next,
                                            onFieldSubmitted: (_) =>
                                                FocusScope.of(
                                                  context,
                                                ).requestFocus(_zipFocus),
                                            validator: (v) =>
                                                v?.trim().isEmpty ?? true
                                                ? 'Enter state'
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: _zipController,
                                            focusNode: _zipFocus,
                                            decoration: _inputDecoration(
                                              'Zip Code *',
                                            ),
                                            keyboardType: TextInputType.number,
                                            textInputAction:
                                                TextInputAction.next,
                                            onFieldSubmitted: (_) =>
                                                FocusScope.of(
                                                  context,
                                                ).requestFocus(_phoneFocus),
                                            validator: (v) =>
                                                v?.trim().isEmpty ?? true
                                                ? 'Enter zip code'
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _phoneController,
                                            focusNode: _phoneFocus,
                                            decoration: _inputDecoration(
                                              'Phone *',
                                            ),
                                            keyboardType: TextInputType.phone,
                                            textInputAction:
                                                TextInputAction.done,
                                            validator: (v) =>
                                                v?.trim().isEmpty ?? true
                                                ? 'Enter phone number'
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (isTablet) ...[
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: _phoneController,
                                      focusNode: _phoneFocus,
                                      decoration: _inputDecoration(
                                        'Phone Number *',
                                      ),
                                      keyboardType: TextInputType.phone,
                                      textInputAction: TextInputAction.done,
                                      validator: (v) =>
                                          v?.trim().isEmpty ?? true
                                          ? 'Enter phone number'
                                          : null,
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () async {
                                        final selectedAddress =
                                            await Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const AddressPage(),
                                              ),
                                            );

                                        if (selectedAddress != null &&
                                            selectedAddress is Address) {
                                          _streetController.text =
                                              selectedAddress.line1;
                                          _cityController.text =
                                              selectedAddress.city;
                                          _stateController.text =
                                              selectedAddress.state;
                                          _zipController.text =
                                              selectedAddress.zip;
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.location_on_outlined,
                                      ),
                                      label: const Text(
                                        'Change or Add Address',
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Billing Information
                            _buildSection(
                              title: 'Billing Information',
                              icon: Icons.receipt_outlined,
                              child: SwitchListTile(
                                title: const Text(
                                  'Same as Shipping Address',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                value: sameAsShipping,
                                onChanged: (val) =>
                                    setState(() => sameAsShipping = val),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),

                            // Payment Method
                            _buildSection(
                              title: 'Payment Method',
                              icon: Icons.payment_outlined,
                              child: Column(
                                children: [
                                  _buildPaymentOption(
                                    'card',
                                    'Credit/Debit Card',
                                    Icons.credit_card,
                                  ),
                                  if (paymentMethod == 'card') ...[
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _cardNumberController,
                                      focusNode: _cardNumberFocus,
                                      decoration: _inputDecoration(
                                        'Card Number *',
                                        hint: '1234 5678 9012 3456',
                                      ),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(16),
                                      ],
                                      textInputAction: TextInputAction.next,
                                      onFieldSubmitted: (_) => FocusScope.of(
                                        context,
                                      ).requestFocus(_expiryDateFocus),
                                      validator: (v) {
                                        if (v?.trim().isEmpty ?? true) {
                                          return 'Please enter card number';
                                        }
                                        if (v!.length != 16) {
                                          return 'Please enter a valid 16-digit card number';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: _expiryDateController,
                                            focusNode: _expiryDateFocus,
                                            decoration: _inputDecoration(
                                              'MM/YY *',
                                              hint: '12/25',
                                            ),
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              _ExpiryDateFormatter(),
                                            ],
                                            textInputAction:
                                                TextInputAction.next,
                                            onFieldSubmitted: (_) =>
                                                FocusScope.of(
                                                  context,
                                                ).requestFocus(_cvvFocus),
                                            validator: (v) {
                                              if (v?.trim().isEmpty ?? true) {
                                                return 'Please enter expiry date';
                                              }
                                              if (!RegExp(
                                                r'^\d{2}\/\d{2}$',
                                              ).hasMatch(v!)) {
                                                return 'Please enter a valid MM/YY date';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _cvvController,
                                            focusNode: _cvvFocus,
                                            decoration: _inputDecoration(
                                              'CVV *',
                                              hint: '123',
                                            ),
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                              LengthLimitingTextInputFormatter(
                                                3,
                                              ),
                                            ],
                                            textInputAction:
                                                TextInputAction.done,
                                            validator: (v) {
                                              if (v?.trim().isEmpty ?? true) {
                                                return 'Please enter CVV';
                                              }
                                              if (v!.length != 3) {
                                                return 'Please enter a valid 3-digit CVV';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  _buildPaymentOption(
                                    'upi',
                                    'UPI',
                                    Icons.account_balance,
                                  ),
                                  _buildPaymentOption(
                                    'paypal',
                                    'PayPal',
                                    Icons.payment,
                                  ),
                                ],
                              ),
                            ),

                            // Order Summary
                            _buildSection(
                              title: 'Order Summary',
                              icon: Icons.receipt_long_outlined,
                              child: Column(
                                children: [
                                  _summaryRow(
                                    'Subtotal',
                                    currencyFormatter.format(subtotal),
                                  ),
                                  _summaryRow(
                                    'Shipping',
                                    shipping == 0
                                        ? 'Free'
                                        : currencyFormatter.format(shipping),
                                  ),
                                  _summaryRow(
                                    'Estimated Tax',
                                    currencyFormatter.format(tax),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Divider(),
                                  ),
                                  _summaryRow(
                                    'Total',
                                    currencyFormatter.format(total),
                                    isBold: true,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 100,
                            ), 
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Loading overlay
                if (_isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'Processing your order...',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Bottom place order button
          bottomNavigationBar: SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: _isFormValid && !_isLoading
                      ? Colors.blue.shade700
                      : Colors.grey.shade400,
                  elevation: _isFormValid && !_isLoading ? 2 : 0,
                ),
                onPressed: _isLoading || !_isFormValid ? null : _placeOrder,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isLoading) ...[
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Processing...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ] else ...[
                      Icon(
                        Icons.lock_outline,
                        size: 20,
                        color: _isFormValid
                            ? Colors.white
                            : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${currencyFormatter.format(total)} • Place Order',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isFormValid
                              ? Colors.white
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentOption(String value, String title, IconData icon) {
    final isSelected = paymentMethod == value;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Colors.blue.shade600 : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isSelected ? Colors.blue.shade50 : Colors.transparent,
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: paymentMethod,
        onChanged: (val) => setState(() => paymentMethod = val!),
        title: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.blue.shade600 : Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.blue.shade600 : Colors.grey.shade800,
              ),
            ),
          ],
        ),
        activeColor: Colors.blue.shade600,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
              color: isBold ? Colors.grey.shade800 : Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontSize: isBold ? 16 : 14,
              color: isBold ? Colors.grey.shade800 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom text input formatter for expiry date (MM/YY format)
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var newText = newValue.text;

    // Remove any non-digit characters except for a single '/'
    newText = newText.replaceAll(RegExp(r'[^\d/]'), '');

    // Ensure there's only one slash
    final parts = newText.split('/');
    if (parts.length > 2) {
      newText = '${parts[0]}/${parts[1]}';
    }

    // Add '/' after two digits if not already present
    if (newText.length == 2 && !newText.contains('/')) {
      newText = '$newText/';
    }

    // Limit total length to 5 (MM/YY)
    if (newText.length > 5) {
      newText = newText.substring(0, 5);
    }

    // Adjust cursor position
    var selectionIndex = newText.length;
    if (newValue.selection.end > newText.length) {
      selectionIndex = newText.length;
    } else {
      selectionIndex = newValue.selection.end;
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
