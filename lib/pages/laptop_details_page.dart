import 'package:laptop_harbour/models/cart.dart';
import 'package:laptop_harbour/models/cart_item.dart';
import 'package:laptop_harbour/pages/checkout_page.dart';
import 'package:flutter/material.dart';
import 'package:laptop_harbour/models/laptop.dart';
import 'package:laptop_harbour/models/profile.dart';
import 'package:laptop_harbour/models/review.dart';
import 'package:laptop_harbour/providers/cart_provider.dart';
import 'package:laptop_harbour/providers/wishlist_provider.dart';

import 'package:laptop_harbour/services/review_service.dart';
import 'package:laptop_harbour/services/user_service.dart';
import 'package:laptop_harbour/providers/auth_provider.dart';
import 'package:laptop_harbour/pages/login_page.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ProductDetailsPage extends StatefulWidget {
  final Laptop laptop;

  const ProductDetailsPage({super.key, required this.laptop});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage>
    with TickerProviderStateMixin {
  final TextEditingController _reviewController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _reviewSectionKey = GlobalKey();

  double _rating = 0;
  bool _isSubmittingReview = false;
  bool _isAddingToCart = false;
  late TabController _tabController;

  final ReviewService _reviewService = ReviewService();
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _scrollToReviews() {
    final RenderBox? renderBox =
        _reviewSectionKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      _scrollController.animateTo(
        _scrollController.offset + position.dy - 100,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1200;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: isDarkMode ? theme.appBarTheme.backgroundColor : null,
        foregroundColor: isDarkMode ? theme.appBarTheme.foregroundColor : null,
        title: Text(
          widget.laptop.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Consumer<WishlistProvider>(
            builder: (context, wishlistProvider, child) {
              final bool isInWishlist = wishlistProvider.isFavorite(
                widget.laptop,
              );
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: IconButton(
                  key: ValueKey(isInWishlist),
                  icon: Icon(
                    isInWishlist ? Icons.favorite : Icons.favorite_border,
                    color: isInWishlist ? Colors.red : null,
                  ),
                  onPressed: () => _handleWishlistToggle(
                    authProvider,
                    wishlistProvider,
                    isInWishlist,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isDesktop
          ? _buildDesktopLayout(authProvider)
          : _buildMobileLayout(authProvider),
      bottomNavigationBar: _buildBottomActionBar(authProvider),
    );
  }

  Widget _buildDesktopLayout(AuthProvider authProvider) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column - Image and specs
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  _buildProductImage(height: 400),
                  const SizedBox(height: 32),
                  _buildSpecsSection(),
                ],
              ),
            ),
            const SizedBox(width: 32),
            // Right column - Product info and reviews
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductInfo(authProvider),
                  const SizedBox(height: 32),
                  _buildReviewsSection(authProvider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(AuthProvider authProvider) {
    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverToBoxAdapter(child: _buildProductImage()),
      ],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductInfo(authProvider),
            const SizedBox(height: 24),
            _buildTabSection(authProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage({double? height}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageHeight = height ?? (screenWidth >= 768 ? 300 : 250);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Hero(
      tag: 'laptop-${widget.laptop.id}',
      child: Container(
        height: imageHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDarkMode ? theme.cardColor : Colors.white,
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image(
            image: widget.laptop.image.startsWith('http')
                ? NetworkImage(widget.laptop.image)
                : AssetImage(widget.laptop.image) as ImageProvider,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: isDarkMode ? theme.cardColor : Colors.grey[100],
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                    color: theme.primaryColor,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: isDarkMode ? theme.cardColor : Colors.grey[200],
                child: Icon(
                  Icons.error,
                  size: 50,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfo(AuthProvider authProvider) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.laptop.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            height: 1.2,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          NumberFormat.currency(
            locale: 'en_US',
            symbol: '₦',
            decimalDigits: 0,
          ).format(widget.laptop.price),
          style: theme.textTheme.headlineMedium?.copyWith(
            color:isDarkMode ?Colors.grey[200]: theme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: _scrollToReviews,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < widget.laptop.rating
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    );
                  }),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.laptop.rating.toStringAsFixed(1),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
                StreamBuilder<List<Review>>(
                  stream: _reviewService.getReviews(widget.laptop.id!),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Text(
                        '(0 reviews)',
                        style: TextStyle(
                          color: isDarkMode? Colors.grey[400] : Colors.grey[600],
                        ),
                      );
                    }
                    return Text(
                      '(${snapshot.data!.length} reviews)',
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    );
                  },
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabSection(AuthProvider authProvider) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Expanded(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? theme.cardColor : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: isDarkMode?Colors.grey[50]:theme.primaryColor,
              unselectedLabelColor: isDarkMode ? Colors.grey[400] : Colors.grey,
              indicatorColor: theme.primaryColor,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Specifications',),
                Tab(text: 'Reviews'),
                Tab(text: 'Add Review'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSpecsSection(),
                _buildReviewsSection(authProvider),
                _buildAddReviewSection(authProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecsSection() {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 16),
      child: Card(
        elevation: isDarkMode ? 4 : 2,
        color: isDarkMode ? theme.cardColor : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Specifications',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              _buildSpecRow('Processor', widget.laptop.specs.processor),
              _buildSpecRow('RAM', widget.laptop.specs.ram),
              _buildSpecRow('Storage', widget.laptop.specs.storage),
              _buildSpecRow('Display', widget.laptop.specs.display),
              if (widget.laptop.specs.graphicsCard != null)
                _buildSpecRow('Graphics', widget.laptop.specs.graphicsCard!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsSection(AuthProvider authProvider) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      key: _reviewSectionKey,
      padding: const EdgeInsets.only(top: 16),
      child: StreamBuilder<List<Review>>(
        stream: _reviewService.getReviews(widget.laptop.id!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: CircularProgressIndicator(color: theme.primaryColor),
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Could not load reviews',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please try again later',
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.rate_review_outlined,
                      size: 48,
                      color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No reviews yet',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Be the first to review this product!',
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return _ReviewsList(
            reviews: snapshot.data!,
            userService: _userService,
          );
        },
      ),
    );
  }

  Widget _buildAddReviewSection(AuthProvider authProvider) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 16),
      child: Card(
        elevation: isDarkMode ? 4 : 2,
        color: isDarkMode ? theme.cardColor : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Your Review',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Your Rating',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _rating = index + 1.0;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: index < _rating
                              ? Colors.amber
                              : (isDarkMode
                                    ? Colors.grey[500]
                                    : Colors.grey[400]),
                          size: 32,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _reviewController,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  labelText: 'Write your review...',
                  hintText: 'Share your experience with this laptop',
                  labelStyle: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.primaryColor),
                  ),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[50],
                ),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  onPressed: _isSubmittingReview
                      ? null
                      : () => _submitReview(authProvider),
                  child: _isSubmittingReview
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Submit Review',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(AuthProvider authProvider) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? theme.scaffoldBackgroundColor
            : theme.scaffoldBackgroundColor,
        border: isDarkMode
            ? Border(top: BorderSide(color: Colors.grey[800]!, width: 0.5))
            : null,
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.primaryColor,
                  side: BorderSide(color: theme.primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: isDarkMode ? Colors.transparent : null,
                ),
                onPressed: _isAddingToCart
                    ? null
                    : () => _addToCart(authProvider),
                icon: _isAddingToCart
                    ? SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.primaryColor,
                        ),
                      )
                    : const Icon(Icons.shopping_cart_outlined),
                label: Text(
                  _isAddingToCart ? 'Adding...' : 'Add to Cart',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                onPressed: () => _buyNow(authProvider),
                icon: const Icon(Icons.flash_on),
                label: const Text(
                  'Buy Now',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(String title, String value) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: isDarkMode ? Colors.grey[300] : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleWishlistToggle(
    AuthProvider authProvider,
    WishlistProvider wishlistProvider,
    bool isInWishlist,
  ) {
    if (authProvider.user == null) {
      _showLoginPrompt('You need to be logged in to add to wishlist');
      return;
    }

    if (isInWishlist) {
      wishlistProvider.removeFromWishlist(widget.laptop);
      _showSnackBar('Removed from wishlist', Icons.favorite_border);
    } else {
      wishlistProvider.addToWishlist(widget.laptop);
      _showSnackBar('Added to wishlist', Icons.favorite, Colors.red);
    }
  }

  Future<void> _submitReview(AuthProvider authProvider) async {
    if (authProvider.user == null) {
      _showLoginPrompt('Sign in to review a product');
      return;
    }

    if (_reviewController.text.trim().isEmpty) {
      _showSnackBar('Please write a review', Icons.warning, Colors.orange);
      return;
    }

    if (_rating == 0) {
      _showSnackBar('Please select a rating', Icons.warning, Colors.orange);
      return;
    }

    setState(() {
      _isSubmittingReview = true;
    });

    try {
      final newReview = Review(
        userId: authProvider.user!.uid,
        rating: _rating,
        comment: _reviewController.text.trim(),
        reviewDate: DateTime.now(),
      );

      await _reviewService.addReview(widget.laptop.id!, newReview);
      await _reviewService.updateLaptopRating(widget.laptop.id!);

      _reviewController.clear();
      setState(() {
        _rating = 0;
      });

      _showSnackBar(
        'Review submitted successfully!',
        Icons.check_circle,
        Colors.green,
      );
    } catch (e) {
      _showSnackBar(
        'Failed to submit review. Please try again.',
        Icons.error,
        Colors.red,
      );
    } finally {
      setState(() {
        _isSubmittingReview = false;
      });
    }
  }

  Future<void> _addToCart(AuthProvider authProvider) async {
    if (authProvider.user == null) {
      _showLoginPrompt('Sign in to add to cart');
      return;
    }

    setState(() {
      _isAddingToCart = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.addOrUpdateItem(CartItem(item: widget.laptop, quantity: 1));

      setState(() {
        _isAddingToCart = false;
      });

      _showSnackBar('Added to cart', Icons.shopping_cart, Colors.green);
    });
  }

  void _buyNow(AuthProvider authProvider) {
    if (authProvider.user == null) {
      _showLoginPrompt('Sign in to buy now');
      return;
    }

    final tempCart = Cart(
      items: [CartItem(item: widget.laptop, quantity: 1)],
      userId: authProvider.user!.uid,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(cart: tempCart),
      ),
    );
  }

  void _showLoginPrompt(String message) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
    _showSnackBar(message, Icons.login);
  }

  void _showSnackBar(String message, IconData icon, [Color? color]) {
    final theme = Theme.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(message, style: const TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: color ?? theme.primaryColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _ReviewsList extends StatefulWidget {
  final List<Review> reviews;
  final UserService userService;

  const _ReviewsList({required this.reviews, required this.userService});

  @override
  _ReviewsListState createState() => _ReviewsListState();
}

class _ReviewsListState extends State<_ReviewsList> {
  bool _showAllReviews = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final displayedReviews = _showAllReviews
        ? widget.reviews
        : widget.reviews.take(3).toList();

    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayedReviews.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final review = displayedReviews[index];
            return Card(
              elevation: isDarkMode ? 4 : 1,
              color: isDarkMode ? theme.cardColor : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: theme.primaryColor,
                          child: Text(
                            review.userId.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FutureBuilder<Profile?>(
                                future: widget.userService.getUserProfile(
                                  review.userId,
                                ),
                                builder: (context, userSnapshot) {
                                  if (userSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Text(
                                      'Loading...',
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                      ),
                                    );
                                  }
                                  if (userSnapshot.hasError ||
                                      !userSnapshot.hasData) {
                                    return Text(
                                      'Unknown User',
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                      ),
                                    );
                                  }
                                  return Text(
                                    userSnapshot.data!.firstName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  ...List.generate(5, (i) {
                                    return Icon(
                                      i < review.rating
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber,
                                      size: 16,
                                    );
                                  }),
                                  const SizedBox(width: 8),
                                  Text(
                                    DateFormat(
                                      'MMM d, yyyy',
                                    ).format(review.reviewDate),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      review.comment,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: isDarkMode ? Colors.grey[200] : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        if (widget.reviews.length > 3) ...[
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _showAllReviews = !_showAllReviews;
              });
            },
            icon: Icon(
              _showAllReviews ? Icons.expand_less : Icons.expand_more,
              color: theme.primaryColor,
            ),
            label: Text(
              _showAllReviews
                  ? 'Show Less'
                  : 'Show All ${widget.reviews.length} Reviews',
              style: TextStyle(color: theme.primaryColor),
            ),
          ),
        ],
      ],
    );
  }
}
