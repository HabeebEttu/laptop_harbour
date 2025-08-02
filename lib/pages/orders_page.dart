import 'package:flutter/material.dart';
import 'package:laptop_harbour/components/app_drawer.dart';
import 'package:laptop_harbour/components/header.dart';
import 'package:laptop_harbour/components/page_title.dart';
class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:Header() ,
      backgroundColor: Colors.white,
      drawer: AppDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageTitle(titleList: ['My Orders','Track and manage your laptop orders'])
            ],
          ),
        ),
        ),
      
    );
  }
}