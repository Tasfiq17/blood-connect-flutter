import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel {
  final String id;
  final String patientName;
  final String bloodGroup;
  final String hospital;
  final String address;
  final String district;
  final String contact;
  final String urgency; // 'Normal' | 'Urgent' | 'Emergency'
  final String status;  // 'pending' | 'approved' | 'fulfilled'
  final String requestedBy; // uid of requester
  final DateTime? createdAt;

  RequestModel({
    this.id = '',
    required this.patientName,
    required this.bloodGroup,
    required this.hospital,
    required this.address,
    required this.district,
    required this.contact,
    required this.urgency,
    this.status = 'pending',
    required this.requestedBy,
    this.createdAt,
  });

  factory RequestModel.fromMap(Map<String, dynamic> map, {String id = ''}) {
    return RequestModel(
      id: id,
      patientName: map['patientName'] ?? '',
      bloodGroup: map['bloodGroup'] ?? '',
      hospital: map['hospital'] ?? '',
      address: map['address'] ?? '',
      district: map['district'] ?? '',
      contact: map['contact'] ?? '',
      urgency: map['urgency'] ?? 'Normal',
      status: map['status'] ?? 'pending',
      requestedBy: map['requestedBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientName': patientName,
      'bloodGroup': bloodGroup,
      'hospital': hospital,
      'address': address,
      'district': district,
      'contact': contact,
      'urgency': urgency,
      'status': status,
      'requestedBy': requestedBy,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
