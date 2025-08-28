import 'package:flutter/material.dart';
import 'package:laptop_harbour/models/laptop.dart';
import 'package:laptop_harbour/models/order.dart' as model_order;
import 'package:laptop_harbour/models/profile.dart';
import 'package:laptop_harbour/providers/theme_provider.dart';
import 'package:laptop_harbour/providers/user_provider.dart';
import 'package:laptop_harbour/services/order_service.dart';
import 'package:laptop_harbour/services/user_service.dart';
import 'package:provider/provider.dart';
import 'package:laptop_harbour/providers/laptop_provider.dart';
import 'package:laptop_harbour/pages/admin/admin_orders_page.dart';
import 'package:intl/intl.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        elevation: 0,
        actions: [
          Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return IconButton(
                  onPressed: () {
                    themeProvider.toggleTheme();
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      themeProvider.isDarkMode
                          ? Icons.light_mode
                          : Icons.dark_mode,
                      color: themeProvider.isDarkMode
                          ? Colors.grey[300]
                          : theme.primaryColor,
                      size: 20,
                    ),
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              _buildWelcomeCard(),
              const SizedBox(height: 24),

              // Statistics cards
              _buildStatsSection(),
              const SizedBox(height: 24),

              
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Main action cards
              _buildActionCards(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Consumer<UserProvider>(builder: (context, userProvider, child) {
      if (userProvider.userProfile == null) {
        return const Center(child: CircularProgressIndicator());
      }
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome back, ${userProvider.userProfile!.firstName}!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
              const SizedBox(height: 8),
              Text(
                'Manage your store efficiently',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/add_laptop'),
                      icon: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
                      label: Text(
                        'Quick Add',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.onPrimary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildStatsSection() {
    return FutureBuilder<List<Laptop>>(
      future: Provider.of<LaptopProvider>(context).getLaptopsList(),
      builder: (context, laptopSnapshot) {
        return StreamBuilder<List<model_order.Order>>(
          stream: OrderService().getAllOrders(),
          builder: (context, orderSnapshot) {
            return StreamBuilder<List<Profile>>(
              stream: UserService().getAllUsers(),
              builder: (context, userSnapshot) {
                if (laptopSnapshot.connectionState == ConnectionState.waiting ||
                    orderSnapshot.connectionState == ConnectionState.waiting ||
                    userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (laptopSnapshot.hasError ||
                    orderSnapshot.hasError ||
                    userSnapshot.hasError) {
                  return Center(
                      child: Text(
                          'Error: ${laptopSnapshot.error ?? orderSnapshot.error ?? userSnapshot.error}'));
                } else {
                  final totalLaptops = laptopSnapshot.data?.length ?? 0;
                  final totalOrders = orderSnapshot.data?.length ?? 0;
                  final totalUsers = userSnapshot.data?.length ?? 0;

                  double totalRevenue = 0.0;
                  if (orderSnapshot.hasData) {
                    for (var order in orderSnapshot.data!) {
                      if (order.status == 'Delivered') {
                        totalRevenue += order.totalPrice;
                      }
                    }
                  }

                  final Map<String, dynamic> dashboardStats = {
                    'Total Laptops': totalLaptops,
                    'Total Orders': totalOrders,
                    'Total Users': totalUsers,
                    'Revenue': totalRevenue,
                  };

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overview',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.27,
                        children: dashboardStats.entries.map((entry) {
                          return _buildStatCard(entry.key, entry.value);
                        }).toList(),
                      ),
                    ],
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(String title, dynamic value) {
    String displayValue;
    if (title == 'Revenue') {
      displayValue = NumberFormat.currency(symbol: '₦', decimalDigits: 2).format(value);
    } else {
      displayValue = value.toString();
    }

    IconData icon;
    Color color;
    String? subtitle;

    switch (title) {
      case 'Total Laptops':
        icon = Icons.laptop_chromebook_outlined;
        color = Colors.blue;
        
        break;
      case 'Total Orders':
        icon = Icons.shopping_bag_outlined;
        color = Colors.orange;
        break;
      case 'Total Users':
        icon = Icons.people_alt_outlined;
        color = Colors.green;
        break;
      case 'Revenue':
        icon = Icons.attach_money_outlined;
        color = Colors.red;
        break;
      default:
        icon = Icons.help_outline;
        color = Colors.grey;
    }

    return DashboardMetricCard(
      title: title,
      value: displayValue,
      icon: icon,
      color: color,
      subtitle: subtitle,
    );
  }

  Widget _buildActionCards() {
    final actions = [
      {
        'icon': Icons.laptop_mac,
        'title': 'Laptop Management',
        'subtitle': 'View and edit all laptops',
        'color': Theme.of(context).colorScheme.primary,
        'onTap': () => Navigator.pushNamed(context, '/laptop_management'),
      },
      {
        'icon': Icons.add_box_outlined,
        'title': 'Add New Laptop',
        'subtitle': 'Add a new laptop to the store',
        'color': Theme.of(context).colorScheme.secondary,
        'onTap': () => Navigator.pushNamed(context, '/add_laptop'),
      },
      {
        'icon': Icons.category_outlined,
        'title': 'Add New Category',
        'subtitle': 'Add a new product category',
        'color': Theme.of(context).colorScheme.tertiary,
        'onTap': () => Navigator.pushNamed(context, '/add_category'),
      },
      {
        'icon': Icons.people_outline,
        'title': 'User Management',
        'subtitle': 'Manage user roles and permissions',
        'color': Colors.purple,
        'onTap': () => Navigator.pushNamed(context, '/user_management'),
      },
      {
        'icon': Icons.shopping_bag_outlined,
        'title': 'Order Management',
        'subtitle': 'View and update customer orders',
        'color': Colors.teal,
        'onTap': () => Navigator.push(context, MaterialPageRoute(
          builder: (context) => const AdminOrdersPage(),
        )),
      },
      
    ];

    return Column(
      children: actions.map((action) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildActionCard(
            context,
            icon: action['icon'] as IconData,
            title: action['title'] as String,
            subtitle: action['subtitle'] as String,
            color: action['color'] as Color,
            onTap: action['onTap'] as VoidCallback,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// additional helper widget for organization
class DashboardMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const DashboardMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (subtitle != null)
                Flexible(
                  child: Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Flexible(
              child: Text(
                value,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
