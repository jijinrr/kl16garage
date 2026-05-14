import 'dart:io';
import 'package:flutter/foundation.dart';
import '../core/services/session.dart';
import '../models/user_model.dart';

/// Centralised profile state — name, phone, local photo.
/// Sync this provider to reflect updates instantly in:
/// Settings, Dashboard header, Drawer, profile cards.
class UserProvider extends ChangeNotifier {
  UserProvider(UserModel? initialUser) {
    if (initialUser != null) _populate(initialUser);
  }

  String _name = '';
  String _email = '';
  String _phone = '';
  String _role = '';
  File? _localPhoto;       // picked from device
  String _networkPhotoUrl = '';

  // ── Getters ───────────────────────────────────────────────────────────────
  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get role => _role;
  File? get localPhoto => _localPhoto;
  String get networkPhotoUrl => _networkPhotoUrl;

  /// Display initial (first letter of name) for fallback avatar.
  String get initial =>
      _name.isNotEmpty ? _name[0].toUpperCase() : '?';

  /// True if any photo is available.
  bool get hasPhoto =>
      _localPhoto != null || _networkPhotoUrl.isNotEmpty;

  // ── Populate from a UserModel (call after login / session restore) ─────────
  void populate(UserModel user) {
    _populate(user);
    notifyListeners();
  }

  void _populate(UserModel user) {
    _name = user.name;
    _email = user.email;
    _phone = user.phone;
    _role = user.role;
    _networkPhotoUrl = user.photoUrl;
    _localPhoto = null;
  }

  // ── Updates ───────────────────────────────────────────────────────────────
  void updateName(String name) {
    _name = name.trim();
    Session.name = _name;
    notifyListeners();
  }

  void updatePhone(String phone) {
    _phone = phone.trim();
    notifyListeners();
  }

  void updatePhoto(File photo) {
    _localPhoto = photo;
    notifyListeners();
  }

  void clearPhoto() {
    _localPhoto = null;
    _networkPhotoUrl = '';
    notifyListeners();
  }

  /// Call on logout to wipe local state.
  void clear() {
    _name = '';
    _email = '';
    _phone = '';
    _role = '';
    _localPhoto = null;
    _networkPhotoUrl = '';
    notifyListeners();
  }
}
