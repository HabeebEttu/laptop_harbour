import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:laptop_harbour/components/browse_category.dart';
import 'package:laptop_harbour/components/header.dart';
import 'package:laptop_harbour/components/hero_component.dart';
import 'package:laptop_harbour/components/stats.dart';
import 'package:laptop_harbour/utils/responsive_text.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> heroData = [
      {
        'text1': 'Find your perfect',
        'text2': 'Laptop',
        'text3':
            'Discover the latest laptops from top brands. Compare specs, read reviews, and find the perfect device for your needs',
        'image': 'assets/images/page1.jpg',
      },
      {
        'text1': 'Unleash your',
        'text2': 'Gaming',
        'text3':
            'Experience ultimate performance with gaming laptops featuring the latest graphics cards and processors.',
        'image': 'assets/images/page2.jpg',
      },
      {
        'text1': 'Professional',
        'text2': 'Productivity',
        'text3':
            'Boost your productivity with business laptops designed for productivity and creative workflows',
        'image': 'assets/images/page3.jpg',
      },
    ];
    List<Map<String, dynamic>> statData = [
      {
        'icon': FontAwesomeIcons.truck,
        'title': 'Free Shipping',
        'subtitle': r'on Orders Over $100',
      },
      {
        'icon': FontAwesomeIcons.medal,
        'title': 'Best Warranty',
        'subtitle': r'3-year protection',
      },
      {
        'icon': FontAwesomeIcons.chartLine,
        'title': 'Price Match',
        'subtitle': r'Guaranteed best price',
      },
    ];
    List<Map<String, dynamic>> categoryData = [
      {'name': 'Gaming', 'amount': 234},
      {'name': 'Creator', 'amount': 254},
      {'name': 'Budget', 'amount': 203},
      {'name': 'Ultrabook', 'amount': 54},
      {'name': 'Business', 'amount': 123},
    ];
    List<String> sortList = [
      'Featured',
      'Price: Low to High',
      'Price: High to Low',
      'Rating',
      'Newest'
    ];
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: Header(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  HeroComponent(heroData: heroData),
                  const SizedBox(height: 25),
                  Stats(statData: statData),
                  const SizedBox(height: 25),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Shop by category',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: getResponsiveFontSize(context, 24),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      BrowseCategory(
                        height: height,
                        categoryData: categoryData,
                      ),
                      const SizedBox(height: 10),
                      BrowseLaptops(sortList: sortList),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BrowseLaptops extends StatefulWidget {
  const BrowseLaptops({
    super.key,
    required this.sortList,
  });

  final List<String> sortList;

  @override
  State<BrowseLaptops> createState() => _BrowseLaptopsState();
}

class _BrowseLaptopsState extends State<BrowseLaptops> {
  String sortItem = 'Featured';

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
                      side: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
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
                      side: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
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
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 20,
            ),
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
                  style: TextStyle(fontSize: getResponsiveFontSize(context, 16)),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!, width: 1)),
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
                                fontSize: getResponsiveFontSize(context, 16)),
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
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
