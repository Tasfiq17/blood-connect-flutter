import 'package:cloud_firestore/cloud_firestore.dart';

class DonationModel {
  final String id;
  final String uid;
  final String bloodGroup;
  final String hospital;
  final String notes;
  final DateTime? date;
  final DateTime? createdAt;

  DonationModel({
    this.id = '',
    required this.uid,
    required this.bloodGroup,
    required this.hospital,
    this.notes = '',
    this.date,
    this.createdAt,
  });

  factory DonationModel.fromMap(Map<String, dynamic> map, {String id = ''}) {
    return DonationModel(
      id: id,
      uid: map['uid'] ?? '',
      bloodGroup: map['bloodGroup'] ?? '',
      hospital: map['hospital'] ?? '',
      notes: map['notes'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'bloodGroup': bloodGroup,
      'hospital': hospital,
      'notes': notes,
      'date': date != null ? Timestamp.fromDate(date!) : FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
