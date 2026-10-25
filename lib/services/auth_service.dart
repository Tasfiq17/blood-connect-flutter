import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Register User
  Future<String?> registerUser({
    required UserModel user,
    required String password,
  }) async {
    try {
      // Create Firebase Authentication account
      UserCredential credential =
      await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: password,
      );

      // Save user information to Firestore
      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set({
        'uid': credential.user!.uid,
        'fullName': user.fullName,
        'email': user.email,
        'phone': user.phone,
        'bloodGroup': user.bloodGroup,
        'gender': user.gender,
        'district': user.district,
        'address': user.address,
        'dateOfBirth': user.dateOfBirth,
        'isDonor': user.isDonor,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  /// Login User
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return "Email or password incorrect";
      }
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  /// Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Current Logged In User
  User? get currentUser => _auth.currentUser;
}