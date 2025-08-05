import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laptop_harbour/models/laptop.dart';
import 'package:laptop_harbour/services/product_service.dart';
import 'package:laptop_harbour/utils/responsive_text.dart';
import 'laptop_list.dart';

class BrowseLaptops extends StatefulWidget {
  const BrowseLaptops({super.key, required this.sortList});

  final List<String> sortList;

  @override
  State<BrowseLaptops> createState() => _BrowseLaptopsState();
}

class _BrowseLaptopsState extends State<BrowseLaptops> {
  String sortItem = 'Featured';
  double _price = 2500;
  String _selectedCategory = 'All';
  String _selectedBrand = 'All';
  final Map<String, int> categories = {
    'All': 845,
    'Gaming': 234,
    'Creator': 254,
    'Budget': 203,
    'Ultrabook': 54,
    'Business': 123,
  };

  final Map<String, int> brands = {
    'All': 845,
    'HP': 150,
    'Dell': 120,
    'Apple': 90,
    'Asus': 180,
    'Lenovo': 200,
  };
  late Future<List<Laptop>> _laptopsFuture;

  @override
  void initState() {
    super.initState();
    _laptopsFuture = ProductService.getLaptops();
    
  }


  @override
  Widget build(BuildContext context) {
    return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Browse Laptops',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: getResponsiveFontSize(context, 24),
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.grid_on_outlined),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.list),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(height: 10),
      Card(
          color: Colors.grey[50],
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.tune),
                  Padding(
                    padding: const EdgeInsets.only(left: 7),
                    child: Text(
                      'Filters',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: getResponsiveFontSize(context, 20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                'Sort by',
                style: TextStyle(
                  fontSize: getResponsiveFontSize(context, 16),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: sortItem,
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: widget.sortList.map((String item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: getResponsiveFontSize(context, 16),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        sortItem = newValue!;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                  "Price Range: \$0 - \$ ${_price.toInt()}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Slider(
                min: 0,
                max: 5000,
                value: _price,
                divisions: 100,
                onChanged: (value) {
                  setState(() => _price = value);
                },
              ),
              const SizedBox(height: 20),
              const Text(
                "Categories",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...categories.entries.map(
                (entry) => RadioListTile(
                  title: Text(
                    "${entry.key} (${entry.value})",
                    style: const TextStyle(fontSize: 14),
                  ),
                  value: entry.key,
                  groupValue: _selectedCategory,
                  onChanged: (value) {
                    setState(() => _selectedCategory = value as String);
                  },
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Brands",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...brands.entries.map(
                (entry) => RadioListTile(
                  title: Text(
                    "${entry.key} (${entry.value})",
                    style: const TextStyle(fontSize: 14),
                  ),
                  value: entry.key,
                  groupValue: _selectedBrand,
                  onChanged: (value) {
                    setState(() => _selectedBrand = value as String);
                  },
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'showing 6 of 1,247 laptops',
            style: GoogleFonts.poppins(
              fontSize: getResponsiveFontSize(context, 13),
              color: Colors.grey[700]!,
              fontWeight: FontWeight.w400,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[500]!, width: 0.75),
            ),
            child: const Row(
              children: [
                Icon(Icons.filter_alt_outlined, size: 15),
                Text('0 filters'),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      FutureBuilder<List<Laptop>>(
        future: _laptopsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No laptops found.'));
          } else {
            return LaptopList(laptops: snapshot.data!);
          }
        },
      ),
      const SizedBox(
        height: 10,
      ),
      OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        )),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
              child: Text(
            'Load More',
            style: GoogleFonts.poppins(
              // fontSize: getResponsiveFontSize(context, 1),
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          )),
        ),
      )
    ],
    );
  }
}
