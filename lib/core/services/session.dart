/// Lightweight in-memory session holder.
/// Set on login, cleared on logout — no Firebase dependency.
class Session {
  Session._();

  static String uid = '';
  static String role = '';
  static String name = '';

  static bool get isAdmin => role == 'admin';

  static void set(
      {required String uid, required String role, required String name}) {
    Session.uid = uid;
    Session.role = role;
    Session.name = name;
  }

  static void clear() {
    uid = '';
    role = '';
    name = '';
  }
}
