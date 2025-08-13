import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laptop_harbour/providers/order_provider.dart';
import 'package:laptop_harbour/widgets/order_card.dart';
import 'package:provider/provider.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders',style:TextStyle(fontWeight:FontWeight.bold,fontSize:13)),
        centerTitle: true,

      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (orderProvider.orders.isEmpty) {
            return const Center(
              child: Text('You have no orders yet.'),
            );
          }

          return ListView.builder(
            itemCount: orderProvider.orders.length,
            itemBuilder: (context, index) {
              final order = orderProvider.orders[index];
              return OrderCard(order: order);
            },
          );
        },
      ),
    );
  }
}