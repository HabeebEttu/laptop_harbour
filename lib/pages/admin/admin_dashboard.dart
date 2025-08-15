import 'package:flutter/material.dart';
import 'package:laptop_harbour/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _adminPages = [
    const _DashboardOverview(),
    const _LaptopManagement(),
    const _OrderManagement(),
    const _UserManagement(),
    const _ReviewsManagement(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Implement logout
              Provider.of<AuthProvider>(context, listen: false).signOut();
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
      drawer: NavigationDrawer(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: const [
          NavigationDrawerDestination(
            icon: Icon(Icons.dashboard),
            label: Text('Overview'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.laptop),
            label: Text('Laptops'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.shopping_cart),
            label: Text('Orders'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.people),
            label: Text('Users'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.star),
            label: Text('Reviews'),
          ),
        ],
      ),
      body: _adminPages[_selectedIndex],
    );
  }
}

class _DashboardOverview extends StatelessWidget {
  const _DashboardOverview();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.all(16),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _StatCard(
          title: 'Total Sales',
          value: '₦2,500,000',
          icon: Icons.attach_money,
          color: Colors.green,
        ),
        _StatCard(
          title: 'Total Orders',
          value: '156',
          icon: Icons.shopping_cart,
          color: Colors.blue,
        ),
        _StatCard(
          title: 'Total Users',
          value: '1,234',
          icon: Icons.people,
          color: Colors.orange,
        ),
        _StatCard(
          title: 'Products',
          value: '45',
          icon: Icons.laptop,
          color: Colors.purple,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _LaptopManagement extends StatelessWidget {
  const _LaptopManagement();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Laptop Management'));
  }
}

class _OrderManagement extends StatelessWidget {
  const _OrderManagement();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Order Management'));
  }
}

class _UserManagement extends StatelessWidget {
  const _UserManagement();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('User Management'));
  }
}

class _ReviewsManagement extends StatelessWidget {
  const _ReviewsManagement();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Reviews Management'));
  }
}
