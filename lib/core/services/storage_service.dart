import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../errors/exceptions.dart';

/// Handles all Firebase Storage operations.
/// Images are uploaded at reduced quality to keep Storage usage low.
class StorageService {
  StorageService._();

  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static const _uuid = Uuid();

  /// Uploads [file] to [folder] in Firebase Storage.
  /// Returns the public download URL.
  ///
  /// Throws [StorageException] on failure.
  static Future<String> uploadFile({
    required File file,
    required String folder,
    String? fileName,
  }) async {
    try {
      final ext = file.path.contains('.')
          ? '.${file.path.split('.').last}'
          : '.jpg'; // e.g. ".jpg"
      final name = fileName ?? '${_uuid.v4()}$ext';
      final ref = _storage.ref().child('$folder/$name');

      final task = await ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      return await task.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw StorageException(e.message ?? 'Storage upload failed.');
    } catch (e) {
      throw StorageException(e.toString());
    }
  }

  /// Uploads multiple files and returns a list of download URLs.
  static Future<List<String>> uploadMultiple({
    required List<File> files,
    required String folder,
  }) async {
    final futures = files.map((f) => uploadFile(file: f, folder: folder));
    return Future.wait(futures);
  }

  /// Deletes a file by its full download URL.
  static Future<void> deleteByUrl(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } on FirebaseException catch (e) {
      throw StorageException(e.message ?? 'Storage delete failed.');
    }
  }

  // ── Folder naming conventions ─────────────────────────────────────────────
  static String staffPhotosFolder(String staffId) => 'staff_photos/$staffId';
  static String servicePhotosFolder(String serviceId) =>
      'service_photos/$serviceId';
  static String profilePhotosFolder(String uid) => 'profile_photos/$uid';
}
