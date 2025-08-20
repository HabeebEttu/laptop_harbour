import 'package:flutter/material.dart';
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

class _LaptopsPageState extends State<LaptopsPage> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '₦',
      decimalDigits: 2,
    );
    final laptopProvider = Provider.of<LaptopProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Laptops',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.black,
            letterSpacing: 0.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      _showFilterDialog(
                        context,
                        laptopProvider,
                        categoryProvider,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.filter_alt_outlined,
                            color: Color(0xFF1A1A1A),
                            size: 22,
                          ),
                          SizedBox(width: 7),
                          Text(
                            'Filter',
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF1A1A1A),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          laptopProvider.setSortCriterion(value);
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'none',
                                child: Text('Sort by: Default'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'price_asc',
                                child: Text('Price: Low to High'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'price_desc',
                                child: Text('Price: High to Low'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'rating',
                                child: Text('Sort by: Rating'),
                              ),
                            ],
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.import_export,
                                color: Color(0xFF1A1A1A),
                                size: 22,
                              ),
                              SizedBox(width: 7),
                              Text(
                                'Sort',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF1A1A1A),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: Icon(
                            _isGridView ? Icons.view_list : Icons.grid_view,
                            color: const Color(0xFF1A1A1A),
                            size: 22,
                          ),
                          onPressed: () {
                            setState(() {
                              _isGridView = !_isGridView;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: StreamBuilder<List<Laptop>>(
                  stream: laptopProvider.getLaptopsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No laptops found.'));
                    }
                    final laptops = snapshot.data!;
                    if (_isGridView) {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              mainAxisExtent: 255,
                            ),
                        itemBuilder: (context, index) {
                          final laptop = laptops[index];
                          return LaptopPageCard(
                            laptop: laptop,
                            currencyFormatter: currencyFormatter,
                          );
                        },
                        itemCount: laptops.length,
                      );
                    } else {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: laptops.length,
                        itemBuilder: (context, index) {
                          final laptop = laptops[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: LaptopPageCard(
                              laptop: laptop,
                              isGridView: false,
                              currencyFormatter: currencyFormatter,
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog(
    BuildContext context,
    LaptopProvider laptopProvider,
    CategoryProvider categoryProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                child: StreamBuilder<List<Category>>(
                  stream: categoryProvider.getCategories(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox(
                        height: 120,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final categories = snapshot.data!;
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Filter Products',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF222222),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Category',
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A73E8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...categories.map((category) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 2.0),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () {
                                  setState(() {
                                    if (laptopProvider.selectedCategoryId ==
                                        category.id) {
                                      laptopProvider.setSelectedCategory(null);
                                    } else {
                                      laptopProvider.setSelectedCategory(
                                        category.id,
                                      );
                                    }
                                  });
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color:
                                            laptopProvider.selectedCategoryId ==
                                                category.id
                                            ? const Color(0xFF1A73E8)
                                            : Colors.white,
                                        border: Border.all(
                                          color:
                                              laptopProvider
                                                      .selectedCategoryId ==
                                                  category.id
                                              ? const Color(0xFF1A73E8)
                                              : const Color(0xFFB0B0B0),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child:
                                          laptopProvider.selectedCategoryId ==
                                              category.id
                                          ? const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 16,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      category.name,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight:
                                            laptopProvider.selectedCategoryId ==
                                                category.id
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        color:
                                            laptopProvider.selectedCategoryId ==
                                                category.id
                                            ? const Color(0xFF1A73E8)
                                            : const Color(0xFF222222),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 22),
                          const Text(
                            'Price Range',
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A73E8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '₦${laptopProvider.minPrice?.toStringAsFixed(0) ?? '0'}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF222222),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '₦${laptopProvider.maxPrice?.toStringAsFixed(0) ?? '5000000'}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF222222),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 4,
                              activeTrackColor: const Color(0xFF1A73E8),
                              inactiveTrackColor: const Color(0xFFE0E0E0),
                              thumbColor: const Color(0xFF1A73E8),
                              overlayColor: const Color(0x221A73E8),
                              rangeThumbShape: const RoundRangeSliderThumbShape(
                                enabledThumbRadius: 11,
                              ),
                              rangeTrackShape:
                                  const RoundedRectRangeSliderTrackShape(),
                            ),
                            child: RangeSlider(
                              values: RangeValues(
                                laptopProvider.minPrice ?? 0,
                                laptopProvider.maxPrice ?? 5000000,
                              ),
                              min: 0,
                              max: 5000000,
                              divisions: 500,
                              labels: RangeLabels(
                                '₦${laptopProvider.minPrice?.toStringAsFixed(0) ?? '0'}',
                                '₦${laptopProvider.maxPrice?.toStringAsFixed(0) ?? '5000000'}',
                              ),
                              onChanged: (RangeValues values) {
                                setState(() {
                                  laptopProvider.setPriceRange(
                                    values.start,
                                    values.end,
                                  );
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    laptopProvider.clearFilters();
                                    Navigator.of(context).pop();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF1A73E8),
                                    side: const BorderSide(
                                      color: Color(0xFF1A73E8),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text(
                                    'Clear',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1A73E8),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Apply',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
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
      },
    );
  }
}
