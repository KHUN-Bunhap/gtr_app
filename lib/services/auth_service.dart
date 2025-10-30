import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Authentication Service
/// Handles user authentication with Firebase Auth
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get user role from Firestore
  // Returns 'admin', 'teacher', 'student', 'developer', or null if not found
  Future<String?> getUserRole() async {
    try {
      if (currentUser == null) return null;

      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (!userDoc.exists) return null;

      return userDoc.data()?['role'] as String?;
    } catch (e) {
      return null;
    }
  }

  // Check if current user is an admin
  Future<bool> isAdmin() async {
    final role = await getUserRole();
    return role == 'admin';
  }

  // Check if current user is a teacher
  Future<bool> isTeacher() async {
    final role = await getUserRole();
    return role == 'teacher';
  }

  // Check if current user is a developer
  Future<bool> isDeveloper() async {
    final role = await getUserRole();
    return role == 'developer';
  }

  // Check if current user is a student
  Future<bool> isStudent() async {
    final role = await getUserRole();
    return role == 'student';
  }

  // Check if current user can edit schedules (admin or teacher)
  Future<bool> canEditSchedule() async {
    final role = await getUserRole();
    return role == 'admin' || role == 'teacher' || role == 'developer';
  }

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String studentId,
    String? username,
  }) async {
    try {
      // Create user account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(fullName);

      // Create user document in Firestore
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'email': email,
        'fullName': fullName,
        'username': username ?? '',
        'studentId': studentId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Failed to sign out. Please try again.';
    }
  }

  // Reset password by email
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to send reset email. Please try again.';
    }
  }

  // Reset password by student ID
  // Looks up user by student ID, retrieves email, and sends reset link
  Future<void> resetPasswordByStudentId(String studentId) async {
    try {
      // Query Firestore for user with matching student ID
      final querySnapshot = await _firestore
          .collection('users')
          .where('studentId', isEqualTo: studentId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw 'No account found with this Student ID.';
      }

      // Get user's email from Firestore
      final userDoc = querySnapshot.docs.first;
      final email = userDoc.data()['email'] as String?;

      if (email == null || email.isEmpty) {
        throw 'Unable to retrieve email for this Student ID.';
      }

      // Send password reset email via Firebase Auth
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      // If it's already a string error we threw, rethrow as-is
      if (e is String) {
        rethrow;
      }
      throw 'Failed to send reset email. Please try again.';
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password is too weak. Please use a stronger password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
}
