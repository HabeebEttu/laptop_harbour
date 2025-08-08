import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laptop_harbour/pages/laptops_page.dart';
import 'package:laptop_harbour/services/laptop_service.dart';
import 'package:laptop_harbour/components/laptop_list.dart';
import 'package:laptop_harbour/models/laptop.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> heroText = [
      {
        'title': 'Summer Sale Blast',
        'subtitle': 'Up to 30% of on premium laptops',
        'buttontext': 'Shop Now',
        'image': 'images/summer_sale.png',
      },
      {
        'title': 'New Arrivals',
        'subtitle': 'Discover the latest laptops in town',
        'buttontext': 'Shop Now',
        'image': 'images/sale2.png',
      },
      {
        'title': 'Unleash your power',
        'subtitle': 'top tier gaming laptops await ',
        'buttontext': 'Shop Now',
        'image': 'images/sale1.png',
      },
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "LaptopHarbor",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.blueAccent,
            ),
          ),
          const CircleAvatar(radius: 14, backgroundColor: Colors.pinkAccent),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
              ),

              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search laptops...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Hot Deals
            Text(
              'Hot Deals',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 150,
              width: MediaQuery.of(context).size.width * 0.92,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: heroText.length,
                itemBuilder: (context, index) {
                  final deal = heroText[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              deal['image']!,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(
                                  (0.4 * 255).round(),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
                              minHeight: 150,
                            ),
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              bottom: 10,
                              top: 20,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    deal['title']!,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  deal['subtitle']!,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                const Spacer(),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 15,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(deal['buttontext']!),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "Categories",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Categories
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount;
                if (constraints.maxWidth > 1200) {
                  crossAxisCount = 6;
                } else if (constraints.maxWidth > 800) {
                  crossAxisCount = 4;
                } else {
                  crossAxisCount = 2;
                }
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2,
                  children: const [
                    _CategoryTile(icon: Icons.videogame_asset, label: "Gaming"),
                    _CategoryTile(icon: Icons.attach_money, label: "Budget"),
                    _CategoryTile(icon: Icons.work, label: "Business"),
                    _CategoryTile(icon: Icons.palette, label: "Creative"),
                    _CategoryTile(icon: Icons.lightbulb, label: "Ultrabooks"),
                    _CategoryTile(icon: Icons.computer, label: "Workstations"),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Featured Laptops",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LaptopsPage(),
                      ),
                    );
                  },
                  child: const Text("See All"),
                ),
              ],
            ),
            const SizedBox(height: 10),

            StreamBuilder<List<Laptop>>(
              stream: LaptopService().getLaptops(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No top-rated laptops found.'),
                  );
                } else {
                  return LaptopList();
                }
              },
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Top-Rated Laptops",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LaptopsPage(),
                      ),
                    );
                  },
                  child: const Text("See All"),
                ),
              ],
            ),
            const SizedBox(height: 10),

            StreamBuilder<List<Laptop>>(
              stream: LaptopService().getTopRatedLaptops(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No top-rated laptops found.'),
                  );
                } else {
                  return LaptopList();
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: "Wishlist",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Cart",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Orders"),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CategoryTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: Colors.blue),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
