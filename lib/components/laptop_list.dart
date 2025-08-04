import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laptop_harbour/models/laptop.dart';
import 'package:laptop_harbour/utils/responsive_text.dart';
import 'package:intl/intl.dart';

class LaptopList extends StatelessWidget {
  const LaptopList({super.key, required this.laptops});

  final List<Laptop> laptops;

  @override
  Widget build(BuildContext context) {
    List<dynamic> icons = [
      FontAwesomeIcons.microchip,
      FontAwesomeIcons.hardDrive,
      FontAwesomeIcons.display,
    ];
    NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: r'$',
      decimalDigits: 2,
    );
    return SizedBox(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: laptops.length,
        itemBuilder: (context, index) {
          dynamic laptop = laptops[index];
          return Column(
            children: [
              Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(laptop.image),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey[500]!,
                                    width: 0.75,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  laptop.tags[0],
                                  style: GoogleFonts.poppins(
                                    fontSize: getResponsiveFontSize(
                                      context,
                                      10,
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                children: List.generate(2, (index) {
                                  return Container(
                                    margin: const EdgeInsets.only(left: 5),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      laptop.tags[index + 1],
                                      style: GoogleFonts.poppins(
                                        fontSize: getResponsiveFontSize(
                                          context,
                                          10,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            laptop.title,
                            style: GoogleFonts.poppins(
                              fontSize: getResponsiveFontSize(context, 15),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Column(
                            children: List.generate(icons.length, (i) {
                              return Row(
                                children: [
                                  FaIcon(
                                    icons[i],
                                    color: Colors.grey[300],
                                    size: 15,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    laptop.specs[i],
                                    style: GoogleFonts.poppins(
                                      fontSize: getResponsiveFontSize(
                                        context,
                                        12,
                                      ),
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '${laptop.rating.toString()} (${laptop.reviews.toString()} reviews)',
                                  style: GoogleFonts.poppins(
                                    fontSize: getResponsiveFontSize(
                                      context,
                                      12,
                                    ),
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                currencyFormatter.format(laptop.price),
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: getResponsiveFontSize(context, 21),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: InkWell(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey[50],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.shopping_cart, size: 15),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Add to Cart',
                                      style: GoogleFonts.poppins(
                                        fontSize: getResponsiveFontSize(
                                          context,
                                          14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      width: 0.75,
                                      color: Colors.grey[500]!,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'View',
                                        style: GoogleFonts.poppins(
                                          fontSize: getResponsiveFontSize(
                                            context,
                                            14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }
}