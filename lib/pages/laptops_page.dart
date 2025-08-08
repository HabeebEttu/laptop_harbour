import 'package:flutter/material.dart';
import 'package:laptop_harbour/models/laptop.dart';
import 'package:laptop_harbour/models/reviews.dart';
import 'package:laptop_harbour/models/specs.dart';
import 'package:laptop_harbour/pages/laptop_details_page.dart';

class LaptopsPage extends StatelessWidget {
  const LaptopsPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<Laptop> laptopData = [
      Laptop(
        id: '1',
        title: 'Hp Spectre x360 14',
        brand: 'HP',
        price: 1240.99,
        rating: 4.3,
        image: 'assets/images/sale1.png',
        reviews: [
          Reviews(
            userId: 'user1',
            rating: 4.0,
            comment: 'Great laptop!',
            reviewDate: DateTime.now(),
          ),
          Reviews(
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
          Reviews(
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Laptops'), centerTitle: true),
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
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.transparent,
                        ),
                        child: Row(
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
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {},
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.transparent,
                            ),
                            child: Row(
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
                        SizedBox(width: 10),
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {},
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blueAccent),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.blueAccent,
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.apps_rounded, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {},
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.transparent,
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.list, color: Colors.black87),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    mainAxisExtent: 250,
                  ),
                  itemBuilder: (context, index) {
                    final laptop = laptopData[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailsPage(laptop: laptop),
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
                                      borderRadius: BorderRadius.only(
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
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    laptop.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 7),
                                  Row(
                                    children: [
                                      Icon(
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
                                  SizedBox(height: 15),
                                  Text(
                                    "\$${laptop.price.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  itemCount: laptopData.length,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
