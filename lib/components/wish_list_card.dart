import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laptop_harbour/utils/responsive_text.dart';
import 'package:intl/intl.dart';

class WishListCard extends StatelessWidget {
  const WishListCard({super.key, required this.laptop});
  final Map<String, dynamic> laptop;

  @override
  Widget build(BuildContext context) {
    List<dynamic> icons = [
      FontAwesomeIcons.microchip,
      FontAwesomeIcons.hardDrive,
      FontAwesomeIcons.display,
    ];
    NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 2,
    );
    return Card(
      color: Colors.white,
      
      elevation: 0,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(laptop['image']),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 10, vertical: 6),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey[500]!,
                          width: 0.75,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        laptop['tags'][0],
                        style: GoogleFonts.poppins(
                          fontSize: getResponsiveFontSize(context, 10),
                        ),
                      ),
                    ),
                    Row(
                      spacing: 5,
                      children: List.generate(2, (index) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            laptop['tags'][index + 1],
                            style: GoogleFonts.poppins(
                              fontSize: getResponsiveFontSize(context, 10),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  laptop['title'],
                  style: GoogleFonts.poppins(
                    fontSize: getResponsiveFontSize(context, 15),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Column(
                  children: List.generate(icons.length, (i) {
                    return Row(
                      spacing: 5,
                      children: [
                        FaIcon(icons[i], color: Colors.grey[300], size: 15),
                        Text(
                          laptop['specs'][i],
                          style: GoogleFonts.poppins(
                            fontSize: getResponsiveFontSize(context, 12),
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
                    spacing: 5,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      Text(
                        '${laptop['rating'].toString()} (${laptop['reviews'].toString()} reviews)',
                        style: GoogleFonts.poppins(
                          fontSize: getResponsiveFontSize(context, 12),
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
                      currencyFormatter.format(laptop['price']),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: getResponsiveFontSize(context, 21),
                      ),
                    ),
                  ],
                ),
                Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: InkWell(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 30,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              spacing: 11,
                              children: [
                                Icon(Icons.shopping_cart, size: 15),
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
                    ),
                    InkWell(
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          border: BoxBorder.all(
                            width: 0.75,
                            color: Colors.grey[400]!,
                          ),
                        ),
                        child: Icon(Icons.delete_outline_outlined),
                      ),
                      onTap: () {},
                    ),
                    InkWell(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        spacing: 7,

                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 15,
                            ),
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
                              mainAxisSize: MainAxisSize.min,
                              spacing: 8,
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
                Container(
                  padding: EdgeInsets.symmetric(),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Added 1/5/2025',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[360],
                      fontWeight: FontWeight.w500,
                      fontSize: getResponsiveFontSize(context, 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
