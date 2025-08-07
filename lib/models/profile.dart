// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

class Profile {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final String? address;
  final String? city;
  final String? postalCode;
  final String? country;
  final String? profilePic;

  Profile({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    this.address,
    this.city,
    this.postalCode,
    this.country,
    this.profilePic,
  });

  Profile copyWith({
    String? uid,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? address,
    String? city,
    String? postalCode,
    String? country,
    String? profilePic,
  }) {
    return Profile(
      uid: uid ?? this.uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      profilePic: profilePic ?? this.profilePic,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'city': city,
      'postalCode': postalCode,
      'country': country,
      'profilePic': profilePic,
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      uid: map['uid'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      email: map['email'] as String,
      phoneNumber: map['phoneNumber'] != null ? map['phoneNumber'] as String : null,
      address: map['address'] != null ? map['address'] as String : null,
      city: map['city'] != null ? map['city'] as String : null,
      postalCode: map['postalCode'] != null ? map['postalCode'] as String : null,
      country: map['country'] != null ? map['country'] as String : null,
      profilePic: map['profilePic'] != null ? map['profilePic'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Profile.fromJson(String source) =>
      Profile.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Profile(uid: $uid, firstName: $firstName, lastName: $lastName, email: $email, phoneNumber: $phoneNumber, address: $address, city: $city, postalCode: $postalCode, country: $country, profilePic: $profilePic)';
  }

  @override
  bool operator ==(covariant Profile other) {
    if (identical(this, other)) return true;
  
    return 
      other.uid == uid &&
      other.firstName == firstName &&
      other.lastName == lastName &&
      other.email == email &&
      other.phoneNumber == phoneNumber &&
      other.address == address &&
      other.city == city &&
      other.postalCode == postalCode &&
      other.country == country &&
      other.profilePic == profilePic;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
      firstName.hashCode ^
      lastName.hashCode ^
      email.hashCode ^
      phoneNumber.hashCode ^
      address.hashCode ^
      city.hashCode ^
      postalCode.hashCode ^
      country.hashCode ^
      profilePic.hashCode;
  }
}
