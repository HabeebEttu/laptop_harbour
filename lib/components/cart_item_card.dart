import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laptop_harbour/models/cart_item.dart';
import 'package:laptop_harbour/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class CartItemCard extends StatefulWidget {
  const CartItemCard({super.key, required this.cartItem});
  final CartItem cartItem;

  @override
  State<CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isUpdating = false;
  bool _isRemoving = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
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

    return Selector<CartProvider, CartItem?>(
      selector: (context, cartProvider) {
        if (cartProvider.cart?.items == null) return null;
        try {
          return cartProvider.cart!.items.firstWhere(
            (item) => item.item.id == widget.cartItem.item.id,
          );
        } catch (e) {
          return null; // Item was removed
        }
      },
      builder: (context, cartItem, child) {
        // If item is null, it means it was removed - don't render anything
        if (cartItem == null) {
          return const SizedBox.shrink();
        }

        final cartProvider = Provider.of<CartProvider>(context, listen: false);

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDarkMode
                          ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
                          : [Colors.white, const Color(0xFFFBFBFB)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode
                            ? Colors.black.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.12),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                        spreadRadius: -3,
                      ),
                      BoxShadow(
                        color: isDarkMode
                            ? Colors.white.withOpacity(0.02)
                            : Colors.white.withOpacity(0.8),
                        blurRadius: 1,
                        offset: const Offset(0, 1),
                      ),
                    ],
                    border: Border.all(
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.08)
                          : Colors.grey.withOpacity(0.08),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProductImage(isDarkMode),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildProductDetails(
                            context,
                            isDarkMode,
                            cartProvider,
                            cartItem,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProductImage(bool isDarkMode) {
    return Hero(
      tag: 'cart-item-${widget.cartItem.item.id}',
      child: Container(
        width: 120,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: _buildImage(isDarkMode),
        ),
      ),
    );
  }

  Widget _buildImage(bool isDarkMode) {
    if (widget.cartItem.item.image.startsWith('http')) {
      return Image.network(
        widget.cartItem.item.image,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.laptop_rounded,
              size: 40,
              color: Colors.grey.shade400,
            ),
          );
        },
      );
    } else {
      return Image.asset(
        widget.cartItem.item.image,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.laptop_rounded,
              size: 40,
              color: Colors.grey.shade400,
            ),
          );
        },
      );
    }
  }

  Widget _buildProductDetails(
    BuildContext context,
    bool isDarkMode,
    CartProvider cartProvider,
    CartItem cartItem,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product title
        Text(
          cartItem.item.title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: isDarkMode ? Colors.white : Colors.black87,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 8),

        // Price with better formatting
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.shade400.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '₦${cartItem.item.price.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.blue.shade400,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Total price for this item
        Text(
          'Subtotal: ₦${(cartItem.item.price * cartItem.quantity).toStringAsFixed(2)}',
          style: TextStyle(
            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 16),

        // Quantity and Remove controls
        Row(
          children: [
            _buildQuantityControls(isDarkMode, cartProvider, cartItem),
            const SizedBox(width: 12),
            _buildRemoveButton(isDarkMode, cartProvider, cartItem),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantityControls(
    bool isDarkMode,
    CartProvider cartProvider,
    CartItem cartItem,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.grey.shade800.withOpacity(0.5)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQuantityButton(
            icon: Icons.remove_rounded,
            onTap: () => _decreaseQuantity(cartProvider, cartItem),
            enabled: cartItem.quantity > 1,
            isDarkMode: isDarkMode,
          ),

          Container(
            constraints: const BoxConstraints(minWidth: 40),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                cartItem.quantity.toString(),
                key: ValueKey(cartItem.quantity),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          _buildQuantityButton(
            icon: Icons.add_rounded,
            onTap: () => _increaseQuantity(cartProvider, cartItem),
            enabled: true,
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildRemoveButton(
    bool isDarkMode,
    CartProvider cartProvider,
    CartItem cartItem,
  ) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isRemoving ? null : () => _removeItem(cartProvider, cartItem),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _isRemoving
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.red.shade400,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.red.shade400,
                          size: 18,
                        ),
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
    required bool isDarkMode,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isUpdating ? null : (enabled ? onTap : null),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: enabled
                ? (isDarkMode ? Colors.grey.shade700 : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _isUpdating
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blue.shade400,
                      ),
                    ),
                  )
                : Icon(
                    icon,
                    size: 16,
                    color: enabled
                        ? (isDarkMode ? Colors.white : Colors.grey.shade700)
                        : Colors.grey.shade400,
                  ),
          ),
        ),
      ),
    );
  }

  void _decreaseQuantity(CartProvider cartProvider, CartItem cartItem) async {
    if (cartItem.quantity <= 1 || _isUpdating) return;

    // Add haptic feedback
    HapticFeedback.lightImpact();

    setState(() {
      _isUpdating = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final newQuantity = cartItem.quantity - 1;
      final updatedItem = cartItem.copyWith(quantity: newQuantity);
      cartProvider.addOrUpdateItem(updatedItem);
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update quantity: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  void _increaseQuantity(CartProvider cartProvider, CartItem cartItem) async {
    if (_isUpdating) return;

    // Add haptic feedback
    HapticFeedback.lightImpact();

    setState(() {
      _isUpdating = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final newQuantity = cartItem.quantity + 1;
      final updatedItem = cartItem.copyWith(quantity: newQuantity);
      cartProvider.addOrUpdateItem(updatedItem);
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update quantity: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  void _removeItem(CartProvider cartProvider, CartItem cartItem) async {
    // Show confirmation dialog first
    final shouldRemove = await _showRemoveDialog();
    if (!shouldRemove) return;

    // Add haptic feedback
    HapticFeedback.mediumImpact();

    setState(() {
      _isRemoving = true;
    });

    try {
      // Add slight delay for better UX
      await Future.delayed(const Duration(milliseconds: 500));

      // Animate out before removing
      await _animationController.reverse();

      cartProvider.removeItem(cartItem.item.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${cartItem.item.title} removed from cart',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            action: SnackBarAction(
              label: 'Undo',
              textColor: Colors.white,
              onPressed: () {
                cartProvider.addOrUpdateItem(cartItem);
                // Reset animation
                _animationController.forward();
              },
            ),
          ),
        );
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove item: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRemoving = false;
        });
      }
    }
  }

  Future<bool> _showRemoveDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.red.shade400,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Remove Item', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
              content: Text(
                'Are you sure you want to remove "${widget.cartItem.item.title}" from your cart?',
                style: const TextStyle(height: 1.4),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Remove'),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
