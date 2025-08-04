import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  const CustomTabBar({super.key, this.tabTitles});
  final List<String>? tabTitles;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabTitles!.length,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          isScrollable: true,
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey[600],
          labelPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
          tabs: List.generate(tabTitles!.length, (index) {
            return Tab(
              child: Text(
                tabTitles![index],
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
