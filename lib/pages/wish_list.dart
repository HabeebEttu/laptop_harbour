import 'package:flutter/material.dart';
import 'package:laptop_harbour/components/bottom_nav_bar.dart';
import 'package:laptop_harbour/components/wish_list_card.dart';
import 'package:laptop_harbour/pages/cart_page.dart';
import 'package:laptop_harbour/pages/home_page.dart';
import 'package:laptop_harbour/pages/orders_page.dart';
import 'package:laptop_harbour/pages/profile_page.dart';
import 'package:laptop_harbour/providers/wishlist_provider.dart';
import 'package:provider/provider.dart';

class WishList extends StatefulWidget {
  const WishList({super.key});

  @override
  State<WishList> createState() => _WishListState();
}

class _WishListState extends State<WishList> with TickerProviderStateMixin {
  int _selectedIndex = 1;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    // Add haptic feedback
    _triggerHapticFeedback();

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        _navigateWithTransition(const HomePage());
        break;
      case 1:
        // Already on wishlist page, do nothing.
        break;
      case 2:
        _navigateWithTransition(const CartPage());
        break;
      case 3:
        _navigateWithTransition(const OrdersPage());
        break;
      case 4:
        _navigateWithTransition(ProfilePage());
        break;
    }
  }

  void _triggerHapticFeedback() {
    // Add haptic feedback for better UX
    // HapticFeedback.lightImpact(); // Uncomment if you want haptic feedback
  }

  void _navigateWithTransition(Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF121212)
          : const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: FadeTransition(
          opacity: _fadeAnimation,
          child: const Text(
            'Wishlist',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDarkMode ? Colors.white : Colors.black87,
        centerTitle: false,
        actions: [
          Consumer<WishlistProvider>(
            builder: (context, wishlistProvider, child) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 16),
                child: IconButton(
                  onPressed: wishlistProvider.wishlist.isEmpty
                      ? null
                      : () => _showClearWishlistDialog(context),
                  icon: const Icon(Icons.clear_all_rounded),
                  tooltip: 'Clear Wishlist',
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section with Count
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
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
                            ? Colors.black26
                            : Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Consumer<WishlistProvider>(
                    builder: (context, wishlistProvider, child) {
                      final wishlist = wishlistProvider.wishlist;
                      return Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.favorite_rounded,
                              color: Colors.red.shade400,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Saved Items",
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: Text(
                                    "${wishlist.length} ${wishlist.length == 1 ? 'product' : 'products'}",
                                    key: ValueKey(wishlist.length),
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // Content Section
                Expanded(
                  child: Consumer<WishlistProvider>(
                    builder: (context, wishlistProvider, child) {
                      final wishlist = wishlistProvider.wishlist;

                      if (wishlistProvider.loading) {
                        return _buildLoadingState();
                      } else if (wishlist.isEmpty) {
                        return _buildEmptyState(isDarkMode);
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          await wishlistProvider.refreshWishlist();
                        },
                        color: Colors.red.shade400,
                        child: AnimatedList(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          initialItemCount: wishlist.length,
                          itemBuilder: (context, index, animation) {
                            if (index >= wishlist.length)
                              return const SizedBox.shrink();

                            final laptop = wishlist[index];
                            return SlideTransition(
                              position:
                                  Tween<Offset>(
                                    begin: const Offset(1, 0),
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.easeInOut,
                                    ),
                                  ),
                              child: FadeTransition(
                                opacity: animation,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: WishListCard(laptop: laptop),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
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

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade400),
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Loading your favorites...',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Heart Icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 1500),
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.withOpacity(0.1),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.favorite_border_rounded,
                      size: 80,
                      color: Colors.red.shade300,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            Text(
              'Your wishlist is empty',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Start saving your favorite laptops\nto see them here',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 40),

            // Browse Button
            ElevatedButton.icon(
              onPressed: () => _navigateWithTransition(const HomePage()),
              icon: const Icon(Icons.explore_outlined),
              label: const Text('Browse Laptops'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearWishlistDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 12),
              Text('Clear Wishlist'),
            ],
          ),
          content: const Text(
            'Are you sure you want to remove all items from your wishlist? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<WishlistProvider>(
                  context,
                  listen: false,
                ).clearWishlist();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Wishlist cleared'),
                    backgroundColor: Colors.red.shade400,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }
}
