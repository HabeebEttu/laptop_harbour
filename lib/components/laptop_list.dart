import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laptop_harbour/models/laptop.dart';
import 'package:laptop_harbour/pages/laptop_details_page.dart' as laptop_details;

class LaptopList extends StatefulWidget {
  final List<Laptop> laptops;

  const LaptopList({super.key, required this.laptops});

  @override
  State<LaptopList> createState() => _LaptopListState();
}

class _LaptopListState extends State<LaptopList> {
  String _sortCriterion = 'none';
  bool _isGridView = false;

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: r'₦',
      decimalDigits: 2,
    );

    final displayLaptops = List<Laptop>.from(widget.laptops);

    if (_sortCriterion == 'price_asc') {
      displayLaptops.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortCriterion == 'price_desc') {
      displayLaptops.sort((a, b) => b.price.compareTo(a.price));
    } else if (_sortCriterion == 'rating') {
      displayLaptops.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Filter functionality is not yet implemented.')),
                    );
                  },
                ),
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
                  child: const Row(
                    children: [
                      Text("Sort"),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ],
            ),
            IconButton(
              icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
              onPressed: () {
                setState(() {
                  _isGridView = !_isGridView;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_isGridView)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: displayLaptops.length,
            itemBuilder: (context, index) {
              final laptop = displayLaptops[index];
              return LaptopCard(
                  laptop: laptop, currencyFormatter: currencyFormatter);
            },
          )
        else
          SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: displayLaptops.length,
              itemBuilder: (context, index) {
                final laptop = displayLaptops[index];
                return Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 10),
                  child: LaptopCard(
                      laptop: laptop, currencyFormatter: currencyFormatter),
                );
              },
            ),
          ),
      ],
    );
  }
}

class LaptopCard extends StatelessWidget {
  const LaptopCard({
    super.key,
    required this.laptop,
    required this.currencyFormatter,
  });

  final Laptop laptop;
  final NumberFormat currencyFormatter;

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  laptop.image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              laptop.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              currencyFormatter.format(laptop.price),
              style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  laptop.rating.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
