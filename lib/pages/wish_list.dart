import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laptop_harbour/components/app_drawer.dart';
import 'package:laptop_harbour/components/bottom_nav_bar.dart';
import 'package:laptop_harbour/components/header.dart';
import 'package:laptop_harbour/components/page_title.dart';
import 'package:laptop_harbour/components/wish_list_card.dart';
import 'package:laptop_harbour/pages/cart_page.dart';
import 'package:laptop_harbour/pages/home_page.dart';
import 'package:laptop_harbour/pages/orders_page.dart';
import 'package:laptop_harbour/pages/settings_page.dart';
import 'package:laptop_harbour/utils/responsive_text.dart';

class WishList extends StatefulWidget {
  const WishList({super.key});

  @override
  State<WishList> createState() => _WishListState();
}

class _WishListState extends State<WishList> {
  int _selectedIndex = 1;
  bool gridView = true;
  String currFilter = 'All Items';
  String selectedSort = 'Recently Added';
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

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const HomePage()));
        break;
      case 1:
        // Already on wishlist page, do nothing.
        break;
      case 2:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const CartPage()));
        break;
      case 3:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const OrdersPage()));
        break;
      case 4:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const SettingsPage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> titleList = ['My WishList', '5 items saved'];
    double width = MediaQuery.of(context).size.width;
    List<String> filterItems = ['All Items', 'In Stock', 'Out of Stock'];
    List<String> sortList = [
      'Recently Added',
      'Price: High to low',
      'Price: Low to High',
      'Highest Rated',
      'Name A-Z',
    ];

    return Scaffold(
      appBar: Header(),
      drawer: AppDrawer(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              PageTitle(
                titleList: titleList,
                trailer: InkWell(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[500]!, width: 0.75),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 7,
                      children: [
                        Icon(
                          Icons.share_outlined,
                          weight: 600,
                          size: getResponsiveFontSize(context, 15),
                          color: Colors.black,
                        ),
                        Text(
                          'Share',
                          style: GoogleFonts.poppins(
                            fontSize: getResponsiveFontSize(context, 15),
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsetsGeometry.symmetric(
                  vertical: 12,
                  horizontal: 15,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            'Select All',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              selectedItemBuilder: (context) {
                                return List.generate(filterItems.length, (
                                  index,
                                ) {
                                  return SizedBox(
                                    width: width * 0.15,
                                    child: Text(
                                      filterItems[index],
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                  );
                                });
                              },
                              items: List.generate(filterItems.length, (index) {
                                return DropdownMenuItem(
                                  value: filterItems[index],
                                  child: Row(
                                    spacing: 7,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        filterItems[index],
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              onChanged: (value) {
                                setState(() {
                                  currFilter = value!;
                                });
                              },
                              icon: Icon(Icons.keyboard_arrow_down_rounded),
                              isExpanded: false,
                              isDense: true,
                              elevation: 2,
                              borderRadius: BorderRadius.circular(12),
                              dropdownColor: Colors.white,
                              value: currFilter,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              selectedItemBuilder: (context) {
                                return List.generate(sortList.length, (index) {
                                  return SizedBox(
                                    width: width * 0.20,
                                    child: Text(
                                      sortList[index],
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                  );
                                });
                              },
                              items: List.generate(sortList.length, (index) {
                                return DropdownMenuItem(
                                  value: sortList[index],
                                  child: SizedBox(
                                    child: Text(
                                      sortList[index],
                                      overflow: TextOverflow.visible,
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                  ),
                                );
                              }),
                              onChanged: (value) {
                                setState(() {
                                  selectedSort = value!;
                                });
                              },
                              icon: Icon(Icons.keyboard_arrow_down_rounded),
                              isExpanded: false,
                              isDense: true,
                              elevation: 2,
                              borderRadius: BorderRadius.circular(12),
                              dropdownColor: Colors.white,
                              value: selectedSort,
                            ),
                          ),
                        ),
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
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Showing 5 of 5 items',
                        style: GoogleFonts.poppins(color: Colors.grey[500]),
                      ),
                    ),
                    SizedBox(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          dynamic laptop = laptopData[index];
                          return WishListCard(laptop: laptop);
                        },
                        itemCount: laptopData.length,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
