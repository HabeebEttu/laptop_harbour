import 'package:flutter/material.dart';
import 'package:laptop_harbour/models/cart_item.dart';
import 'package:laptop_harbour/models/category.dart';
import 'package:laptop_harbour/models/laptop.dart';
import 'package:laptop_harbour/pages/laptop_details_page.dart';
import 'package:laptop_harbour/providers/cart_provider.dart';
import 'package:laptop_harbour/providers/category_provider.dart';
import 'package:intl/intl.dart';
import 'package:laptop_harbour/providers/wishlist_provider.dart';
import 'package:provider/provider.dart';

class WishListCard extends StatelessWidget {
  const WishListCard({super.key, required this.laptop});
  final Laptop laptop;

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: r'$',
      decimalDigits: 2,
    );

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    laptop.image,
                    height: 80,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Consumer<WishlistProvider>(
                    builder: (context, wishlistProvider, child) {
                      return GestureDetector(
                        onTap: () {
                          wishlistProvider.removeFromWishlist(laptop);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Item removed from your wishlist.'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        child: const CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 16,
                          child: Icon(
                            Icons.heart_broken_outlined,
                            color: Colors.red,
                            size: 18,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    laptop.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  FutureBuilder<Category?>(
                    future: Provider.of<CategoryProvider>(
                      context,
                      listen: false,
                    ).getCategory(laptop.categoryId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const SizedBox.shrink();
                      }
                      if (snapshot.hasError ||
                          !snapshot.hasData ||
                          snapshot.data == null) {
                        return const Text(
                          'N/A',
                          style:
                              TextStyle(color: Colors.grey, fontSize: 14),
                        );
                      }
                      final category = snapshot.data!;
                      return Text(
                        category.name,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  Text(
                    currencyFormatter.format(laptop.price),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final cartItem =
                            CartItem(item: laptop, quantity: 1);
                        cartProvider.addOrUpdateItem(cartItem);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Item added to your cart.'),
                              backgroundColor: Colors.green,
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        "Add to Cart",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailsPage(laptop: laptop),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text("View Details"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}