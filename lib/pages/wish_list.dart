import 'package:flutter/material.dart';
import 'package:laptop_harbour/components/header.dart';
class WishList extends StatelessWidget {
  const WishList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(),
      body: SafeArea(child: 
      SingleChildScrollView(
        // child: ,
      )),
    );
  }
}