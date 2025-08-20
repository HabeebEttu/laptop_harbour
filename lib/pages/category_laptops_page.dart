import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laptop_harbour/models/category.dart';
import 'package:laptop_harbour/models/laptop.dart';
import 'package:laptop_harbour/providers/category_provider.dart';
import 'package:laptop_harbour/providers/laptop_provider.dart';
import 'package:provider/provider.dart';
import 'package:laptop_harbour/components/laptop_page_card.dart';

class CategoryLaptopsPage extends StatefulWidget {
  final String categoryId;

  const CategoryLaptopsPage({super.key, required this.categoryId});

  @override
  State<CategoryLaptopsPage> createState() => _CategoryLaptopsPageState();
}

class _CategoryLaptopsPageState extends State<CategoryLaptopsPage> {
  final TextEditingController _searchController = TextEditingController();
  Category? categoryData;
  bool isLoadingCategory = true;
  String? categoryError;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Don't initialize providers here - do it in didChangeDependencies
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      _initializePage();
    }
  }

  void _initializePage() async {
    // First load the category
    await _loadCategory();

    // Then set up the laptop provider with the category
    if (mounted && categoryData != null) {
      final laptopProvider = Provider.of<LaptopProvider>(
        context,
        listen: false,
      );
      laptopProvider.setSelectedCategory(widget.categoryId);
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

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();

    // Clear the filters when leaving the page
    if (mounted) {
      try {
        final laptopProvider = Provider.of<LaptopProvider>(
          context,
          listen: false,
        );
        laptopProvider.setSelectedCategory(null);
        laptopProvider.setSearchQuery('');
      } catch (e) {
        debugPrint('Error clearing filters: $e');
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '₦',
      decimalDigits: 2,
    );

    // Show loading state while category is loading
    if (isLoadingCategory) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading category...'),
            ],
          ),
        ),
      );
    }

    // Show error state if category failed to load
    if (categoryError != null || categoryData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                categoryError ?? 'Failed to load category',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoadingCategory = true;
                    categoryError = null;
                  });
                  _loadCategory();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryData!.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final laptopProvider = Provider.of<LaptopProvider>(
                context,
                listen: false,
              );
              laptopProvider.refresh();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search in ${categoryData!.name}...",
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),

          // Laptops grid
          Expanded(
            child: Consumer<LaptopProvider>(
              builder: (context, laptopProvider, child) {
                // Show loading state from provider
                if (laptopProvider.isLoading &&
                    laptopProvider.filteredLaptops.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading laptops...'),
                      ],
                    ),
                  );
                }

                // Show error state from provider
                if (laptopProvider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wifi_off,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Connection Error',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Unable to load laptops. Please check your internet connection.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            laptopProvider.clearError();
                            laptopProvider.refresh();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                // Get current laptops (either from stream or provider state)
                final laptops = laptopProvider.filteredLaptops;

                // Show empty state
                if (laptops.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchController.text.isEmpty
                              ? Icons.laptop_chromebook
                              : Icons.search_off,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'No laptops found in this category'
                              : 'No laptops match your search',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        if (_searchController.text.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your search terms',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              _searchController.clear();
                            },
                            child: const Text('Clear Search'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                // Show laptops grid
                return RefreshIndicator(
                  onRefresh: () async {
                    laptopProvider.refresh();
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    physics: const AlwaysScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 250,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.65,
                        ),
                    itemCount: laptops.length,
                    itemBuilder: (context, index) {
                      final laptop = laptops[index];
                      return LaptopPageCard(
                        laptop: laptop,
                        currencyFormatter: currencyFormatter,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
