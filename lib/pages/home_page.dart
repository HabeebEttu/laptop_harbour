import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:laptop_harbour/components/browse_category.dart';
import 'package:laptop_harbour/components/header.dart';
import 'package:laptop_harbour/components/hero_component.dart';
import 'package:laptop_harbour/components/stats.dart';
import 'package:laptop_harbour/utils/responsive_text.dart';
import '../components/browse_laptops.dart';

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
      'Newest',
    ];
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: Header(),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Laptop Harbour'),
            ),
            ListTile(
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
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
