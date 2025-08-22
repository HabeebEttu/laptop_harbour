import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:laptop_harbour/models/category.dart';
import 'package:laptop_harbour/models/laptop.dart';
import 'package:laptop_harbour/providers/category_provider.dart';
import 'package:laptop_harbour/providers/laptop_provider.dart';
import 'package:provider/provider.dart';
import 'package:laptop_harbour/components/laptop_page_card.dart';

enum ViewType { grid, list }

enum SortOption { nameAsc, nameDesc, priceAsc, priceDesc, ratingDesc }

class CategoryLaptopsPage extends StatefulWidget {
  final String categoryId;

  const CategoryLaptopsPage({super.key, required this.categoryId});

  @override
  State<CategoryLaptopsPage> createState() => _CategoryLaptopsPageState();
}

class _CategoryLaptopsPageState extends State<CategoryLaptopsPage>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  late AnimationController _searchAnimationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _searchAnimation;
  late Animation<double> _fabAnimation;

  Category? categoryData;
  bool isLoadingCategory = true;
  String? categoryError;
  bool _isInitialized = false;
  bool _isSearchExpanded = false;
  ViewType _viewType = ViewType.grid;
  SortOption _sortOption = SortOption.nameAsc;
  double _minPrice = 0;
  double _maxPrice = 5000000;
  RangeValues _priceRange = const RangeValues(0, 5000000);
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);

    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _searchAnimation = CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeInOut,
    );

    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );

    _scrollController.addListener(_onScroll);
    _fabAnimationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      _initializePage();
    }
  }

  void _onScroll() {
    if (_scrollController.offset > 100 && !_fabAnimation.isDismissed) {
      _fabAnimationController.reverse();
    } else if (_scrollController.offset <= 100 && !_fabAnimation.isCompleted) {
      _fabAnimationController.forward();
    }
  }

  void _initializePage() async {
    await _loadCategory();

    if (mounted && categoryData != null) {
      final laptopProvider = Provider.of<LaptopProvider>(
        context,
        listen: false,
      );
      laptopProvider.setSelectedCategory(widget.categoryId);

      // Set initial price range based on available laptops
      _setPriceRange();
    }
  }

  void _setPriceRange() {
    final laptopProvider = Provider.of<LaptopProvider>(context, listen: false);
    final laptops = laptopProvider.filteredLaptops;

    if (laptops.isNotEmpty) {
      final prices = laptops.map((l) => l.price).toList()..sort();
      setState(() {
        _minPrice = prices.first.toDouble();
        _maxPrice = prices.last.toDouble();
        _priceRange = RangeValues(_minPrice, _maxPrice);
      });
    }
  }

  Future<void> _loadCategory() async {
    try {
      final categoryProvider = Provider.of<CategoryProvider>(
        context,
        listen: false,
      );
      final category = await categoryProvider.getCategory(widget.categoryId);

      if (mounted) {
        setState(() {
          categoryData = category;
          isLoadingCategory = false;
          categoryError = null;
        });
      }
    } catch (e) {
      debugPrint('Error loading category: $e');
      if (mounted) {
        setState(() {
          isLoadingCategory = false;
          categoryError = e.toString();
        });
      }
    }
  }

  void _onSearchChanged() {
    if (mounted && categoryData != null) {
      final laptopProvider = Provider.of<LaptopProvider>(
        context,
        listen: false,
      );
      laptopProvider.setSearchQuery(_searchController.text);
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
    });

    if (_isSearchExpanded) {
      _searchAnimationController.forward();
    } else {
      _searchAnimationController.reverse();
      _searchController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void _toggleViewType() {
    setState(() {
      _viewType = _viewType == ViewType.grid ? ViewType.list : ViewType.grid;
    });
  }

  List<Laptop> _sortLaptops(List<Laptop> laptops) {
    final sorted = List<Laptop>.from(laptops);

    switch (_sortOption) {
      case SortOption.nameAsc:
        sorted.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOption.nameDesc:
        sorted.sort((a, b) => b.title.compareTo(a.title));
        break;
      case SortOption.priceAsc:
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceDesc:
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.ratingDesc:
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }

    return sorted.where((laptop) {
      return laptop.price >= _priceRange.start &&
          laptop.price <= _priceRange.end;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    _searchAnimationController.dispose();
    _fabAnimationController.dispose();

    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1200;

    final currencyFormatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '₦',
      decimalDigits: 0,
    );

    if (isLoadingCategory) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...'), elevation: 0),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 24),
              Text(
                'Loading category...',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    if (categoryError != null || categoryData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error'), elevation: 0),
        body: _buildErrorState(),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchAndFilters(isTablet, isDesktop),
          if (_showFilters) _buildFilterPanel(),
          Expanded(
            child: _buildLaptopsList(currencyFormatter, isTablet, isDesktop),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 1,
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _isSearchExpanded
            ? TextField(
                key: const ValueKey('search_field'),
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Search in ${categoryData!.name}...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey[400]),
                ),
                style: const TextStyle(color: Colors.white),
              )
            : Text(
                key: const ValueKey('category_title'),
                categoryData!.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
      ),
      actions: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isSearchExpanded
              ? IconButton(
                  key: const ValueKey('close_search'),
                  icon: const Icon(Icons.close),
                  onPressed: _toggleSearch,
                )
              : Row(
                  key: const ValueKey('action_buttons'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _toggleSearch,
                    ),
                    IconButton(
                      icon: Icon(
                        _viewType == ViewType.grid
                            ? Icons.list
                            : Icons.grid_view,
                      ),
                      onPressed: _toggleViewType,
                    ),
                    PopupMenuButton<SortOption>(
                      icon: const Icon(Icons.sort),
                      onSelected: (option) {
                        setState(() {
                          _sortOption = option;
                        });
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: SortOption.nameAsc,
                          child: ListTile(
                            leading: Icon(Icons.sort_by_alpha),
                            title: Text('Name A-Z'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: SortOption.nameDesc,
                          child: ListTile(
                            leading: Icon(Icons.sort_by_alpha),
                            title: Text('Name Z-A'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: SortOption.priceAsc,
                          child: ListTile(
                            leading: Icon(Icons.attach_money),
                            title: Text('Price Low-High'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: SortOption.priceDesc,
                          child: ListTile(
                            leading: Icon(Icons.attach_money),
                            title: Text('Price High-Low'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: SortOption.ratingDesc,
                          child: ListTile(
                            leading: Icon(Icons.star),
                            title: Text('Highest Rated'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters(bool isTablet, bool isDesktop) {
    if (_isSearchExpanded) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search in ${categoryData!.name}...",
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: _showFilters
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.filter_list,
                color: _showFilters
                    ? Colors.white
                    : Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Price Range',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _priceRange = RangeValues(_minPrice, _maxPrice);
                  });
                },
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RangeSlider(
            values: _priceRange,
            min: _minPrice,
            max: _maxPrice,
            divisions: 20,
            labels: RangeLabels(
              NumberFormat.currency(
                locale: 'en_US',
                symbol: '₦',
                decimalDigits: 0,
              ).format(_priceRange.start),
              NumberFormat.currency(
                locale: 'en_US',
                symbol: '₦',
                decimalDigits: 0,
              ).format(_priceRange.end),
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _priceRange = values;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                NumberFormat.currency(
                  locale: 'en_US',
                  symbol: '₦',
                  decimalDigits: 0,
                ).format(_priceRange.start),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                NumberFormat.currency(
                  locale: 'en_US',
                  symbol: '₦',
                  decimalDigits: 0,
                ).format(_priceRange.end),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLaptopsList(
    NumberFormat currencyFormatter,
    bool isTablet,
    bool isDesktop,
  ) {
    return Consumer<LaptopProvider>(
      builder: (context, laptopProvider, child) {
        if (laptopProvider.isLoading &&
            laptopProvider.filteredLaptops.isEmpty) {
          return _buildLoadingState();
        }

        if (laptopProvider.error != null) {
          return _buildNetworkErrorState(laptopProvider);
        }

        final rawLaptops = laptopProvider.filteredLaptops;
        final laptops = _sortLaptops(rawLaptops);

        if (laptops.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: () async {
            laptopProvider.refresh();
          },
          child: _buildLaptopsGrid(
            laptops,
            currencyFormatter,
            isTablet,
            isDesktop,
          ),
        );
      },
    );
  }

  Widget _buildLaptopsGrid(
    List<Laptop> laptops,
    NumberFormat currencyFormatter,
    bool isTablet,
    bool isDesktop,
  ) {
    if (_viewType == ViewType.list) {
      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: laptops.length,
        itemBuilder: (context, index) {
          final laptop = laptops[index];
          return AnimatedContainer(
  duration: const Duration(milliseconds: 200),
  margin: const EdgeInsets.only(bottom: 12),
  child: Material(
    elevation: 2,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: () {
        // Navigate to product details
        HapticFeedback.lightImpact();
      },
      onLongPress: () {
        // Show quick actions menu
        HapticFeedback.mediumImpact();
        // Add to favorites, share, etc.
      },
      borderRadius: BorderRadius.circular(12),
      splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Image container with loading state and error handling
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[100],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image(
                image: laptop.image.startsWith('http')
                    ? NetworkImage(laptop.image)
                    : AssetImage(laptop.image) as ImageProvider,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.laptop,
                      color: Colors.grey[400],
                      size: 30,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Content section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title with better typography
                Text(
                  laptop.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 8),
                
                // Price with better styling
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    currencyFormatter.format(laptop.price),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Rating and additional info row
                Row(
                  children: [
                    // Rating
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            laptop.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Action button
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
          ));
        },
      );
    }

    // Grid view
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(isTablet, isDesktop),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isDesktop ? 0.75 : 0.65,
      ),
      itemCount: laptops.length,
      itemBuilder: (context, index) {
        final laptop = laptops[index];
        return Hero(
          tag: 'laptop-${laptop.id}',
          child: LaptopPageCard(
            laptop: laptop,
            currencyFormatter: currencyFormatter,
          ),
        );
      },
    );
  }

  int _getCrossAxisCount(bool isTablet, bool isDesktop) {
    if (isDesktop) return 4;
    if (isTablet) return 3;
    return 2;
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: _fabAnimation,
          child: FloatingActionButton.small(
            heroTag: "scroll_to_top",
            onPressed: () {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
            child: const Icon(Icons.keyboard_arrow_up),
          ),
        ),
        const SizedBox(height: 8),
        ScaleTransition(
          scale: _fabAnimation,
          child: FloatingActionButton(
            heroTag: "refresh",
            onPressed: () {
              _refreshIndicatorKey.currentState?.show();
            },
            child: const Icon(Icons.refresh),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              categoryError ?? 'Could not load the category. Please try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isLoadingCategory = true;
                  categoryError = null;
                });
                _loadCategory();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Loading laptops...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkErrorState(LaptopProvider laptopProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              size: 80,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Network Error',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Could not load laptops. Please check your internet connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                laptopProvider.clearError();
                laptopProvider.refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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
            Icon(
              _searchController.text.isEmpty
                  ? Icons.laptop_chromebook
                  : Icons.search_off,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              _searchController.text.isEmpty
                  ? 'No laptops found'
                  : 'No laptops match your search',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              _searchController.text.isEmpty
                  ? 'This category is currently empty'
                  : 'Try adjusting your search terms or filters',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
            if (_searchController.text.isNotEmpty || _showFilters) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _priceRange = RangeValues(_minPrice, _maxPrice);
                    _showFilters = false;
                  });
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear Filters'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
