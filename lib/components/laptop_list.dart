import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laptop_harbour/models/laptop.dart';
import 'package:laptop_harbour/pages/laptop_details_page.dart' as laptop_details;
import 'package:flutter/services.dart';
import 'package:laptop_harbour/providers/laptop_provider.dart';
import 'package:laptop_harbour/services/laptop_service.dart';
import 'package:provider/provider.dart';

class LaptopList extends StatefulWidget {
  final List<Laptop> laptops;

  const LaptopList({super.key, required this.laptops});

  @override
  State<LaptopList> createState() => _LaptopListState();
}

class _LaptopListState extends State<LaptopList> {
  String _sortCriterion = 'none';
  bool _isGridView = false;

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: r'₦',
      decimalDigits: 2,
    );

    final displayLaptops = List<Laptop>.from(widget.laptops);

    if (_sortCriterion == 'price_asc') {
      displayLaptops.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortCriterion == 'price_desc') {
      displayLaptops.sort((a, b) => b.price.compareTo(a.price));
    } else if (_sortCriterion == 'rating') {
      displayLaptops.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'The filter feature is coming soon!')),
                    );
                  },
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    setState(() {
                      _sortCriterion = value;
                    });
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'none',
                      child: Text('Sort by: Default'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'price_asc',
                      child: Text('Price: Low to High'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'price_desc',
                      child: Text('Price: High to Low'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'rating',
                      child: Text('Sort by: Rating'),
                    ),
                  ],
                  child: const Row(
                    children: [
                      Text("Sort"),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ],
            ),
            IconButton(
              icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
              onPressed: () {
                setState(() {
                  _isGridView = !_isGridView;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_isGridView)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: displayLaptops.length,
            itemBuilder: (context, index) {
              final laptop = displayLaptops[index];
              return LaptopCard(
                  laptop: laptop, currencyFormatter: currencyFormatter);
            },
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayLaptops.length,
            itemBuilder: (context, index) {
              final laptop = displayLaptops[index];
              return Container(
                height: 250,
                margin: const EdgeInsets.only(bottom: 10),
                child: LaptopCard(
                    laptop: laptop, currencyFormatter: currencyFormatter),
              );
            },
          ),
      ],
    );
  }
}



class LaptopCard extends StatefulWidget {
  const LaptopCard({
    super.key,
    required this.laptop,
    required this.currencyFormatter,
  });
  
  final Laptop laptop;
  final NumberFormat currencyFormatter;

  @override
  State<LaptopCard> createState() => _LaptopCardState();
}

class _LaptopCardState extends State<LaptopCard> {
  int _reviewCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchReviewCount();
  }

  Future<void> _fetchReviewCount() async {
    try {
      final laptopProvider = Provider.of<LaptopProvider>(context, listen: false);
      final count = await laptopProvider.getReviewCountForLaptop(widget.laptop.id!); 
      if (mounted) {
        setState(() {
          _reviewCount = count;
        });
      }
    } catch (e) {
      debugPrint('Error fetching review count: $e');
      if (mounted) {
        setState(() {
          _reviewCount = 0; // Set to 0 or handle error state appropriately
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Add haptic feedback for better UX
          HapticFeedback.lightImpact();
          
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  laptop_details.ProductDetailsPage(laptop: widget.laptop),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOutCubic;
                
                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);
                
                return SlideTransition(
                  position: offsetAnimation,
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              transitionDuration: const Duration(milliseconds: 350),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        splashColor: Theme.of(context).primaryColor.withOpacity(0.1),
        highlightColor: Theme.of(context).primaryColor.withOpacity(0.05),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 3,
                offset: const Offset(0, 1),
                spreadRadius: 0,
              ),
            ],
            border: Border.all(
              color: Colors.grey.withOpacity(0.12),
              width: 0.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section with overlay elements
              Expanded(
                flex: 3,
                child: _buildImageSection(context),
              ),
              
              // Content section
              _buildContentSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Stack(
        children: [
          // Main product image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              widget.laptop.image,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Loading...',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.laptop_mac,
                          size: 32,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Image unavailable',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Rating badge overlay
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.75),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Colors.amber,
                    size: 12,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    widget.laptop.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Wishlist button (optional - you can remove if not needed)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 16,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Product title with better typography
          Text(
            widget.laptop.title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 8),
          
          // Price with enhanced styling
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  NumberFormat.currency(symbol: '₦',decimalDigits: 2)
                  .format(widget.laptop.price),
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                // Removed Stock indicator
              ],
            ),
          ),
          
          const SizedBox(height: 6),
          
          // Enhanced rating section
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Star rating display
                Row(
                  children: List.generate(5, (index) {
                    if (index < widget.laptop.rating.floor()) {
                      return const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 14,
                      );
                    } else if (index < widget.laptop.rating) {
                      return const Icon(
                        Icons.star_half_rounded,
                        color: Colors.amber,
                        size: 14,
                      );
                    } else {
                      return Icon(
                        Icons.star_outline_rounded,
                        color: Colors.grey[300],
                        size: 14,
                      );
                    }
                  }),
                ),
                const SizedBox(width: 4),
                Text(
                  '(${_getReviewCount(_reviewCount)})',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                // Quick action button
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.add_shopping_cart_rounded,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to get review count
  String _getReviewCount(int count) {
    return count.toString();
  }
}