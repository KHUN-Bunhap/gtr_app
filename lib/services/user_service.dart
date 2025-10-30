import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

/// User Data Service
/// Handles user profile data storage and retrieval in Firestore
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Get user data stream
  Stream<DocumentSnapshot> getUserStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots();
  }

  // Get user data once
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      throw 'Failed to load user data';
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String userId,
    String? fullName,
    String? bio,
    String? profileImageUrl,
    String? username,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (fullName != null) updateData['fullName'] = fullName;
      if (bio != null) updateData['bio'] = bio;
      if (profileImageUrl != null)
        updateData['profileImageUrl'] = profileImageUrl;
      if (username != null) updateData['username'] = username;

      await _firestore.collection('users').doc(userId).update(updateData);
    } catch (e) {
      throw 'Failed to update profile';
    }
  }

  // Upload profile image
  Future<String> uploadProfileImage(String userId, File imageFile) async {
    try {
      final ref = _storage.ref().child(
        'profile_images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw 'Failed to upload image';
    }
  }

  // Upload cover image
  Future<String> uploadCoverImage(String userId, File imageFile) async {
    try {
      final ref = _storage.ref().child(
        'cover_images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw 'Failed to upload cover image';
    }
  }

  // Delete user account
  Future<void> deleteUserAccount(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      await _auth.currentUser?.delete();
    } catch (e) {
      throw 'Failed to delete account';
    }
  }
}
