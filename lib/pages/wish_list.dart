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

class _WishListState extends State<WishList> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const HomePage()));
        break;
      case 1:
        // Already on wishlist page, do nothing.
        break;
      case 2:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const CartPage()));
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OrdersPage()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Wishlist',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Your Saved Products (5)",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Consumer<WishlistProvider>(
                builder: (context, wishlistProvider, child) {
                  final wishlist = wishlistProvider.wishlist;
                  if (wishlist.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.favorite_border, size: 64),
                          const SizedBox(height: 16),
                          Text(
                            'Your wishlist is empty',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ListView.builder(
                      itemCount: wishlist.length,
                      itemBuilder: (context, index) {
                        final laptop = wishlist[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: WishListCard(laptop: laptop),
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
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
