
import 'package:laptop_harbour/models/user.dart';
class Profile {
  final User user;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String? address;
  final String? city;
  final String? postalCode;
  final String? country;

  Profile({
    required this.user,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.address,
    this.city,
    this.postalCode,
    this.country,
  });
}
