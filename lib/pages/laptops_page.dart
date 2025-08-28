import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:laptop_harbour/models/category.dart';
import 'package:laptop_harbour/models/laptop.dart';
import 'package:laptop_harbour/providers/category_provider.dart';
import 'package:laptop_harbour/providers/laptop_provider.dart';
import 'package:provider/provider.dart';
import 'package:laptop_harbour/components/laptop_page_card.dart';

class LaptopsPage extends StatefulWidget {
  const LaptopsPage({super.key});

  @override
  State<LaptopsPage> createState() => _LaptopsPageState();
}

class _LaptopsPageState extends State<LaptopsPage>
    with TickerProviderStateMixin {
  bool _isGridView = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _filterAnimationController;
  late AnimationController _searchAnimationController;
  late Animation<double> _filterSlideAnimation;
  late Animation<double> _searchScaleAnimation;
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _filterSlideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _filterAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _searchScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _searchAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Start filter animation on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _filterAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filterAnimationController.dispose();
    _searchAnimationController.dispose();
    super.dispose();
  }

  // Responsive grid count based on screen width
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 2;
  }

  double _getMainAxisExtent(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 280;
    if (width > 800) return 270;
    return 255;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '₦',
      decimalDigits: 2,
    );
    final laptopProvider = Provider.of<LaptopProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar 
            if (_showSearch)
              AnimatedBuilder(
                animation: _searchScaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _searchScaleAnimation.value,
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: isTablet ? 24 : 16,
                        vertical: 8,
                      ),
                      child: _buildSearchBar(),
                    ),
                  );
                },
              ),

            // Filter and sorting controls
            AnimatedBuilder(
              animation: _filterSlideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_filterSlideAnimation.value * screenWidth, 0),
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: isTablet ? 24 : 16,
                      vertical: 8,
                    ),
                    child: _buildFilterControls(
                      laptopProvider,
                      categoryProvider,
                    ),
                  ),
                );
              },
            ),

            // Active filters display
            _buildActiveFilters(laptopProvider),

            // Laptops grid/list
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
                child: _buildLaptopsList(laptopProvider, currencyFormatter),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      title: Text(
        'Laptops',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 24,
          color: theme.appBarTheme.foregroundColor,
          letterSpacing: -0.5,
        ),
      ),
      centerTitle: true,
      backgroundColor: theme.appBarTheme.backgroundColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withOpacity(0.1),
      iconTheme: const IconThemeData(color: Colors.black87),
      actions: [
        // Search toggle button
        IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _showSearch ? Icons.search_off : Icons.search,
              key: ValueKey(_showSearch),
              color: theme.appBarTheme.foregroundColor,
            ),
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            setState(() {
              _showSearch = !_showSearch;
            });
            if (_showSearch) {
              _searchAnimationController.forward();
            } else {
              _searchAnimationController.reverse();
              _searchController.clear();
              setState(() => _searchQuery = '');
            }
          },
          tooltip: _showSearch ? 'Close search' : 'Search laptops',
        ),

        // popup menu button for more options
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: theme.appBarTheme.foregroundColor,
          ),
          onSelected: (value) {
            HapticFeedback.selectionClick();
            switch (value) {
              case 'refresh':
                _refreshData();
                break;
              case 'view_mode':
                _toggleViewMode();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'refresh',
              child: Row(
                children: [
                  Icon(Icons.refresh, size: 20),
                  SizedBox(width: 12),
                  Text('Refresh'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'view_mode',
              child: Row(
                children: [
                  Icon(
                    _isGridView ? Icons.view_list : Icons.grid_view,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(_isGridView ? 'List View' : 'Grid View'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search laptops...',
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 22),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[500], size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
      ),
    );
  }

  Widget _buildFilterControls(
    LaptopProvider laptopProvider,
    CategoryProvider categoryProvider,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Filter button
          Expanded(
            child: _buildControlButton(
              icon: Icons.tune,
              label: 'Filter',
              hasActiveFilter: laptopProvider.hasActiveFilters,
              onPressed: () =>
                  _showFilterDialog(context, laptopProvider, categoryProvider),
            ),
          ),

          const SizedBox(width: 12),

          // Sort button
          Expanded(child: _buildSortButton(laptopProvider)),

          const SizedBox(width: 12),

          // View toggle button
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  _isGridView ? Icons.view_list : Icons.grid_view,
                  key: ValueKey(_isGridView),
                  color: Theme.of(context).primaryColor,
                  size: 22,
                ),
              ),
              onPressed: _toggleViewMode,
              tooltip: _isGridView
                  ? 'Switch to list view'
                  : 'Switch to grid view',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool hasActiveFilter = false,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasActiveFilter
                ? Theme.of(context).primaryColor
                : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: hasActiveFilter
                  ? Theme.of(context).primaryColor
                  : Colors.black87,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: hasActiveFilter
                    ? Theme.of(context).primaryColor
                    : Colors.black87,
                fontWeight: hasActiveFilter ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (hasActiveFilter)
              Container(
                margin: const EdgeInsets.only(left: 6),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortButton(LaptopProvider laptopProvider) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        HapticFeedback.selectionClick();
        laptopProvider.setSortCriterion(value);
      },
      itemBuilder: (BuildContext context) => [
        _buildPopupMenuItem('none', 'Default', Icons.sort),
        _buildPopupMenuItem(
          'price_asc',
          'Price: Low to High',
          Icons.arrow_upward,
        ),
        _buildPopupMenuItem(
          'price_desc',
          'Price: High to Low',
          Icons.arrow_downward,
        ),
        _buildPopupMenuItem('rating', 'Rating', Icons.star),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.import_export, color: Colors.black87, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Sort',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(
    String value,
    String label,
    IconData icon,
  ) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildActiveFilters(LaptopProvider laptopProvider) {
    if (!laptopProvider.hasActiveFilters) return const SizedBox.shrink();

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (laptopProvider.selectedCategoryId != null)
            _buildFilterChip(
              'Category',
              onRemove: () => laptopProvider.setSelectedCategory(null),
            ),
          if (laptopProvider.minPrice != null ||
              laptopProvider.maxPrice != null)
            _buildFilterChip(
              'Price Range',
              onRemove: () => laptopProvider.setPriceRange(null, null),
            ),
          const SizedBox(width: 8),
          _buildClearAllChip(laptopProvider),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {required VoidCallback onRemove}) {
    return Container(
      margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onRemove();
            },
            child: Icon(
              Icons.close,
              size: 16,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClearAllChip(LaptopProvider laptopProvider) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        laptopProvider.clearFilters();
      },
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Clear All',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 4),
            Icon(Icons.clear_all, size: 16, color: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildLaptopsList(
    LaptopProvider laptopProvider,
    NumberFormat currencyFormatter,
  ) {
    return StreamBuilder<List<Laptop>>(
      stream: laptopProvider.getLaptopsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        List<Laptop> laptops = snapshot.data!;

        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          laptops = laptops
              .where(
                (laptop) => laptop.title.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
              )
              .toList();
        }

        if (laptops.isEmpty) {
          return _buildNoResultsState();
        }

        return RefreshIndicator(
          onRefresh: _refreshData,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isGridView
                ? _buildGridView(laptops, currencyFormatter)
                : _buildListView(laptops, currencyFormatter),
          ),
        );
      },
    );
  }

  Widget _buildGridView(List<Laptop> laptops, NumberFormat currencyFormatter) {
    final crossAxisCount = _getCrossAxisCount(context);
    final mainAxisExtent = _getMainAxisExtent(context);

    return GridView.builder(
      key: const ValueKey('grid'),
      padding: const EdgeInsets.only(bottom: 20, top: 8),
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: mainAxisExtent,
      ),
      itemCount: laptops.length,
      itemBuilder: (context, index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 50)),
          curve: Curves.easeOutBack,
          child: LaptopPageCard(
            laptop: laptops[index],
            currencyFormatter: currencyFormatter,
          ),
        );
      },
    );
  }

  Widget _buildListView(List<Laptop> laptops, NumberFormat currencyFormatter) {
    return ListView.separated(
      key: const ValueKey('list'),
      padding: const EdgeInsets.only(bottom: 20, top: 8),
      physics: const BouncingScrollPhysics(),
      itemCount: laptops.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 50)),
          curve: Curves.easeOutBack,
          child: LaptopPageCard(
            laptop: laptops[index],
            isGridView: false,
            currencyFormatter: currencyFormatter,
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading laptops...',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.laptop_chromebook, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text(
              'No laptops available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new arrivals',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: const Text('Clear search'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(
    BuildContext context,
    LaptopProvider laptopProvider,
    CategoryProvider categoryProvider,
  ) {
    HapticFeedback.lightImpact();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: _buildFilterDialog(laptopProvider, categoryProvider),
          ),
        );
      },
    );
  }

  Widget _buildFilterDialog(
    LaptopProvider laptopProvider,
    CategoryProvider categoryProvider,
  ) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Container(
            constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
            padding: const EdgeInsets.all(24),
            child: StreamBuilder<List<Category>>(
              stream: categoryProvider.getCategories(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final categories = snapshot.data!;

                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Icon(
                            Icons.tune,
                            color: Theme.of(context).primaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Filter Products',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.grey[100],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Category section
                      _buildFilterSection(
                        title: 'Category',
                        child: Column(
                          children: categories.map((category) {
                            final isSelected =
                                laptopProvider.selectedCategoryId ==
                                category.id;
                            return _buildCategoryOption(
                              category: category,
                              isSelected: isSelected,
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    laptopProvider.setSelectedCategory(null);
                                  } else {
                                    laptopProvider.setSelectedCategory(
                                      category.id,
                                    );
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Price range section
                      _buildFilterSection(
                        title: 'Price Range',
                        child: _buildPriceRangeSlider(laptopProvider, setState),
                      ),

                      const SizedBox(height: 32),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                laptopProvider.clearFilters();
                                Navigator.pop(context);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Theme.of(context).primaryColor,
                                side: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: const Text(
                                'Clear All',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Apply Filters',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildCategoryOption({
    required Category category,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey[400]!,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                category.name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRangeSlider(
    LaptopProvider laptopProvider,
    StateSetter setState,
  ) {
    final minPrice = laptopProvider.minPrice ?? 0;
    final maxPrice = laptopProvider.maxPrice ?? 5000000;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '₦${minPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: const Text(
                'to',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '₦${maxPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            activeTrackColor: Theme.of(context).primaryColor,
            inactiveTrackColor: Colors.grey[200],
            thumbColor: Theme.of(context).primaryColor,
            overlayColor: Theme.of(context).primaryColor.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            rangeThumbShape: const RoundRangeSliderThumbShape(
              enabledThumbRadius: 12,
            ),
            rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
            valueIndicatorColor: Theme.of(context).primaryColor,
            valueIndicatorTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: RangeSlider(
            values: RangeValues(minPrice, maxPrice),
            min: 0,
            max: 5000000,
            divisions: 500,
            labels: RangeLabels(
              '₦${minPrice.toStringAsFixed(0)}',
              '₦${maxPrice.toStringAsFixed(0)}',
            ),
            onChanged: (RangeValues values) {
              setState(() {
                laptopProvider.setPriceRange(values.start, values.end);
              });
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('₦0', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            Text(
              '₦5M+',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ],
    );
  }

  void _toggleViewMode() {
    HapticFeedback.lightImpact();
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  Future<void> _refreshData() async {
    HapticFeedback.lightImpact();
    final laptopProvider = Provider.of<LaptopProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );

    // Add your refresh logic here
    // For example:
    laptopProvider.refresh();
    // await categoryProvider.refreshCategories();

    // Show success feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Data refreshed successfully'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}
