class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String bloodGroup;
  final String gender;
  final String district;
  final String address;
  final String dateOfBirth;
  final bool isDonor;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.bloodGroup,
    required this.gender,
    required this.district,
    required this.address,
    required this.dateOfBirth,
    required this.isDonor,
  });

  /// Create a UserModel from a Firestore document map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      bloodGroup: map['bloodGroup'] ?? '',
      gender: map['gender'] ?? '',
      district: map['district'] ?? '',
      address: map['address'] ?? '',
      dateOfBirth: map['dateOfBirth'] ?? '',
      isDonor: map['isDonor'] ?? false,
    );
  }

  /// Convert UserModel to a Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'bloodGroup': bloodGroup,
      'gender': gender,
      'district': district,
      'address': address,
      'dateOfBirth': dateOfBirth,
      'isDonor': isDonor,
    };
  }

  /// Return a copy of this model with specified fields replaced
  UserModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? phone,
    String? bloodGroup,
    String? gender,
    String? district,
    String? address,
    String? dateOfBirth,
    bool? isDonor,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      gender: gender ?? this.gender,
      district: district ?? this.district,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      isDonor: isDonor ?? this.isDonor,
    );
  }
}