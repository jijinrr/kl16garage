import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/errors/exceptions.dart';
import '../core/services/firebase_service.dart';
import '../core/services/storage_service.dart';
import '../models/staff_model.dart';

abstract class StaffRepository {
  Stream<List<StaffModel>> watchAllStaff();
  Future<void> addStaff(StaffModel staff, {File? photo});
  Future<void> updateStaff(StaffModel staff, {File? photo});
  Future<void> toggleStatus(String id, bool isActive);
  Future<void> deleteStaff(String id);
}

class FirestoreStaffRepository implements StaffRepository {
  @override
  Stream<List<StaffModel>> watchAllStaff() {
    return FirebaseService.staff
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs.map(StaffModel.fromFirestore).toList());
  }

  @override
  Future<void> addStaff(StaffModel staff, {File? photo}) async {
    try {
      String photoUrl = staff.photoUrl;
      if (photo != null) {
        photoUrl = await StorageService.uploadFile(
          file: photo,
          folder: 'staff_photos',
        );
      }

      final model = staff.copyWith(photoUrl: photoUrl);
      await FirebaseService.staff.add(StaffModel.toFirestore(model));
    } on StorageException {
      rethrow;
    } on FirebaseException catch (e) {
      throw DatabaseException(e.message ?? 'Failed to add staff.');
    }
  }

  @override
  Future<void> updateStaff(StaffModel staff, {File? photo}) async {
    try {
      String photoUrl = staff.photoUrl;
      if (photo != null) {
        photoUrl = await StorageService.uploadFile(
          file: photo,
          folder: 'staff_photos',
          fileName: '${staff.id}.jpg',
        );
      }

      final model = staff.copyWith(photoUrl: photoUrl);
      await FirebaseService.staff
          .doc(staff.id)
          .update(StaffModel.toFirestore(model));
    } on StorageException {
      rethrow;
    } on FirebaseException catch (e) {
      throw DatabaseException(e.message ?? 'Failed to update staff.');
    }
  }

  @override
  Future<void> toggleStatus(String id, bool isActive) async {
    try {
      await FirebaseService.staff
          .doc(id)
          .update({'isActive': isActive});
    } on FirebaseException catch (e) {
      throw DatabaseException(e.message ?? 'Failed to update status.');
    }
  }

  @override
  Future<void> deleteStaff(String id) async {
    try {
      await FirebaseService.staff.doc(id).delete();
    } on FirebaseException catch (e) {
      throw DatabaseException(e.message ?? 'Failed to delete staff.');
    }
  }
}
