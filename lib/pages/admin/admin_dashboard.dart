import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:laptop_harbour/pages/admin/laptop_management.dart';
import 'package:laptop_harbour/pages/admin/order_management.dart';
import 'package:laptop_harbour/pages/admin/user_management.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildDashboardCard(
            context,
            icon: FontAwesomeIcons.laptop,
            title: 'Laptop Management',
            subtitle: 'View and edit all laptops',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const LaptopManagementPage(),
              ),
            ),
          ),
          _buildDashboardCard(
            context,
            icon: FontAwesomeIcons.plus,
            title: 'Add New Laptop',
            subtitle: 'Add a new laptop to the store',
            onTap: () => Navigator.pushNamed(context, '/add_laptop'),
          ),
          _buildDashboardCard(
            context,
            icon: FontAwesomeIcons.tags,
            title: 'Add New Category',
            subtitle: 'Add a new product category',
            onTap: () => Navigator.pushNamed(context, '/add_category'),
          ),
          _buildDashboardCard(
            context,
            icon: FontAwesomeIcons.users,
            title: 'User Management',
            subtitle: 'Manage user roles and permissions',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const UserManagementPage(),
              ),
            ),
          ),
          _buildDashboardCard(
            context,
            icon: FontAwesomeIcons.boxOpen,
            title: 'Order Management',
            subtitle: 'View and update customer orders',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const OrderManagementPage(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        leading: FaIcon(icon, color: Theme.of(context).primaryColor, size: 28),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
