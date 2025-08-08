import 'package:laptop_harbour/components/browse_laptops.dart';

class LaptopsPage extends StatelessWidget {
  const LaptopsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Laptops'),centerTitle: true,),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            child: BrowseLaptops(sortList: ['Featured', 'Newest', 'Price: Low to High', 'Price: High to Low']),
          ),
        ),
      ),
    );
  }
}
