import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laptop_harbour/components/header.dart';
import 'package:laptop_harbour/utils/responsive_text.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> navItems = [{}];
    return Scaffold(
      appBar: Header(),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Laptop Harbour'),
            ),
            ListTile(
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Settings'),
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          children: [
            ListTile(
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.arrow_back),
              ),
              title: Text('Shopping Cart',style: GoogleFonts.poppins(fontWeight: FontWeight.w600,fontSize:getResponsiveFontSize(context,22)),),
              subtitle: Text('3 items in our cart',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                  fontSize: getResponsiveFontSize(context, 18),
                ),
              ),
              
            ),
          ],
        ),
      ),
    );
  }
}
