import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

class BrowseCategory extends StatelessWidget {
  const BrowseCategory({
    super.key,
    required this.height,
    required this.categoryData,
  });

  final double height;
  final List<Map<String, dynamic>> categoryData;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: height * 0.5,
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 14,
        ),
        itemCount: categoryData.length,
        itemBuilder: (context, index) {
          dynamic category = categoryData[index];
          return Container(
            decoration: BoxDecoration(
              border: BoxBorder.all(
                style: BorderStyle.solid,
                color: Colors.grey[400]!,
              ),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(
                  FontAwesomeIcons.laptop,
                  size: 31,
                  color: Colors.grey[400],
                ),
                Text(category['name'],
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  '${category['amount']} models',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
