import 'package:flutter/material.dart';

class CartItemCard extends StatefulWidget {
  const CartItemCard({super.key});

  @override
  State<CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            Container(
              width: MediaQuery.of(context).size.width*0.4,
              height: 150,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage('images/laptop3.jpg'),fit: BoxFit.fitWidth),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.41 ,
                  child: Text(
                    'Del XPS 15 laptop,intel core i7,15B RAM,512GB SSD',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  
                  padding: const EdgeInsets.all(8.0),
                  child: Text('\$1899.99',style: TextStyle(
                    color: Colors.blueAccent
                  ),),
                ),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: BoxBorder.all(color: Colors.grey[200]!,
            
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 8,
                        children: [
                          GestureDetector(child: Text('-')),
                          GestureDetector(child: Text('1')),
                          GestureDetector(child: Text('+'))
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: BoxBorder.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 8,
                        children: [
                          Icon(Icons.delete_outline_rounded, color: Colors.red),
                          Text('Remove', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                )
                
              ],
            )
          ],
        ),
      ),
    );
  }
}
