import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/request_model.dart';
import '../models/donation_model.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─────────────────────────────────────────
  // Current User
  // ─────────────────────────────────────────

  /// One-time fetch of the current user document
  Future<DocumentSnapshot<Map<String, dynamic>>> getCurrentUser() async {
    final uid = _auth.currentUser!.uid;
    return await _firestore.collection('users').doc(uid).get();
  }

  /// Live stream of the current user document
  Stream<DocumentSnapshot<Map<String, dynamic>>> currentUserStream() {
    final uid = _auth.currentUser!.uid;
    return _firestore.collection('users').doc(uid).snapshots();
  }

  // ─────────────────────────────────────────
  // Donor / User Stats — Live Streams
  // ─────────────────────────────────────────

  /// Stream of all users (for total user count)
  Stream<QuerySnapshot<Map<String, dynamic>>> allUsersStream() {
    return _firestore.collection('users').snapshots();
  }

  /// Stream of all donors (isDonor == true)
  Stream<QuerySnapshot<Map<String, dynamic>>> donorsStream() {
    return _firestore
        .collection('users')
        .where('isDonor', isEqualTo: true)
        .snapshots();
  }

  /// Stream of all blood requests
  Stream<QuerySnapshot<Map<String, dynamic>>> requestsStream() {
    return _firestore.collection('requests').orderBy('createdAt', descending: true).snapshots();
  }

  /// Stream of blood requests matching a specific blood group
  Stream<QuerySnapshot<Map<String, dynamic>>> matchingRequestsStream(String bloodGroup) {
    if (bloodGroup.isEmpty) return const Stream.empty();
    return _firestore
        .collection('requests')
        .where('bloodGroup', isEqualTo: bloodGroup)
        .snapshots();
  }



  // ─────────────────────────────────────────
  // Blood Group Statistics — Live Stream
  // ─────────────────────────────────────────

  /// Returns a live stream that emits a map of blood group → donor count
  Stream<Map<String, int>> bloodStatsStream() {
    return _firestore
        .collection('users')
        .where('isDonor', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final Map<String, int> counts = {
        'A+': 0, 'A-': 0, 'B+': 0, 'B-': 0,
        'O+': 0, 'O-': 0, 'AB+': 0, 'AB-': 0,
      };
      for (var doc in snapshot.docs) {
        final group = doc['bloodGroup'] as String?;
        if (group != null && counts.containsKey(group)) {
          counts[group] = counts[group]! + 1;
        }
      }
      return counts;
    });
  }

  // ─────────────────────────────────────────
  // Blood Requests
  // ─────────────────────────────────────────

  /// Submit a new blood request
  Future<String?> submitBloodRequest(RequestModel request) async {
    try {
      await _firestore.collection('requests').add(request.toMap());
      return null; // success
    } catch (e) {
      return e.toString();
    }
  }

  /// Stream of requests by the current user
  Stream<QuerySnapshot<Map<String, dynamic>>> getUserRequests() {
    final uid = _auth.currentUser!.uid;
    return _firestore
        .collection('requests')
        .where('requestedBy', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ─────────────────────────────────────────
  // Donations
  // ─────────────────────────────────────────

  /// Log a donation event
  Future<String?> logDonation(DonationModel donation) async {
    try {
      await _firestore.collection('donations').add(donation.toMap());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Stream of the current user's donations
  Stream<QuerySnapshot<Map<String, dynamic>>> getUserDonations() {
    final uid = _auth.currentUser!.uid;
    return _firestore
        .collection('donations')
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ─────────────────────────────────────────
  // Profile Updates
  // ─────────────────────────────────────────

  /// Toggle donor availability status
  Future<String?> toggleDonorStatus(bool isDonor) async {
    try {
      final uid = _auth.currentUser!.uid;
      await _firestore.collection('users').doc(uid).update({'isDonor': isDonor});
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Update user profile fields
  Future<String?> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      final uid = _auth.currentUser!.uid;
      await _firestore.collection('users').doc(uid).update(updates);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ─────────────────────────────────────────
  // Find Donors (with filters)
  // ─────────────────────────────────────────

  /// Stream donors filtered by blood group and/or district
  Stream<QuerySnapshot<Map<String, dynamic>>> findDonors({
    String? bloodGroup,
    String? district,
  }) {
    Query<Map<String, dynamic>> query = _firestore
        .collection('users')
        .where('isDonor', isEqualTo: true);

    if (bloodGroup != null && bloodGroup.isNotEmpty) {
      query = query.where('bloodGroup', isEqualTo: bloodGroup);
    }
    if (district != null && district.isNotEmpty) {
      query = query.where('district', isEqualTo: district);
    }

    return query.snapshots();
  }
}