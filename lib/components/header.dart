import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
@override
  final Size preferredSize;

  const Header({super.key}) : preferredSize = const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          
          const Text(
            'Laptop Harbor',
            style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
      ],
      automaticallyImplyLeading: true,
    );
  }
}