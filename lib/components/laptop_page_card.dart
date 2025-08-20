import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laptop_harbour/models/laptop.dart';
import 'package:laptop_harbour/providers/wishlist_provider.dart';
import 'package:provider/provider.dart';
import 'package:laptop_harbour/pages/laptop_details_page.dart'
    as laptop_details;

class LaptopPageCard extends StatelessWidget {
  final Laptop laptop;
  final bool isGridView;
  final NumberFormat currencyFormatter;

  const LaptopPageCard({
    super.key,
    required this.laptop,
    this.isGridView = true,
    required this.currencyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        WishlistProvider wishlistProvider = Provider.of<WishlistProvider>(
          context,
        );
        List<Laptop> wishlist = Provider.of<WishlistProvider>(context).wishlist;
        bool isWishlisted = wishlist.contains(laptop);

        void toggleWishlist() {
          setState(() {
            isWishlisted = !isWishlisted;

            if (isWishlisted) {
              wishlistProvider.addToWishlist(laptop);
            } else {
              wishlistProvider.removeFromWishlist(laptop);
            }
            // Example: context.read<LaptopProvider>().toggleWishlist(laptop.id);
            laptop.isWishlisted = isWishlisted;
          });
        }

        if (isGridView) {
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      laptop_details.ProductDetailsPage(laptop: laptop),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(18),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        SizedBox(
                          height: 120,
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            child: laptop.image.startsWith('http')
                                ? Image.network(
                                    laptop.image,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  )
                                : Image.asset(
                                    laptop.image,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: GestureDetector(
                            onTap: toggleWishlist,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 16,
                              child: Icon(
                                isWishlisted
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isWishlisted
                                    ? Colors.red
                                    : const Color(0xFF1A1A1A),
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          laptop.title,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF222222),
                            letterSpacing: 0.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Color(0xFFFFC107),
                              size: 15,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              laptop.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 13.2,
                                color: Color(0xFF757575),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 13),
                        Text(
                          currencyFormatter.format(laptop.price),
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF1A73E8),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(18),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 110,
                  height: 120,
                  child: InkWell(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            laptop_details.ProductDetailsPage(laptop: laptop),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                      child: laptop.image.startsWith('http')
                          ? Image.network(
                              laptop.image,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            )
                          : Image.asset(
                              laptop.image,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  laptop_details.ProductDetailsPage(
                                    laptop: laptop,
                                  ),
                            ),
                          ),
                          child: Text(
                            laptop.title,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF222222),
                              letterSpacing: 0.1,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Color(0xFFFFC107),
                              size: 15,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              laptop.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 13.2,
                                color: Color(0xFF757575),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 13),
                        Text(
                          currencyFormatter.format(laptop.price),
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF1A73E8),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: GestureDetector(
                    onTap: toggleWishlist,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 16,
                      child: Icon(
                        isWishlisted ? Icons.favorite : Icons.favorite_border,
                        color: isWishlisted
                            ? Colors.red
                            : const Color(0xFF1A1A1A),
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
