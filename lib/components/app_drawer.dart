import 'package:flutter/material.dart';
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
            title:Text('Orders'),
            onTap: () {
              Navigator.pushNamed(context,'/orders');
            }
          ),
          ListTile(
            title: const Text('Wish List'),
            onTap: () {
              Navigator.pushNamed(context,'/wishlist');
            },
          ),
          ListTile(
            title: const Text('Add Laptop'),
            onTap: () {
              Navigator.pushNamed(context, '/add_laptop');
            },
          ),
          ListTile(
            title: const Text('Add Category'),
            onTap: () {
              Navigator.pushNamed(context, '/add_category');
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
    );
  }
}
