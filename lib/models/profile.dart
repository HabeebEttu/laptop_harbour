// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

class Profile {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String? profilePic;
  final String? address;
  final String? city;
  final String? postalCode;
  final String? country;
  final String role;
  final bool isBlocked;

  String get id => uid;

  Profile({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.profilePic,
    this.address,
    this.city,
    this.postalCode,
    this.country,
    this.role = 'user',
    this.isBlocked = false,
  });

  Profile copyWith({
    String? uid,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profilePic,
    String? address,
    String? city,
    String? postalCode,
    String? country,
    String? role,
    bool? isBlocked,
  }) {
    return Profile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePic: profilePic ?? this.profilePic,
      address: address ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      role: role ?? this.role,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'profilePic': profilePic,
      'address': address,
      'city': city,
      'postalCode': postalCode,
      'country': country,
      'role': role,
      'isBlocked': isBlocked,
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      uid: map['uid'] as String,
      email: map['email'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      phoneNumber: map['phoneNumber'] as String,
      profilePic: map['profilePic'] as String?,
      address: map['address'] as String?,
      city: map['city'] as String?,
      postalCode: map['postalCode'] as String?,
      country: map['country'] as String?,
      role: map['role'] as String? ?? 'user',
      isBlocked: map['isBlocked'] as bool? ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory Profile.fromJson(String source) =>
      Profile.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Profile(uid: $uid, email: $email, firstName: $firstName, lastName: $lastName, phoneNumber: $phoneNumber, profilePic: $profilePic, address: $address, city: $city, postalCode: $postalCode, country: $country, role: $role, isBlocked: $isBlocked)';
  }

  @override
  bool operator ==(covariant Profile other) {
    if (identical(this, other)) return true;
  
    return 
      other.uid == uid &&
        other.email == email &&
      other.firstName == firstName &&
        other.lastName == lastName &&
      other.phoneNumber == phoneNumber &&
        other.profilePic == profilePic &&
      other.address == address &&
      other.city == city &&
      other.postalCode == postalCode &&
      other.country == country &&
        other.role == role &&
        other.isBlocked == isBlocked;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        email.hashCode ^
      firstName.hashCode ^
        lastName.hashCode ^
      phoneNumber.hashCode ^
        profilePic.hashCode ^
      address.hashCode ^
      city.hashCode ^
      postalCode.hashCode ^
      country.hashCode ^
        role.hashCode ^
        isBlocked.hashCode;
  }
}
