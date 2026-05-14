import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../core/errors/exceptions.dart';
import '../core/services/firebase_service.dart';
import '../core/utils/date_helpers.dart';
import '../models/service_model.dart';

// ── Hive cache helpers ────────────────────────────────────────────────────────
// Services are cached as a JSON-string list under a single key.
const _cacheKey = 'today_services';

List<ServiceModel> _fromCache() {
  try {
    final box = Hive.box<dynamic>('services_cache');
    final raw = box.get(_cacheKey) as String?;
    if (raw == null) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(ServiceModel.fromJson).toList();
  } catch (_) {
    return [];
  }
}

Future<void> _toCache(List<ServiceModel> services) async {
  try {
    final box = Hive.box<dynamic>('services_cache');
    final json = jsonEncode(services.map((s) => s.toJson()).toList());
    await box.put(_cacheKey, json);
  } catch (_) {
    // Cache failures are non-fatal
  }
}

abstract class ServiceRepository {
  Stream<List<ServiceModel>> watchTodayServices();
  Stream<List<ServiceModel>> watchAllServices();
  Future<void> addService(ServiceModel service);
  Future<void> updateService(ServiceModel service);
  Future<void> deleteService(String id);
  Future<void> markCompleted(String id);
  Future<List<ServiceModel>> fetchHistory({
    DocumentSnapshot? lastDoc,
    int limit = 20,
    String? statusFilter,
  });
  Future<List<ServiceModel>> fetchByDateRange(DateTime from, DateTime to);
}

class FirestoreServiceRepository implements ServiceRepository {
  @override
  Stream<List<ServiceModel>> watchTodayServices() {
    final start = DateHelpers.startOfDay(DateTime.now());
    final end = DateHelpers.endOfDay(DateTime.now());
    return FirebaseService.services
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
          final services =
              snap.docs.map(ServiceModel.fromFirestore).toList();
          _toCache(services); // keep cache fresh on every stream update
          return services;
        });
  }

  @override
  Stream<List<ServiceModel>> watchAllServices() {
    return FirebaseService.services
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) =>
            snap.docs.map(ServiceModel.fromFirestore).toList());
  }

  @override
  Future<void> addService(ServiceModel service) async {
    try {
      await FirebaseService.services
          .add(ServiceModel.toFirestore(service));
    } on FirebaseException catch (e) {
      throw DatabaseException(e.message ?? 'Failed to add service.');
    }
  }

  @override
  Future<void> updateService(ServiceModel service) async {
    try {
      await FirebaseService.services
          .doc(service.id)
          .update(ServiceModel.toFirestore(service));
    } on FirebaseException catch (e) {
      throw DatabaseException(e.message ?? 'Failed to update service.');
    }
  }

  @override
  Future<void> deleteService(String id) async {
    try {
      await FirebaseService.services.doc(id).delete();
    } on FirebaseException catch (e) {
      throw DatabaseException(e.message ?? 'Failed to delete service.');
    }
  }

  @override
  Future<void> markCompleted(String id) async {
    try {
      await FirebaseService.services.doc(id).update({
        'status': 'Completed',
        'completedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw DatabaseException(e.message ?? 'Failed to mark complete.');
    }
  }

  @override
  Future<List<ServiceModel>> fetchHistory({
    DocumentSnapshot? lastDoc,
    int limit = 20,
    String? statusFilter,
  }) async {
    try {
      Query query = FirebaseService.services
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (statusFilter != null && statusFilter != 'All') {
        query = query.where('status', isEqualTo: statusFilter);
      }
      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      final snap = await query.get();
      return snap.docs.map(ServiceModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      // Fall back to Hive cache on network failure
      final cached = _fromCache();
      if (cached.isNotEmpty) return cached;
      throw DatabaseException(e.message ?? 'Failed to fetch history.');
    }
  }

  @override
  Future<List<ServiceModel>> fetchByDateRange(
      DateTime from, DateTime to) async {
    try {
      final snap = await FirebaseService.services
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(from))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(to))
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs.map(ServiceModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      throw DatabaseException(e.message ?? 'Failed to fetch services.');
    }
  }
}
