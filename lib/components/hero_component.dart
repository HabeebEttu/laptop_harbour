import 'package:flutter/material.dart';
import 'package:laptop_harbour/utils/responsive_text.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HeroComponent extends StatefulWidget {
  const HeroComponent({super.key, required this.heroData});

  final List<Map<String, dynamic>> heroData;

  @override
  State<HeroComponent> createState() => _HeroComponentState();
}

class _HeroComponentState extends State<HeroComponent> {
  final _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.55,
      width: MediaQuery.of(context).size.width * 0.95,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.heroData.length,
              itemBuilder: (context, index) {
                dynamic hero = widget.heroData[index];
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
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 600) {
                            return Wrap(
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
                            );
                          } else {
                            return Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
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
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () {},
                                    child: const Text('Compare Models'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side:
                                          const BorderSide(color: Colors.white),
                                      shape: const StadiumBorder(),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 32, vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          SmoothPageIndicator(
            controller: _controller,
            count: widget.heroData.length,
            effect: const WormEffect(
              dotHeight: 8,
              dotWidth: 8,
              activeDotColor: Colors.blueAccent,
            ),
          ),
        ],
      ),
    );
  }
}
