import 'package:laptop_harbour/models/laptop.dart';

class Order {
  final String id;
  final List<Laptop> items;
  final String status;
  final DateTime orderDate;
  final DateTime estimatedDilveryDate;

  Order({
    required this.id,
    required this.items,
    required this.status,
    required this.orderDate,
    required this.estimatedDilveryDate,
  });
}
