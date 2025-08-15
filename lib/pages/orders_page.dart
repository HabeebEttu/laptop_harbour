import 'package:flutter/material.dart';
import 'package:laptop_harbour/components/bottom_nav_bar.dart';
import 'package:laptop_harbour/pages/home_page.dart';
import 'package:laptop_harbour/pages/profile_page.dart';
import 'package:laptop_harbour/pages/wish_list.dart';
import 'package:laptop_harbour/providers/auth_provider.dart';
import 'package:laptop_harbour/providers/order_provider.dart';
import 'package:laptop_harbour/widgets/order_card.dart';
import 'package:provider/provider.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final int _selectedIndex = 3;
  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    // Use pushReplacement to avoid building up a stack of pages
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WishList()),
        );
        break;
      case 2:
        // You should have a CartPage to navigate to
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CartPage()));
        break;
      case 3:
        // Already on orders page, do nothing.
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
        title: const Text(
          'My Orders',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: ChangeNotifierProvider(
        create: (context) => OrderProvider(Provider.of<AuthProvider>(context, listen: false)),
        child: const OrdersList(),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}