import 'package:flutter/material.dart';
import 'package:laptop_harbour/components/order_card.dart';

class OrderStatusTabBar extends StatelessWidget {
  const OrderStatusTabBar({super.key});
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5, 
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TabBar(
                isScrollable: true,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
                tabs: [
                  Tab(text: "All Orders"),
                  Tab(text: "Processing"),
                  Tab(text: "Shipped"),
                  Tab(text: "Delivered"),
                  Tab(text: "Cancelled"),
                ],
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height*0.7, // Added fixed height
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height*0.7,
                  child: const TabBarView(
                  
                    children: [
                      Center(child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            OrderCard()
                          ],
                        ),
                      )),
                      Center(child: Text("Processing Content")),
                      Center(child: Text("Shipped Content")),
                      Center(child: Text("Delivered Content")),
                      Center(child: Text("Cancelled Content")),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
