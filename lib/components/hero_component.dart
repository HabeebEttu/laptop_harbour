import 'package:flutter/material.dart';
import 'package:laptop_harbour/utils/responsive_text.dart';

class HeroComponent extends StatelessWidget {
  const HeroComponent({super.key, required this.heroData});

  final List<Map<String, dynamic>> heroData;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.55,
      width: MediaQuery.of(context).size.width * 0.95,
      child: PageView.builder(
        itemCount: heroData.length,
        itemBuilder: (context, index) {
          dynamic hero = heroData[index];
          return Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.95,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(hero['image']),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.black.withOpacity(0.4),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hero['text1'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: getResponsiveFontSize(context, 28),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      hero['text2'],
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: getResponsiveFontSize(context, 28),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 300,
                      child: Text(
                        hero['text3'],
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: getResponsiveFontSize(context, 16)),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Wrap(
                  spacing: 10.0,
                  runSpacing: 10.0,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Shop Now'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueAccent,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text('Compare Models'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
