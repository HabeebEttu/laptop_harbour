import 'package:flutter/material.dart';
import 'package:laptop_harbour/models/laptop.dart';
import 'package:laptop_harbour/models/profile.dart';
import 'package:laptop_harbour/models/review.dart';
import 'package:laptop_harbour/models/cart_item.dart';
import 'package:laptop_harbour/providers/cart_provider.dart';
import 'package:laptop_harbour/providers/wishlist_provider.dart';
import 'package:laptop_harbour/providers/laptop_provider.dart'; // Import LaptopProvider
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

  final ReviewService _reviewService = ReviewService(); // Keep ReviewService for adding reviews
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

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 1,
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

    return Hero(
      tag: 'laptop-${widget.laptop.id}',
      child: Container(
        height: imageHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
                color: Colors.grey[100],
                child: Center(
                  child: CircularProgressIndicator(
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
                color: Colors.grey[200],
                child: const Icon(Icons.error, size: 50, color: Colors.grey),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfo(AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.laptop.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          NumberFormat.currency(
            locale: 'en_US',
            symbol: '₦',
            decimalDigits: 0,
          ).format(widget.laptop.price),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Theme.of(context).primaryColor,
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                StreamBuilder<List<Review>>(
                  stream: _reviewService.getReviews(widget.laptop.id!),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Text('(0 reviews)');
                    }
                    return Text(
                      '(${snapshot.data!.length} reviews)',
                      style: TextStyle(color: Colors.grey[600]),
                    );
                  },
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabSection(AuthProvider authProvider) {
    return Expanded(
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: const [
              Tab(text: 'Specifications'),
              Tab(text: 'Reviews'),
              Tab(text: 'Add Review'),
            ],
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
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 16),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Specifications',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
    return SingleChildScrollView(
      key: _reviewSectionKey,
      padding: const EdgeInsets.only(top: 16),
      child: StreamBuilder<List<Review>>(
        stream: _reviewService.getReviews(widget.laptop.id!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Could not load reviews',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text('Please try again later'),
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
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No reviews yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text('Be the first to review this product!'),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 16),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Your Review',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              const Text(
                'Your Rating',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                              : Colors.grey[400],
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
                decoration: InputDecoration(
                  labelText: 'Write your review...',
                  hintText: 'Share your experience with this laptop',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                  foregroundColor: Theme.of(context).primaryColor,
                  side: BorderSide(color: Theme.of(context).primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isAddingToCart
                    ? null
                    : () => _addToCart(authProvider),
                icon: _isAddingToCart
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
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
                  backgroundColor: Theme.of(context).primaryColor,
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(color: Colors.black54),
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

    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Simulate API call

    // Defer the cart update to the next frame
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
    // Implement buy now logic
    _showSnackBar('Proceeding to checkout...', Icons.shopping_bag);
  }

  void _showLoginPrompt(String message) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
    _showSnackBar(message, Icons.login);
  }

  void _showSnackBar(String message, IconData icon, [Color? color]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: color ?? Theme.of(context).primaryColor,
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
              elevation: 1,
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
                          backgroundColor: Theme.of(context).primaryColor,
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
                                    return const Text('Loading...');
                                  }
                                  if (userSnapshot.hasError ||
                                      !userSnapshot.hasData) {
                                    return const Text('Unknown User');
                                  }
                                  return Text(
                                    userSnapshot.data!.firstName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
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
                                      color: Colors.grey[600],
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
                      style: const TextStyle(fontSize: 14, height: 1.4),
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
              color: Theme.of(context).primaryColor,
            ),
            label: Text(
              _showAllReviews
                  ? 'Show Less'
                  : 'Show All ${widget.reviews.length} Reviews',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
        ],
      ],
    );
  }
}
