import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laptop_harbour/models/laptop.dart';
import 'package:laptop_harbour/services/laptop_service.dart';
import 'package:laptop_harbour/pages/add_laptop_page.dart';
import 'package:laptop_harbour/pages/laptop_details_page.dart';

class LaptopManagementPage extends StatefulWidget {
  const LaptopManagementPage({super.key});

  @override
  State<LaptopManagementPage> createState() => _LaptopManagementPageState();
}

class _LaptopManagementPageState extends State<LaptopManagementPage>
    with SingleTickerProviderStateMixin {
  final LaptopService _laptopService = LaptopService();
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  String _searchQuery = '';
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  List<Laptop> _filterLaptops(List<Laptop> laptops) {
    if (_searchQuery.isEmpty) return laptops;
    return laptops
        .where(
          (laptop) =>
              laptop.title.toLowerCase().contains(_searchQuery) ||
              laptop.price.toString().contains(_searchQuery),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Laptop Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              // Add haptic feedback
              HapticFeedback.selectionClick();
              // Navigate to add laptop page with animation
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const AddLaptopPage(), // Replace with your add page
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: animation.drive(
                            Tween(
                              begin: const Offset(1.0, 0.0),
                              end: Offset.zero,
                            ),
                          ),
                          child: child,
                        );
                      },
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search laptops...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          FocusScope.of(context).unfocus();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
              ),
            ),
          ),

          // Content Area
          Expanded(
            child: StreamBuilder<List<Laptop>>(
              stream: _laptopService.getLaptops(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                }

                if (snapshot.hasError) {
                  return _buildErrorState(() => setState(() {}));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                final filteredLaptops = _filterLaptops(snapshot.data!);

                if (filteredLaptops.isEmpty && _searchQuery.isNotEmpty) {
                  return _buildNoSearchResults();
                }

                return _buildLaptopList(filteredLaptops);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
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

  Widget _buildErrorState(VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
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
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Failed to load laptops. Please check your connection and try again.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.laptop_chromebook,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              'No laptops yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Start by adding your first laptop to the inventory',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to add laptop page
              },
              icon: const Icon(Icons.add),
              label: const Text('Add First Laptop'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search terms',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLaptopList(List<Laptop> laptops) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive grid/list based on screen width
        if (constraints.maxWidth > 600) {
          // Tablet/Desktop: Grid view
          return _buildGridView(laptops);
        } else {
          // Mobile: List view
          return _buildListView(laptops);
        }
      },
    );
  }

  Widget _buildGridView(List<Laptop> laptops) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: laptops.length,
        itemBuilder: (context, index) {
          final laptop = laptops[index];
          return _buildLaptopCard(laptop, index);
        },
      ),
    );
  }

  Widget _buildListView(List<Laptop> laptops) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: laptops.length,
      itemBuilder: (context, index) {
        final laptop = laptops[index];
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Interval(
                        index * 0.1,
                        1.0,
                        curve: Curves.easeOutQuart,
                      ),
                    ),
                  ),
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
                ),
                child: _buildLaptopTile(laptop, index),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLaptopCard(Laptop laptop, int index) {
    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _navigateToDetails(laptop),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildLaptopImage(laptop.image)),
              const SizedBox(height: 8),
              Text(
                laptop.title,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '₦${_formatPrice(laptop.price)}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildActionButton(
                    Icons.edit_outlined,
                    () => _navigateToEdit(laptop),
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    Icons.delete_outline,
                    () => _showDeleteDialog(laptop),
                    isDestructive: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLaptopTile(Laptop laptop, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Dismissible(
        key: Key(laptop.id!),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.delete,
            color: Theme.of(context).colorScheme.onError,
          ),
        ),
        confirmDismiss: (direction) => _showDeleteDialog(laptop),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: _buildLaptopImage(laptop.image, size: 60),
          title: Text(
            laptop.title,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '₦${_formatPrice(laptop.price)}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionButton(
                Icons.edit_outlined,
                () => _navigateToEdit(laptop),
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                Icons.delete_outline,
                () => _showDeleteDialog(laptop),
                isDestructive: true,
              ),
            ],
          ),
          onTap: () => _navigateToDetails(laptop),
        ),
      ),
    );
  }

  Widget _buildLaptopImage(String imageUrl, {double size = 80}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.laptop,
            size: size * 0.4,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: SizedBox(
                width: size * 0.3,
                height: size * 0.3,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    VoidCallback onPressed, {
    bool isDestructive = false,
  }) {
    return IconButton(
      icon: Icon(icon),
      onPressed: _isDeleting ? null : onPressed,
      color: isDestructive
          ? Theme.of(context).colorScheme.error
          : Theme.of(context).colorScheme.primary,
      style: IconButton.styleFrom(
        backgroundColor: isDestructive
            ? Theme.of(context).colorScheme.errorContainer
            : Theme.of(context).colorScheme.primaryContainer,
      ),
    );
  }

  String _formatPrice(dynamic price) {
    // Format price with thousand separators
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  Future<bool?> _showDeleteDialog(Laptop laptop) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Delete Laptop'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Are you sure you want to delete "${laptop.title}"?',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This action cannot be undone.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isDeleting
                ? null
                : () async {
                    setState(() => _isDeleting = true);
                    try {
                      await _laptopService.deleteLaptop(laptop.id!);
                      Navigator.pop(context, true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${laptop.title} deleted successfully'),
                          action: SnackBarAction(
                            label: 'UNDO',
                            onPressed: () {
                              // Implement undo functionality if supported
                            },
                          ),
                        ),
                      );
                    } catch (e) {
                      Navigator.pop(context, false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to delete laptop: $e'),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    } finally {
                      setState(() => _isDeleting = false);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: _isDeleting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _navigateToDetails(Laptop laptop) {
    HapticFeedback.selectionClick();
    // Navigate to laptop details with animation
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ProductDetailsPage(laptop: laptop), // Replace with your details page
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _navigateToEdit(Laptop laptop) {
    HapticFeedback.selectionClick();
    // Navigate to edit laptop page
    // Navigator.push(
    //   context,
    //   PageRouteBuilder(
    //     pageBuilder: (context, animation, secondaryAnimation) =>
    //         EditLaptopPage(laptop: laptop), // Replace with your edit page
    //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
    //       return SlideTransition(
    //         position: animation.drive(
    //           Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
    //         ),
    //         child: child,
    //       );
    //     },
    //   ),
    // );
  }
}


