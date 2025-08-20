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

    final String? fcmToken;

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
    this.fcmToken,
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
    String? fcmToken,
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
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  Map<String, dynamic> toMap() {
    return {
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
      'fcmToken': fcmToken,
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      uid: map['uid'],
      email: map['email'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      phoneNumber: map['phoneNumber'],
      profilePic: map['profilePic'],
      address: map['address'],
      city: map['city'],
      postalCode: map['postalCode'],
      country: map['country'],
      role: map['role'] ?? 'user',
      isBlocked: map['isBlocked'] ?? false,
      fcmToken: map['fcmToken'],
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
