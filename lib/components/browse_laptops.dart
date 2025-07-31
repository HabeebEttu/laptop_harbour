import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final List<Map<String, dynamic>> laptopData = [
    {
      'discount': '8% OFF',
      'tags': ['Apple', 'Pro', 'High Performance'],
      'title':
          'MacBook Pro 16-inch M3 Pro with 18GB Unified Memory and 512GB SSD Storage',
      'specs': ['Apple M3 Pro', '512GB SSD', '16.2-inch Liquid Retina XDR'],
      'rating': 4.8,
      'reviews': 1247,
      'price': 2399,
      'oldPrice': 2599,
      'image': 'assets/images/laptop1.jpg',
    },
    {
      'discount': '5% OFF',
      'tags': ['HP', 'Gaming', 'RTX 4060'],
      'title': 'HP Omen 16 Gaming Laptop, Intel i7, 16GB RAM, 1TB SSD',
      'specs': ['Intel Core i7', '16GB RAM', '1TB SSD', 'RTX 4060'],
      'rating': 4.6,
      'reviews': 980,
      'price': 1799,
      'oldPrice': 1899,
      'image': 'assets/images/laptop2.jpg',
    },
    {
      'discount': '10% OFF',
      'tags': ['Dell', 'Business', 'Touchscreen'],
      'title': 'Dell XPS 13 Plus, 12th Gen i5, 8GB RAM, 512GB SSD',
      'specs': [
        'Intel Core i5',
        '8GB RAM',
        '512GB SSD',
        '13.4-inch Touchscreen',
      ],
      'rating': 4.7,
      'reviews': 1103,
      'price': 1299,
      'oldPrice': 1449,
      'image': 'assets/images/laptop3.jpg',
    },
  ];

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
          color: Colors.white,
          elevation: 2,
          shadowColor: Colors.black12,
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
                  "Price Range: \$0 - \$${_price.toInt()}",
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
        SizedBox(height: 10),
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
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[500]!, width: 0.75),
              ),
              child: Row(
                children: [
                  Icon(Icons.filter_alt_outlined, size: 15),
                  Text('0 filters'),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        LaptopList(laptopData: laptopData),
        SizedBox(
          height: 10,
        ),
        OutlinedButton(
          onPressed: () {
          
        },
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(8),
            )
          ),
          child: Container(
            width: double.infinity,
            padding: EdgeInsetsGeometry.symmetric(vertical: 10),
            child: Center(child: Text('Load More',
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

