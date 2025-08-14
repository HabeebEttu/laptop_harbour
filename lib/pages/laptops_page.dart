import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laptop_harbour/models/category.dart';
import 'package:laptop_harbour/models/laptop.dart';
import 'package:laptop_harbour/pages/laptop_details_page.dart'
    as laptop_details;
import 'package:laptop_harbour/providers/category_provider.dart';
import 'package:laptop_harbour/providers/laptop_provider.dart';
import 'package:provider/provider.dart';

class LaptopsPage extends StatefulWidget {
  const LaptopsPage({super.key});

  @override
  State<LaptopsPage> createState() => _LaptopsPageState();
}

class _LaptopsPageState extends State<LaptopsPage> {
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LaptopProvider>(context, listen: false).fetchLaptops();
    });
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Laptops'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
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
                            context, laptopProvider, categoryProvider);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.transparent,
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.filter_alt_outlined,
                              color: Colors.black,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Filter',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
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
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.transparent,
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.import_export, color: Colors.black),
                                SizedBox(width: 10),
                                Text(
                                  'Sort',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: Icon(
                            _isGridView ? Icons.view_list : Icons.grid_view,
                          ),
                          onPressed: () {
                            setState(() {
                              _isGridView = !_isGridView;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                StreamBuilder<List<Laptop>>(
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
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          mainAxisExtent: 250,
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
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: laptops.length,
                        itemBuilder: (context, index) {
                          final laptop = laptops[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context, LaptopProvider laptopProvider,
      CategoryProvider categoryProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Laptops'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return StreamBuilder<List<Category>>(
                stream: categoryProvider.getCategories(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final categories = snapshot.data!;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Category'),
                      ...categories.map((category) {
                        return CheckboxListTile(
                          title: Text(category.name),
                          value: laptopProvider.selectedCategoryId == category.id,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                laptopProvider.setSelectedCategory(category.id);
                              } else {
                                laptopProvider.setSelectedCategory(null);
                              }
                            });
                          },
                        );
                      }).toList(),
                      const SizedBox(height: 20),
                      const Text('Price Range'),
                      RangeSlider(
                        values: RangeValues(
                          laptopProvider.minPrice ?? 0,
                          laptopProvider.maxPrice ?? 10000,
                        ),
                        min: 0,
                        max: 10000,
                        divisions: 100,
                        labels: RangeLabels(
                          '₦${laptopProvider.minPrice?.toStringAsFixed(0) ?? '0'}',
                          '₦${laptopProvider.maxPrice?.toStringAsFixed(0) ?? '10000'}',
                        ),
                        onChanged: (RangeValues values) {
                          setState(() {
                            laptopProvider.setPriceRange(values.start, values.end);
                          });
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                laptopProvider.clearFilters();
                Navigator.of(context).pop();
              },
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }
}

class LaptopPageCard extends StatelessWidget {
  final Laptop laptop;
  final bool isGridView;
  final NumberFormat currencyFormatter;

  const LaptopPageCard({
    super.key,
    required this.laptop,
    this.isGridView = true,
    required this.currencyFormatter,
  });

  @override
  Widget build(BuildContext context) {
    if (isGridView) {
      return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  laptop_details.ProductDetailsPage(laptop: laptop),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!, width: 0.87),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 138,
                width: double.infinity,
                child: Stack(
                  children: [
                    SizedBox(
                      height: 138,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(15),
                          topLeft: Radius.circular(15),
                        ),
                        child: laptop.image.startsWith('http')
                            ? Image.network(
                                laptop.image,
                                fit: BoxFit.fitHeight,
                                width: double.infinity,
                              )
                            : Image.asset(
                          laptop.image,
                          fit: BoxFit.fitHeight,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.white70,
                        radius: 18,
                        child: const Center(
                          child: Icon(
                            Icons.favorite_border,
                            color: Colors.black87,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      laptop.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(
                          laptop.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      currencyFormatter.format(laptop.price),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!, width: 0.87),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 140,
              height: 150,
              child: InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        laptop_details.ProductDetailsPage(laptop: laptop),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                  child: Image.asset(laptop.image, fit: BoxFit.cover),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              laptop_details.ProductDetailsPage(laptop: laptop),
                        ),
                      ),

                      child: Text(
                        laptop.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(
                          "${laptop.rating}",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      currencyFormatter.format(laptop.price),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black12,
                radius: 18,
                child: Center(
                  child: Icon(
                    Icons.favorite_border,
                    color: Colors.black87,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
