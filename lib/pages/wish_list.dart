import 'package:flutter/material.dart';
import 'package:laptop_harbour/components/bottom_nav_bar.dart';
import 'package:laptop_harbour/components/wish_list_card.dart';
import 'package:laptop_harbour/models/laptop.dart';
import 'package:laptop_harbour/models/specs.dart';
import 'package:laptop_harbour/pages/cart_page.dart';
import 'package:laptop_harbour/pages/home_page.dart';
import 'package:laptop_harbour/pages/orders_page.dart';
import 'package:laptop_harbour/pages/profile_page.dart';

class WishList extends StatefulWidget {
  const WishList({super.key});

  @override
  State<WishList> createState() => _WishListState();
}

class _WishListState extends State<WishList> {
  int _selectedIndex = 1;

  // Dummy data for the wishlist
  final List<Laptop> _wishlist = [
    Laptop(
      id: '1',
      title: 'HP Spectre x360 (Dummy)',
      brand: 'HP',
      price: 1299.99,
      image: 'assets/images/laptop1.jpg',
      categoryId: 'premium',
      rating: 4.8,
      tags: ['premium', 'convertible', 'oled'],
      reviews: [],
      specs: Specs(
        processor: 'Intel Core i7-1165G7',
        ram: '16GB DDR4',
        storage: '1TB NVMe SSD',
        display: '13.3" 4K UHD OLED',
        graphicsCard: 'Intel Iris Xe Graphics',
      ),
    ),
    Laptop(
      id: '2',
      title: 'Dell XPS 15 (Dummy)',
      brand: 'Dell',
      price: 1799.99,
      image: 'assets/images/laptop2.jpg',
      categoryId: 'premium',
      rating: 4.9,
      tags: ['premium', 'powerful', '4k'],
      reviews: [],
      specs: Specs(
        processor: 'Intel Core i9-11900H',
        ram: '32GB DDR4',
        storage: '2TB NVMe SSD',
        display: '15.6" 4K UHD+ OLED',
        graphicsCard: 'NVIDIA GeForce RTX 3050 Ti',
      ),
    ),
    Laptop(
      id: '3',
      title: 'MacBook Air M2 (Dummy)',
      brand: 'Apple',
      price: 1199.00,
      image: 'assets/images/laptop3.jpg',
      categoryId: 'ultraportable',
      rating: 4.9,
      tags: ['ultraportable', 'm2', 'retina'],
      reviews: [],
      specs: Specs(
        processor: 'Apple M2',
        ram: '8GB unified memory',
        storage: '256GB SSD',
        display: '13.6" Liquid Retina display',
        graphicsCard: 'Apple 8-core GPU',
      ),
    ),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;
      case 1:
        // Already on wishlist page, do nothing.
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CartPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OrdersPage()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WishList', style: TextStyle(fontWeight: FontWeight.w800)),
        automaticallyImplyLeading: true,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Builder(
          builder: (context) {
            final wishlist = _wishlist;
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
            return SingleChildScrollView(
              child: Column(
                children: [
                  Text('Your saved products (${wishlist.length})'),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: wishlist.length,
                    itemBuilder: (context, index) {
                      final laptop = wishlist[index];
                      return WishListCard(laptop: laptop);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
