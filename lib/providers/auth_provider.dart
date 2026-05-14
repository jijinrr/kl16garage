import 'package:flutter/foundation.dart';
import '../core/errors/exceptions.dart';
import '../core/services/session.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

enum UserRole { admin, staff }

/// Drives routing and role detection.
/// GoRouter listens to this via refreshListenable.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repo) {
    _restoreSession();
  }

  final AuthRepository _repo;

  UserModel? _currentUser;
  AuthStatus _status = AuthStatus.unknown;
  String? _error;
  bool _isLoading = false;

  /// The role the user selected on RoleSelectionScreen.
  /// Used by LoginScreen to show role-appropriate UI.
  String _selectedRole = 'staff';

  UserModel? get currentUser => _currentUser;
  AuthStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  String get selectedRole => _selectedRole;

  UserRole get role =>
      _currentUser?.role == 'admin' ? UserRole.admin : UserRole.staff;

  // ── Role selection (Role Selection Screen → Login Screen) ─────────────────
  void setSelectedRole(String role) {
    _selectedRole = role;
    notifyListeners();
  }

  // ── Restore session on cold start ─────────────────────────────────────────
  Future<void> _restoreSession() async {
    try {
      final user = await _repo.getSessionUser();
      if (user != null) {
        _currentUser = user;
        _status = AuthStatus.authenticated;
        _selectedRole = user.role;
        Session.set(uid: user.uid, role: user.role, name: user.name);
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ── Login with credentials (Admin) ────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners(); // single leading notify (shows spinner)
    try {
      final user = await _repo.login(email, password);
      _currentUser = user;
      _status = AuthStatus.authenticated;
      _selectedRole = user.role;
      _isLoading = false;
      Session.set(uid: user.uid, role: user.role, name: user.name);
      notifyListeners(); // single trailing notify (GoRouter redirects)
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Staff direct login (no credentials required) ──────────────────────────
  Future<bool> loginAsStaff() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final user = await _repo.loginAsStaff();
      _currentUser = user;
      _status = AuthStatus.authenticated;
      _selectedRole = user.role;
      _isLoading = false;
      Session.set(uid: user.uid, role: user.role, name: user.name);
      notifyListeners(); // GoRouter redirects to staff home
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    // Run repo work silently, then flip state once — single notifyListeners()
    // so GoRouter receives exactly one redirect signal to roleSelection.
    try {
      await _repo.logout();
    } finally {
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      _isLoading = false;
      _selectedRole = 'staff';
      Session.clear();
      notifyListeners(); // single notify → GoRouter redirects cleanly
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
