import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Schedule Service
/// Handles schedule data storage and retrieval in Firestore
class ScheduleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Save user's schedule preferences
  Future<void> saveSchedulePreferences({
    required String selectedGroup,
    List<String>? customTimeSlots,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw 'User not authenticated';

      await _firestore.collection('users').doc(userId).update({
        'schedulePreferences': {
          'selectedGroup': selectedGroup,
          'customTimeSlots': customTimeSlots,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      });
    } catch (e) {
      throw 'Failed to save schedule preferences';
    }
  }

  // Get user's schedule preferences
  Future<Map<String, dynamic>?> getSchedulePreferences() async {
    try {
      final userId = currentUserId;
      if (userId == null) return null;

      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data()?['schedulePreferences'] as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  // Get class schedule for a group (from centralized schedule collection)
  Stream<QuerySnapshot> getGroupScheduleStream(String group) {
    return _firestore
        .collection('schedules')
        .where('group', isEqualTo: group)
        .snapshots();
  }

  // Add a custom note to a time slot
  Future<void> addScheduleNote({
    required String timeSlot,
    required int dayIndex,
    required String note,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw 'User not authenticated';

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('scheduleNotes')
          .add({
            'timeSlot': timeSlot,
            'dayIndex': dayIndex,
            'note': note,
            'createdAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      throw 'Failed to add note';
    }
  }

  // Get user's schedule notes
  Stream<QuerySnapshot> getScheduleNotesStream() {
    final userId = currentUserId;
    if (userId == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('scheduleNotes')
        .snapshots();
  }

  // Admin: Add a new class to the schedule (Teachers/Developers only)
  Future<void> addScheduleClass({
    required String subject,
    required String room,
    required String teacher,
    required String timeSlot,
    required int dayOfWeek,
    required String classType,
    String? group,
    required int color,
  }) async {
    try {
      await _firestore.collection('schedules').add({
        'subject': subject,
        'room': room,
        'teacher': teacher,
        'timeSlot': timeSlot,
        'dayOfWeek': dayOfWeek,
        'classType': classType,
        'group': group ?? 'All Groups',
        'color': color,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to add class: ${e.toString()}';
    }
  }

  // Admin: Update an existing class
  Future<void> updateScheduleClass({
    required String classId,
    String? subject,
    String? room,
    String? teacher,
    String? timeSlot,
    int? dayOfWeek,
    String? classType,
    String? group,
    int? color,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (subject != null) updates['subject'] = subject;
      if (room != null) updates['room'] = room;
      if (teacher != null) updates['teacher'] = teacher;
      if (timeSlot != null) updates['timeSlot'] = timeSlot;
      if (dayOfWeek != null) updates['dayOfWeek'] = dayOfWeek;
      if (classType != null) updates['classType'] = classType;
      if (group != null) updates['group'] = group;
      if (color != null) updates['color'] = color;

      await _firestore.collection('schedules').doc(classId).update(updates);
    } catch (e) {
      throw 'Failed to update class: ${e.toString()}';
    }
  }

  // Admin: Delete a class from the schedule
  Future<void> deleteScheduleClass(String classId) async {
    try {
      await _firestore.collection('schedules').doc(classId).delete();
    } catch (e) {
      throw 'Failed to delete class: ${e.toString()}';
    }
  }

  // Get all schedules (for admin/teacher view)
  Stream<QuerySnapshot> getAllSchedulesStream() {
    return _firestore
        .collection('schedules')
        .orderBy('dayOfWeek')
        .orderBy('timeSlot')
        .snapshots();
  }
}
