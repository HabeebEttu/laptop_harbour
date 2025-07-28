import 'package:flutter/material.dart';
import 'package:laptop_harbour/components/header.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> images = [
      'assets/images/page1.jpg',
      'assets/images/page2.jpg',
      'assets/images/page3.jpg'
    ];
    return Scaffold(
      appBar: Header(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30,vertical:18),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          width: MediaQuery.of(context).size.width *0.8,
          child: PageView.builder(
            itemCount: 3,
            itemBuilder: (context, index) {
              return Stack(
                children: [Image(image: AssetImage(images[index]),fit: BoxFit.contain,height: 200,)],
              );
            },
          ),
        ),
      ),
    );
  }
}
