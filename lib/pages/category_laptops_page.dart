import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laptop_harbour/models/category.dart';
import 'package:laptop_harbour/models/laptop.dart';
import 'package:laptop_harbour/pages/laptops_page.dart';
import 'package:laptop_harbour/providers/category_provider.dart';
import 'package:laptop_harbour/providers/laptop_provider.dart';
import 'package:provider/provider.dart';

class CategoryLaptopsPage extends StatefulWidget {
  final String categoryId;

  const CategoryLaptopsPage({super.key, required this.categoryId});

  @override
  State<CategoryLaptopsPage> createState() => _CategoryLaptopsPageState();
}

class _CategoryLaptopsPageState extends State<CategoryLaptopsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final laptopProvider = Provider.of<LaptopProvider>(
        context,
        listen: false,
      );
      laptopProvider.setSelectedCategory(widget.categoryId);
      _searchController.addListener(() {
        laptopProvider.setSearchQuery(_searchController.text);
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LaptopProvider>(
        context,
        listen: false,
      ).setSelectedCategory(null);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '₦',
      decimalDigits: 2,
    );

    return FutureBuilder<Category>(
      future: Provider.of<CategoryProvider>(
        context,
        listen: false,
      ).getCategory(widget.categoryId),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.hasData) {
          final categoryData = asyncSnapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text(categoryData.name),
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search in ${categoryData.name}...",
                        prefixIcon: Icon(
                          Icons.search,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Consumer<LaptopProvider>(
                    builder: (context, laptopProvider, child) {
                      return StreamBuilder<List<Laptop>>(
                        stream: laptopProvider.getLaptopsStream(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text(
                                'No laptops found in this category.',
                              ),
                            );
                          }
                          final laptops = snapshot.data!;
                          return GridView.builder(
                            padding: const EdgeInsets.all(16.0),
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
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(),
          body: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
