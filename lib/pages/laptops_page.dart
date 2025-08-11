import 'package:flutter/material.dart';
import 'package:laptop_harbour/models/laptop.dart';
import 'package:laptop_harbour/models/review.dart';
import 'package:laptop_harbour/models/specs.dart';
import 'package:laptop_harbour/pages/laptop_details_page.dart' as laptop_details;

class LaptopsPage extends StatefulWidget {
  const LaptopsPage({super.key});

  @override
  State<LaptopsPage> createState() => _LaptopsPageState();
}

class _LaptopsPageState extends State<LaptopsPage> {
  String _sortCriterion = 'none';
  bool _isGridView = true;

  final List<Laptop> laptopData = [
    Laptop(
      id: '1',
      title: 'Hp Spectre x360 14',
      brand: 'HP',
      price: 1240.99,
      rating: 4.3,
      image: 'assets/images/sale1.png',
      reviews: [
        Review(
          userId: 'user1',
          rating: 4.0,
          comment: 'Great laptop!',
          reviewDate: DateTime.now(),
        ),
        Review(
          userId: 'user2',
          rating: 5.0,
          comment: 'Amazing performance.',
          reviewDate: DateTime.now(),
        ),
      ],
      categoryId: '1',
      specs: Specs(
        processor: 'Intel Core i7',
        ram: '16GB',
        storage: '1TB SSD',
        display: '14" OLED',
      ),
      tags: ['2-in-1', 'OLED'],
    ),
    Laptop(
      id: '2',
      title: 'Dell Inspiron 15',
      brand: 'Dell',
      price: 1410.99,
      rating: 4.3,
      image: 'assets/images/sale2.png',
      reviews: [
        Review(
          userId: 'user3',
          rating: 4.5,
          comment: 'Good value for money.',
          reviewDate: DateTime.now(),
        ),
      ],
      categoryId: '1',
      specs: Specs(
        processor: 'Intel Core i5',
        ram: '8GB',
        storage: '512GB SSD',
        display: '15.6" FHD',
      ),
      tags: ['reliable', 'large-display'],
    ),
    Laptop(
      id: '3',
      title: 'Dell XPS 13',
      brand: 'Dell',
      price: 1045.99,
      rating: 4.2,
      image: 'assets/images/summer_sale.png',
      reviews: [],
      categoryId: '1',
      specs: Specs(
        processor: 'Intel Core i7',
        ram: '16GB',
        storage: '512GB SSD',
        display: '13.4" FHD+',
      ),
      tags: ['ultrabook', 'compact'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final displayLaptops = List<Laptop>.from(laptopData);

    if (_sortCriterion == 'price_asc') {
      displayLaptops.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortCriterion == 'price_desc') {
      displayLaptops.sort((a, b) => b.price.compareTo(a.price));
    } else if (_sortCriterion == 'rating') {
      displayLaptops.sort((a, b) => b.rating.compareTo(a.rating));
    }

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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Filter functionality is not yet implemented.')),
                        );
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
                            setState(() {
                              _sortCriterion = value;
                            });
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
                                Icon(Icons.import_export,
                                    color: Colors.black),
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
                          icon: Icon(_isGridView
                              ? Icons.view_list
                              : Icons.grid_view),
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
                if (_isGridView)
                  GridView.builder(
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
                      final laptop = displayLaptops[index];
                      return LaptopPageCard(laptop: laptop);
                    },
                    itemCount: displayLaptops.length,
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: displayLaptops.length,
                    itemBuilder: (context, index) {
                      final laptop = displayLaptops[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: LaptopPageCard(laptop: laptop, isGridView: false),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LaptopPageCard extends StatelessWidget {
  final Laptop laptop;
  final bool isGridView;

  const LaptopPageCard({super.key, required this.laptop, this.isGridView = true});

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
            border: Border.all(
              color: Colors.grey[300]!,
              width: 0.87,
            ),
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
                        child: Image.asset(
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
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
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
                      "\${laptop.price.toStringAsFixed(2)}",
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
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                  child: Image.asset(
                    laptop.image,
                    fit: BoxFit.cover,
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
                      Text(
                        laptop.title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(
                            "${laptop.rating}",
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "\${laptop.price.toStringAsFixed(2)}",
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
                    child: Icon(Icons.favorite_border,
                        color: Colors.black87, size: 20),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }
  }
}
