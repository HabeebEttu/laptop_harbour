import 'package:flutter/material.dart';
import 'package:laptop_harbour/models/laptop.dart';
import 'package:laptop_harbour/models/profile.dart';
import 'package:laptop_harbour/models/review.dart';
import 'package:laptop_harbour/models/cart_item.dart';
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

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final TextEditingController _reviewController = TextEditingController();
  double _rating = 0;
  final ReviewService _reviewService = ReviewService();
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.laptop.title),
        actions: [
          Consumer<WishlistProvider>(
            builder: (context, wishlistProvider, child) {
              final bool isInWishlist =
                  wishlistProvider.isFavorite(widget.laptop);
              return IconButton(
                icon: Icon(
                  isInWishlist ? Icons.favorite : Icons.favorite_border,
                  color: isInWishlist ? Colors.red : null,
                ),
                onPressed: () {
                  if (authProvider.user == null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'You need to be logged in to add to wishlist')),
                    );
                  } else {
                    if (isInWishlist) {
                      wishlistProvider.removeFromWishlist(widget.laptop);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Removed from wishlist'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    } else {
                      wishlistProvider.addToWishlist(widget.laptop);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Added to wishlist'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }
                  }
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: widget.laptop.image.startsWith('http')
                        ? NetworkImage(widget.laptop.image)
                        : AssetImage(widget.laptop.image) as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.laptop.title,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                NumberFormat.currency(
                  locale: 'en_US',
                  symbol: '₦',
                  decimalDigits: 2,
                ).format(widget.laptop.price),
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Theme.of(context).primaryColor),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.blueAccent, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    widget.laptop.rating.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(width: 8),
                  StreamBuilder<List<Review>>(
                    stream: _reviewService.getReviews(widget.laptop.id!),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Text('(0 reviews)');
                      }
                      return Text('(${snapshot.data!.length} reviews)');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Specifications',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildSpecRow('Processor', widget.laptop.specs.processor),
              _buildSpecRow('RAM', widget.laptop.specs.ram),
              _buildSpecRow('Storage', widget.laptop.specs.storage),
              _buildSpecRow('Display', widget.laptop.specs.display),
              if (widget.laptop.specs.graphicsCard != null)
                _buildSpecRow('Graphics', widget.laptop.specs.graphicsCard!),
              const SizedBox(height: 24),
              const Text(
                'Reviews',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              StreamBuilder<List<Review>>(
                stream: _reviewService.getReviews(widget.laptop.id!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Could not load reviews. Please try again later.'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No reviews yet.');
                  }
                  return _ReviewsList(
                    reviews: snapshot.data!,
                    userService: _userService,
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Add a Review',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your Rating',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = index + 1.0;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _reviewController,
                decoration: const InputDecoration(
                  labelText: 'Write your review...',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (authProvider.user == null) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Sign in to review a product')),
                      );
                      return;
                    }
                    if (_reviewController.text.isNotEmpty && _rating > 0) {
                      final newReview = Review(
                        userId: authProvider.user!.uid,
                        rating: _rating,
                        comment: _reviewController.text,
                        reviewDate: DateTime.now(),
                      );
                      await _reviewService.addReview(
                          widget.laptop.id!, newReview);
                      await _reviewService
                          .updateLaptopRating(widget.laptop.id!);
                      _reviewController.clear();
                      setState(() {
                        _rating = 0;
                      });
                    }
                  },
                  child: const Text('Submit Review'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blueAccent,
                    side: const BorderSide(color: Colors.blueAccent),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (authProvider.user == null) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Sign in to add to cart')),
                      );
                      return;
                    }
                    final cartProvider =
                        Provider.of<CartProvider>(context, listen: false);
                    cartProvider.addOrUpdateItem(
                      CartItem(item: widget.laptop, quantity: 1),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Added to cart'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: const Text('Add to Cart'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(value, textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}

class _ReviewsList extends StatefulWidget {
  final List<Review> reviews;
  final UserService userService;

  const _ReviewsList({
    required this.reviews,
    required this.userService,
  });

  @override
  _ReviewsListState createState() => _ReviewsListState();
}

class _ReviewsListState extends State<_ReviewsList> {
  bool _showAllReviews = false;

  @override
  Widget build(BuildContext context) {
    final displayedReviews =
        _showAllReviews ? widget.reviews : widget.reviews.take(3).toList();

    return Column(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.4,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayedReviews.length,
            itemBuilder: (context, index) {
              final review = displayedReviews[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(review.userId.substring(0, 1).toUpperCase()),
                  ),
                  title: FutureBuilder<Profile?>(
                    future: widget.userService.getUserProfile(review.userId),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Text('Loading...',
                            style: TextStyle(fontWeight: FontWeight.bold));
                      }
                      if (userSnapshot.hasError ||
                          !userSnapshot.hasData ||
                          userSnapshot.data == null) {
                        return const Text('Unknown User',
                            style: TextStyle(fontWeight: FontWeight.bold));
                      }
                      final userName = userSnapshot.data!.firstName;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(userName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                              review.reviewDate
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0],
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                        ],
                      );
                    },
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.comment),
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (i) => Icon(
                              i < review.rating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.blueAccent,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.reviews.length > 3)
          TextButton(
            onPressed: () {
              setState(() {
                _showAllReviews = !_showAllReviews;
              });
            },
            child: Text(
              _showAllReviews ? 'Show Less' : 'Show More Reviews',
              style: const TextStyle(color: Colors.blueAccent),
            ),
          ),
      ],
    );
  }
}
