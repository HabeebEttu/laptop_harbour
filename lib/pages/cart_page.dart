import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:laptop_harbour/components/bottom_nav_bar.dart';
import 'package:laptop_harbour/components/cart_item_card.dart';
import 'package:laptop_harbour/models/cart.dart';
import 'package:laptop_harbour/pages/checkout_page.dart';
import 'package:laptop_harbour/pages/home_page.dart';
import 'package:laptop_harbour/pages/orders_page.dart';
import 'package:laptop_harbour/pages/profile_page.dart';
import 'package:laptop_harbour/pages/wish_list.dart';
import 'package:laptop_harbour/providers/auth_provider.dart';
import 'package:laptop_harbour/providers/cart_provider.dart';
import 'package:laptop_harbour/providers/user_provider.dart';
import 'package:laptop_harbour/utils/responsive_text.dart';
import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with TickerProviderStateMixin {
  int _selectedIndex = 2;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadCartData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _loadCartData() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      if (authProvider.user != null) {
        await cartProvider.refreshCart(authProvider.user!.uid);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to load cart data. Please try again.');
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    // Add haptic feedback
    HapticFeedback.lightImpact();

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        _navigateWithTransition(const HomePage());
        break;
      case 1:
        _navigateWithTransition(const WishList());
        break;
      case 2:
        // Already on cart page
        break;
      case 3:
        _navigateWithTransition(const OrdersPage());
        break;
      case 4:
        _navigateWithTransition(const ProfilePage());
        break;
    }
  }

  void _navigateWithTransition(Widget page) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOutCubic,
                  ),
                ),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF121212)
          : const Color(0xFFFAFAFA),
      appBar: _buildAppBar(isDarkMode, isTablet),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                if (cartProvider.isLoading) {
                  return _buildLoadingState(isDarkMode);
                }

                final cart = cartProvider.cart;
                if (cart == null || cart.items.isEmpty) {
                  return _buildEmptyState(isDarkMode, isTablet);
                }

                return _buildCartContent(
                  cart,
                  isDarkMode,
                  isTablet,
                  cartProvider,
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDarkMode, bool isTablet) {
    return AppBar(
      title: FadeTransition(
        opacity: _fadeAnimation,
        child: Text(
          'Shopping Cart',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: isTablet ? 28 : 24,
          ),
        ),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: isDarkMode ? Colors.white : Colors.black87,
      centerTitle: false,
      systemOverlayStyle: isDarkMode
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      actions: [
        Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            final cart = cartProvider.cart;
            if (cart == null || cart.items.isEmpty) {
              return const SizedBox.shrink();
            }

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 16),
              child: IconButton(
                onPressed: () => _showClearCartDialog(context, cartProvider),
                icon: const Icon(Icons.delete_sweep_rounded),
                tooltip: 'Clear Cart',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.1),
                  foregroundColor: Colors.red.shade600,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoadingState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Loading your cart...',
            style: GoogleFonts.poppins(
              color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode, bool isTablet) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 32 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.elasticOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    padding: EdgeInsets.all(isTablet ? 40 : 32),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.withOpacity(0.1),
                          Colors.blue.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      size: isTablet ? 100 : 80,
                      color: Colors.blue.shade300,
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: isTablet ? 40 : 32),

            Text(
              'Your cart is empty',
              style: GoogleFonts.poppins(
                fontSize: isTablet ? 28 : 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),

            SizedBox(height: isTablet ? 16 : 12),

            Text(
              'Add some laptops to your cart\nto see them here',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: isTablet ? 18 : 16,
                color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                height: 1.4,
              ),
            ),

            SizedBox(height: isTablet ? 48 : 40),

            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                _navigateWithTransition(const HomePage());
              },
              icon: const Icon(Icons.shopping_bag_outlined),
              label: Text(
                'Start Shopping',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade400,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 40 : 32,
                  vertical: isTablet ? 20 : 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 8,
                shadowColor: Colors.blue.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent(
    Cart cart,
    bool isDarkMode,
    bool isTablet,
    CartProvider cartProvider,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        try {
          final authProvider = Provider.of<AuthProvider>(
            context,
            listen: false,
          );
          if (authProvider.user != null) {
            await cartProvider.refreshCart(authProvider.user!.uid);
          }
        } catch (e) {
          _showErrorSnackBar('Failed to refresh cart. Please try again.');
        }
      },
      color: Colors.blue.shade400,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Header Section
          SliverToBoxAdapter(
            child: _buildCartHeader(cart, isDarkMode, isTablet),
          ),

          // Cart Items
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final cartItem = cart.items[index];
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300 + (index * 50)),
                  curve: Curves.easeOutCubic,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: CartItemCard(cartItem: cartItem),
                  ),
                );
              }, childCount: cart.items.length),
            ),
          ),

          // Checkout Card
          SliverToBoxAdapter(child: CheckOutCard(cart: cart)),

          // Bottom spacing
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildCartHeader(Cart cart, bool isDarkMode, bool isTablet) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        isTablet ? 24 : 20,
        8,
        isTablet ? 24 : 20,
        16,
      ),
      padding: EdgeInsets.symmetric(
        vertical: isTablet ? 20 : 16,
        horizontal: isTablet ? 24 : 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
              : [Colors.white, const Color(0xFFF8F9FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 16 : 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.15),
                  Colors.blue.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.shopping_cart_rounded,
              color: Colors.blue.shade400,
              size: isTablet ? 28 : 24,
            ),
          ),
          SizedBox(width: isTablet ? 20 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Cart Items",
                  style: GoogleFonts.poppins(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: isTablet ? 6 : 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    "${cart.items.length} ${cart.items.length == 1 ? 'item' : 'items'}",
                    key: ValueKey(cart.items.length),
                    style: GoogleFonts.poppins(
                      fontSize: isTablet ? 24 : 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, CartProvider cartProvider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange.shade400,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Clear Cart',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to remove all items from your cart? This action cannot be undone.',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  Navigator.of(context).pop(); // Close dialog first
                  await cartProvider.clearCart();

                  if (mounted) {
                    HapticFeedback.heavyImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text('Cart cleared successfully'),
                          ],
                        ),
                        backgroundColor: Colors.red.shade400,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    _showErrorSnackBar(
                      'Failed to clear cart. Please try again.',
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Clear All',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}

class CheckOutCard extends StatefulWidget {
  final Cart cart;
  const CheckOutCard({super.key, required this.cart});

  @override
  State<CheckOutCard> createState() => _CheckOutCardState();
}

class _CheckOutCardState extends State<CheckOutCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final cartProvider = Provider.of<CartProvider>(context);

    final currencyFormatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '₦',
      decimalDigits: 2,
    );

    // Calculate totals more safely
    double subtotal = 0.0;
    try {
      subtotal = widget.cart.items.fold(
        0.0,
        (sum, item) => sum + (item.item.price * item.quantity),
      );
    } catch (e) {
      subtotal = 0.0;
    }

    const double taxRate = 0.08;
    final double tax = subtotal * taxRate;
    const double shipping = 0.0;
    final double total = subtotal + tax + shipping;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          margin: EdgeInsets.all(isTablet ? 24 : 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
                  : [Colors.white, const Color(0xFFF8F9FA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.4)
                    : Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
                spreadRadius: -4,
              ),
              BoxShadow(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.02)
                    : Colors.white.withOpacity(0.8),
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 28 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(isDarkMode, isTablet),

                SizedBox(height: isTablet ? 24 : 20),

                // Order Details
                _buildOrderDetails(
                  subtotal,
                  tax,
                  shipping,
                  currencyFormatter,
                  isDarkMode,
                ),

                SizedBox(height: isTablet ? 16 : 12),
                Divider(
                  color: isDarkMode
                      ? Colors.grey.shade700
                      : Colors.grey.shade300,
                  thickness: 1,
                ),
                SizedBox(height: isTablet ? 16 : 12),

                // Total
                _buildTotal(total, currencyFormatter, isDarkMode, isTablet),

                SizedBox(height: isTablet ? 32 : 24),

                // Action Buttons
                _buildActionButtons(
                  context,
                  cartProvider,
                  isDarkMode,
                  isTablet,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDarkMode, bool isTablet) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isTablet ? 12 : 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.withOpacity(0.15),
                Colors.blue.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.receipt_rounded,
            color: Colors.blue.shade400,
            size: isTablet ? 24 : 20,
          ),
        ),
        SizedBox(width: isTablet ? 16 : 12),
        Text(
          'Order Summary',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: isTablet ? 22 : 20,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderDetails(
    double subtotal,
    double tax,
    double shipping,
    NumberFormat formatter,
    bool isDarkMode,
  ) {
    return Column(
      children: [
        _buildOrderRow(
          'Subtotal (${widget.cart.items.length} items)',
          formatter.format(subtotal),
          isDarkMode,
        ),
        _buildOrderRow('Tax (8%)', formatter.format(tax), isDarkMode),
        _buildOrderRow('Shipping', 'FREE', isDarkMode, isShipping: true),
      ],
    );
  }

  Widget _buildTotal(
    double total,
    NumberFormat formatter,
    bool isDarkMode,
    bool isTablet,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Total',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: isTablet ? 20 : 18,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          formatter.format(total),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: isTablet ? 22 : 20,
            color: Colors.blue.shade400,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    CartProvider cartProvider,
    bool isDarkMode,
    bool isTablet,
  ) {
    if (isTablet) {
      return Row(
        children: [
          Expanded(flex: 2, child: _buildCheckoutButton(context, isDarkMode)),
          const SizedBox(width: 16),
          Expanded(
            child: _buildClearCartButton(context, cartProvider, isDarkMode),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          _buildCheckoutButton(context, isDarkMode),
          const SizedBox(height: 12),
          _buildClearCartButton(context, cartProvider, isDarkMode),
        ],
      );
    }
  }

  Widget _buildOrderRow(
    String label,
    String value,
    bool isDarkMode, {
    bool isShipping = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isShipping
                  ? Colors.green.shade400
                  : (isDarkMode ? Colors.white : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton(BuildContext context, bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isProcessing ? null : () => _handleCheckout(context),
        icon: _isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.lock_rounded, size: 20),
        label: Text(
          _isProcessing ? 'Processing...' : 'Secure Checkout',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade400,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: Colors.blue.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildClearCartButton(
    BuildContext context,
    CartProvider cartProvider,
    bool isDarkMode,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showClearCartDialog(context, cartProvider),
        icon: Icon(
          Icons.delete_outline_rounded,
          size: 20,
          color: Colors.red.shade400,
        ),
        label: Text(
          'Clear Cart',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.red.shade400,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: Colors.red.shade400),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Future<void> _handleCheckout(BuildContext context) async {
    setState(() {
      _isProcessing = true;
    });

    // Add haptic feedback
    HapticFeedback.mediumImpact();

    // Simulate processing delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      try {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const CheckoutPage(),
            transitionDuration: const Duration(milliseconds: 300),
            reverseTransitionDuration: const Duration(milliseconds: 200),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOutCubic,
                          ),
                        ),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
          ),
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('Failed to navigate to checkout. Please try again.'),
                ],
              ),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
      }
    }
  }

  void _showClearCartDialog(BuildContext context, CartProvider cartProvider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange.shade400,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Clear Cart',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to remove all items from your cart? This action cannot be undone.',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  Navigator.of(context).pop(); // Close dialog first

                  // Show loading indicator
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Clearing cart...'),
                          ],
                        ),
                        backgroundColor: Colors.blue.shade400,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.all(16),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }

                  await cartProvider.clearCart();

                  if (context.mounted) {
                    HapticFeedback.heavyImpact();

                    // Remove any existing snackbars
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text('Cart cleared successfully'),
                          ],
                        ),
                        backgroundColor: Colors.green.shade500,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.all(16),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    HapticFeedback.heavyImpact();

                    // Remove loading snackbar
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();

                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text('Failed to clear cart. Please try again.'),
                          ],
                        ),
                        backgroundColor: Colors.red.shade600,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Clear All',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}
