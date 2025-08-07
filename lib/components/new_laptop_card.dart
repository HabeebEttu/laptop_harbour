
import 'package:flutter/material.dart';
import 'package:laptop_harbour/models/laptop.dart';

class NewLaptopCard extends StatelessWidget {
  final Laptop laptop;

  const NewLaptopCard({super.key, required this.laptop});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(child: Placeholder()),
          const SizedBox(height: 8),
          Text(
            laptop.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            "\${laptop.price}",
            style: const TextStyle(color: Colors.blue, fontSize: 16),
          ),
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                i < laptop.rating.round()
                    ? Icons.star
                    : Icons.star_border,
                color: Colors.amber,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
