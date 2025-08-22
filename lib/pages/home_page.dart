import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laptop_harbour/components/bottom_nav_bar.dart';
import 'package:laptop_harbour/pages/cart_page.dart';
import 'package:laptop_harbour/pages/category_laptops_page.dart';
import 'package:laptop_harbour/pages/laptops_page.dart';
import 'package:laptop_harbour/pages/orders_page.dart';
import 'package:laptop_harbour/pages/profile_page.dart';
import 'package:laptop_harbour/pages/wish_list.dart';
import 'package:laptop_harbour/components/laptop_list.dart';
import 'package:laptop_harbour/models/laptop.dart';
import 'package:laptop_harbour/providers/laptop_provider.dart';
import 'package:laptop_harbour/providers/user_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _searchAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;
  bool _isSearchExpanded = false;
  bool _isSearching = false; // New state variable
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentDealPage = 0;

  @override
  void initState() {
    super.initState();
    
    // Clear any active category filters when HomePage initializes
    Provider.of<LaptopProvider>(context, listen: false).setSelectedCategory(null);

    // Initialize animation controllers
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));

    _searchController.addListener(() {
      setState(() {
        _isSearching = _searchController.text.isNotEmpty; // Update _isSearching
      });
      Provider.of<LaptopProvider>(
        context,
        listen: false,
      ).setSearchQuery(_searchController.text);
    });

    // Start fade animation
    _fadeAnimationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchAnimationController.dispose();
    _fadeAnimationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    // Haptic feedback for better UX
    HapticFeedback.lightImpact();

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const WishList(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          ),
        ).then((_) {
          if (mounted) setState(() => _selectedIndex = 0);
        });
        break;
      case 2:
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const CartPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          ),
        ).then((_) {
          if (mounted) setState(() => _selectedIndex = 0);
        });
        break;
      case 3:
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const OrdersPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          ),
        ).then((_) {
          if (mounted) setState(() => _selectedIndex = 0);
        });
        break;
      case 4:
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const ProfilePage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          ),
        ).then((_) {
          if (mounted) setState(() => _selectedIndex = 0);
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    List<Map<String, dynamic>> heroText = [
      {
        'title': 'Summer Sale Blast',
        'subtitle': 'Up to 30% off on premium laptops',
        'buttontext': 'Shop Now',
        'image': 'assets/images/summer_sale.png',
        'gradient': [Colors.orange.shade400, Colors.red.shade600],
      },
      {
        'title': 'New Arrivals',
        'subtitle': 'Discover the latest laptops in town',
        'buttontext': 'Shop Now',
        'image': 'assets/images/sale2.png',
        'gradient': [Colors.purple.shade400, Colors.blue.shade600],
      },
      {
        'title': 'Unleash Your Power',
        'subtitle': 'Top tier gaming laptops await',
        'buttontext': 'Shop Now',
        'image': 'assets/images/sale1.png',
        'gradient': [Colors.green.shade400, Colors.teal.shade600],
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
        title: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: Row(
            children: [
              if (!_isSearchExpanded) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.laptop_mac, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  "LaptopHarbor",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
              if (_isSearchExpanded)
                Expanded(
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: "Search laptops...",
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              _isSearchExpanded = false;
                              _searchController.clear();
                              _isSearching = false; // Explicitly set to false
                            });
                          },
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: false,
        actions: [
          if (!_isSearchExpanded) ...[
            IconButton(
              onPressed: () {
                setState(() {
                  _isSearchExpanded = true;
                });
              },
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.search,
                  color: theme.primaryColor,
                  size: 20,
                ),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.orange,
                      size: 20,
                    ),
                  ),
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 8,
                        minHeight: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                final profile = userProvider.userProfile;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfilePage()),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: theme.primaryColor,
                        backgroundImage: profile?.profilePic != null 
                            ? NetworkImage(profile!.profilePic!) 
                            : null,
                        child: profile?.profilePic == null
                            ? const Icon(Icons.person, size: 20, color: Colors.white)
                            : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: () async {
            // Add refresh functionality
            await Future.delayed(const Duration(seconds: 1));
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_isSearchExpanded) _buildSearchBar(theme, isDark),
                if (!_isSearching) ...[
                  const SizedBox(height: 24),
                  _buildHotDealsSection(heroText, theme),
                  const SizedBox(height: 32),
                  _buildCategoriesSection(theme),
                ],
                const SizedBox(height: 32),
                _buildFeaturedSection(theme),
                const SizedBox(height: 16),
                _buildLaptopsList(),
                const SizedBox(height: 100), // Bottom padding for nav bar
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "What laptop are you looking for?",
            hintStyle: TextStyle(color: Colors.grey.shade500),
            prefixIcon: Container(
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.search,
                color: theme.primaryColor,
                size: 22,
              ),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildHotDealsSection(List<Map<String, dynamic>> heroText, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange.shade400, Colors.red.shade500],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_fire_department, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Hot Deals',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.red.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'Limited Time',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentDealPage = index;
              });
            },
            itemCount: heroText.length,
            itemBuilder: (context, index) {
              final deal = heroText[index];
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: _buildDealCard(deal, theme),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            heroText.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: _currentDealPage == index ? 24 : 8,
              decoration: BoxDecoration(
                color: _currentDealPage == index
                    ? theme.primaryColor
                    : theme.primaryColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDealCard(Map<String, dynamic> deal, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                deal['image']!,
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: deal['gradient'] != null
                        ? [
                            (deal['gradient'][0] as Color).withOpacity(0.7),
                            (deal['gradient'][1] as Color).withOpacity(0.9),
                          ]
                        : [
                            Colors.black.withOpacity(0.4),
                            Colors.black.withOpacity(0.7),
                          ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Text(
                      deal['title']!,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      deal['subtitle']!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(25),
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  deal['buttontext']!,
                                  style: TextStyle(
                                    color: deal['gradient'] != null 
                                        ? deal['gradient'][1]
                                        : theme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 16,
                                  color: deal['gradient'] != null 
                                      ? deal['gradient'][1]
                                      : theme.primaryColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.category, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                "Categories",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount;
              if (constraints.maxWidth > 1200) {
                crossAxisCount = 6;
              } else if (constraints.maxWidth > 800) {
                crossAxisCount = 4;
              } else {
                crossAxisCount = 2;
              }
              
              final categories = [
                {'icon': Icons.videogame_asset, 'label': 'Gaming', 'id': 'dCtZpYdbwzP74JalrSpw', 'color': Colors.purple},
                {'icon': Icons.attach_money, 'label': 'Budget', 'id': 'T4fnNAd1GQ9bJtPFPmhF', 'color': Colors.green},
                {'icon': Icons.work, 'label': 'Business', 'id': 'AbTbLBWezeQOMTMxx6Ar', 'color': Colors.blue},
                {'icon': Icons.palette, 'label': 'Creative', 'id': '9LwU1JcuomUFlt9eYz5f', 'color': Colors.orange},
                {'icon': Icons.lightbulb, 'label': 'Ultrabooks', 'id': '7mWrpbdYyR6HvCGXsuyP', 'color': Colors.teal},
                {'icon': Icons.computer, 'label': 'Workstations', 'id': 'cI3W9v4gkCwVnjferkWY', 'color': Colors.indigo},
              ];
              
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return _CategoryTile(
                    icon: category['icon'] as IconData,
                    label: category['label'] as String,
                    color: category['color'] as Color,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryLaptopsPage(
                          categoryId: category['id'] as String,
                        ),
                      ),
                    ).then((_) {
                      Future.delayed(const Duration(seconds: 3), () {
                        if (mounted) {
                          Provider.of<LaptopProvider>(context, listen: false).clearFilters();
                        }
                      });
                    }),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade400, Colors.orange.shade500],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.star, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                "Featured Laptops",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground,
                ),
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: theme.primaryColor,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LaptopsPage()),
                      );
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "See All",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLaptopsList() {
    return Consumer<LaptopProvider>(
      builder: (context, laptopProvider, child) {
        return FutureBuilder<List<Laptop>>(
          future: laptopProvider.getLaptopsList(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            }

            if (snapshot.hasError) {
              return _buildErrorState();
            }

            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              final laptops = snapshot.data!;
              return LaptopList(laptops: laptops);
            }

            return _buildEmptyState();
          },
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading amazing laptops...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We couldn\'t load the laptops. Please try again.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade400, Colors.red.shade600],
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: () {
                  // Reload functionality
                  Provider.of<LaptopProvider>(context, listen: false).getLaptopsStream();
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Try Again',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.laptop_mac,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No laptops found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new arrivals!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<_CategoryTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                gradient: _isPressed
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.color.withOpacity(0.8),
                          widget.color,
                        ],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          isDark ? Colors.grey.shade800 : Colors.white,
                          isDark ? Colors.grey.shade700 : Colors.grey.shade50,
                        ],
                      ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _isPressed
                        ? widget.color.withOpacity(0.3)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: _isPressed ? 15 : 8,
                    offset: Offset(0, _isPressed ? 6 : 2),
                  ),
                ],
                border: Border.all(
                  color: _isPressed
                      ? widget.color.withOpacity(0.3)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isPressed
                            ? Colors.white.withOpacity(0.2)
                            : widget.color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.icon,
                        size: 24,
                        color: _isPressed ? Colors.white : widget.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _isPressed
                            ? Colors.white
                            : theme.colorScheme.onBackground,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
            