import 'package:laptop_harbour/models/cart.dart';
import 'package:laptop_harbour/models/order.dart';
import 'package:laptop_harbour/models/profile.dart';

class User {
  final Profile profile;
  final Cart cart;
  final List<Order> orders;

  User({required this.profile, required this.cart, required this.orders});
}
