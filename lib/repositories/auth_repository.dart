import 'package:shared_preferences/shared_preferences.dart';
import '../core/errors/exceptions.dart';
import '../models/user_model.dart';

// ── Hardcoded credentials ─────────────────────────────────────────────────────
const _adminEmail = 'admin@kl16.com';
const _staffEmail = 'staff@kl16.com';
const _sharedPassword = '123456'; // same password for demo mode

const _prefKeyRole = 'session_role';
const _prefKeyName = 'session_name';

/// Minimal auth contract.
abstract class AuthRepository {
  Future<UserModel> login(String email, String password);
  Future<UserModel> loginAsStaff();
  Future<void> logout();
  Future<UserModel?> getSessionUser();
}

class LocalAuthRepository implements AuthRepository {
  // Cached SharedPreferences — initialized once, reused for all operations.
  // Eliminates the repeated async wait on every login/logout/restore.
  SharedPreferences? _prefs;
  Future<SharedPreferences> get _storage async =>
      _prefs ??= await SharedPreferences.getInstance();

  @override
  Future<UserModel> login(String email, String password) async {
    final e = email.trim().toLowerCase();

    if (e == _adminEmail && password == _sharedPassword) {
      final user = _adminUser();
      await _saveSession(user);
      return user;
    }

    if (e == _staffEmail && password == _sharedPassword) {
      final user = _staffUser();
      await _saveSession(user);
      return user;
    }

    throw const AuthException('Invalid email or password.');
  }

  @override
  Future<UserModel> loginAsStaff() async {
    final user = _staffUser();
    await _saveSession(user);
    return user;
  }

  @override
  Future<void> logout() async {
    final prefs = await _storage;
    await prefs.remove(_prefKeyRole);
    await prefs.remove(_prefKeyName);
  }

  @override
  Future<UserModel?> getSessionUser() async {
    final prefs = await _storage;
    final role = prefs.getString(_prefKeyRole);
    if (role == null) return null;
    return role == 'admin' ? _adminUser() : _staffUser();
  }

  Future<void> _saveSession(UserModel user) async {
    final prefs = await _storage;
    await prefs.setString(_prefKeyRole, user.role);
    await prefs.setString(_prefKeyName, user.name);
  }

  static UserModel _adminUser() => const UserModel(
        uid: 'local_admin',
        name: 'KL16 Admin',
        email: 'admin@kl16.com',
        role: 'admin',
        phone: '9876543210',
        photoUrl: '',
        isActive: true,
      );

  static UserModel _staffUser() => const UserModel(
        uid: 'local_staff',
        name: 'Rajan Pillai',
        email: 'staff@kl16.com',
        role: 'staff',
        phone: '8765432109',
        photoUrl: '',
        isActive: true,
      );
}
