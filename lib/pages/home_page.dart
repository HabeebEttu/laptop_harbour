import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:laptop_harbour/components/browse_category.dart';
import 'package:laptop_harbour/components/header.dart';
import 'package:laptop_harbour/components/hero_component.dart';
import 'package:laptop_harbour/components/stats.dart';

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
        'text1': 'Profesional',
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
    double width = MediaQuery.of(context).size.width;
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
                  SizedBox(height: 25),
                  Stats(statData: statData),
                  SizedBox(height: 25),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Shop by category',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      BrowseCategory(
                        height: height,
                        categoryData: categoryData,
                      ),
                      SizedBox(height: 10),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Browse Laptops',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.grid_on_outlined),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: BorderSide(
                                          color: Colors.grey[400]!,
                                          width: 0.75,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.list),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: BorderSide(
                                          color: Colors.grey[400]!,
                                          width: 0.75,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Card(
                            child: Padding(
                              padding: EdgeInsetsGeometry.symmetric(
                                horizontal: 15,
                                vertical: 25,
                              ),
                              child: Column(children: [
                                Row(
                                  children: [Icon(Icons.tune)],
                                )
                              ],),
                            ),
                          ),
                        ],
                      ),
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
