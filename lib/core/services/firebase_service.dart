import 'package:cloud_firestore/cloud_firestore.dart';

/// Centralized Firestore singleton wrapper.
/// Firebase Auth is NOT used — authentication is handled locally.
class FirebaseService {
  FirebaseService._();

  static final FirebaseFirestore db = FirebaseFirestore.instance;

  // ── Collection references ─────────────────────────────────────────────────
  static CollectionReference<Map<String, dynamic>> get users =>
      db.collection('users');

  static CollectionReference<Map<String, dynamic>> get services =>
      db.collection('services');

  static CollectionReference<Map<String, dynamic>> get expenses =>
      db.collection('expenses');

  static CollectionReference<Map<String, dynamic>> get attendance =>
      db.collection('attendance');

  static CollectionReference<Map<String, dynamic>> get staff =>
      db.collection('staff');

  static CollectionReference<Map<String, dynamic>> get payments =>
      db.collection('payments');

  static CollectionReference<Map<String, dynamic>> get settings =>
      db.collection('settings');

  // ── Firestore helpers ─────────────────────────────────────────────────────
  static FieldValue get serverTimestamp => FieldValue.serverTimestamp();

  static DateTime? timestampToDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  static Timestamp dateToTimestamp(DateTime date) => Timestamp.fromDate(date);
}
