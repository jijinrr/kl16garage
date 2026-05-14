import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/admin/screens/admin_home_screen.dart';
import '../features/admin/screens/admin_settings_screen.dart';
import '../features/admin/screens/admin_shell.dart';
import '../features/analytics/screens/analytics_screen.dart';
import '../features/attendance/screens/attendance_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/role_selection_screen.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/reports/screens/reports_screen.dart';
import '../features/services/screens/customer_history_screen.dart';
import '../features/services/screens/service_history_screen.dart';
import '../features/staff/screens/add_customer_screen.dart';
import '../features/staff/screens/expenses_screen.dart';
import '../features/staff/screens/staff_home_screen.dart';
import '../features/staff/screens/staff_settings_screen.dart';
import '../features/staff/screens/staff_shell.dart';
import '../features/staff/screens/today_screen.dart';
import '../features/staff_mgmt/screens/add_staff_screen.dart';
import '../features/staff_mgmt/screens/staff_list_screen.dart';
import '../features/stock/screens/add_stock_screen.dart';
import '../features/stock/screens/stock_screen.dart';
import '../models/service_model.dart';
import '../models/staff_model.dart';
import '../models/stock_model.dart';
import '../providers/auth_provider.dart';

/// Route name constants.
class Routes {
  Routes._();

  static const splash = '/';
  static const roleSelection = '/role-selection';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';

  // Staff shell
  static const staffHome = '/staff/home';
  static const staffToday = '/staff/today';
  static const staffStocks = '/staff/stocks';
  static const staffExpenses = '/staff/expenses';
  static const staffSettings = '/staff/settings';

  // Staff full-screen
  static const staffAddCustomer = '/staff/add-customer';
  static const staffAddStock = '/staff/add-stock';

  // Admin shell
  static const adminHome = '/admin/home';
  static const adminAnalytics = '/admin/analytics';
  static const adminAttendance = '/admin/attendance';
  static const adminStaff = '/admin/staff';
  static const adminAddStaff = '/admin/add-staff';
  static const adminSettings = '/admin/settings';
  static const adminReports = '/admin/reports';
  static const adminHistory = '/admin/history';
  static const adminCustomerHistory = '/admin/customer-history';
}

/// Creates and returns the GoRouter instance.
/// Must be created OUTSIDE build() to prevent recreation on provider changes.
GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: authProvider,
    redirect: (context, state) {
      final status = authProvider.status;
      final loc = state.matchedLocation;

      // Still determining auth state — stay on splash
      if (status == AuthStatus.unknown) {
        return loc == Routes.splash ? null : Routes.splash;
      }

      final isAuthRoute = loc == Routes.splash ||
          loc == Routes.roleSelection ||
          loc == Routes.login ||
          loc == Routes.forgotPassword;

      // Unauthenticated: if not on an auth route → send to role selection
      if (status == AuthStatus.unauthenticated && !isAuthRoute) {
        return Routes.roleSelection;
      }

      // Authenticated: if still on splash or role selection → go to dashboard
      if (status == AuthStatus.authenticated &&
          (loc == Routes.splash || loc == Routes.roleSelection)) {
        return authProvider.role == UserRole.admin
            ? Routes.adminHome
            : Routes.staffHome;
      }

      return null;
    },
    routes: [
      // ── Splash ────────────────────────────────────────────────────────────
      GoRoute(
        path: Routes.splash,
        builder: (_, _) => const SplashScreen(),
      ),

      // ── Auth ──────────────────────────────────────────────────────────────
      GoRoute(
        path: Routes.roleSelection,
        builder: (_, _) => const RoleSelectionScreen(),
        pageBuilder: (_, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const RoleSelectionScreen(),
          transitionsBuilder: (_, anim, _, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      GoRoute(
        path: Routes.login,
        builder: (_, _) => const LoginScreen(),
        pageBuilder: (_, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (_, anim, _, child) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 320),
        ),
      ),
      GoRoute(
        path: Routes.forgotPassword,
        builder: (_, _) => const ForgotPasswordScreen(),
      ),

      // ── Staff shell ───────────────────────────────────────────────────────
      ShellRoute(
        builder: (_, _, child) => StaffShell(child: child),
        routes: [
          GoRoute(
            path: Routes.staffHome,
            builder: (_, _) => const StaffHomeScreen(),
          ),
          GoRoute(
            path: Routes.staffToday,
            builder: (_, _) => const TodayScreen(),
          ),
          GoRoute(
            path: Routes.staffStocks,
            builder: (_, _) => const StockScreen(),
          ),
          GoRoute(
            path: Routes.staffExpenses,
            builder: (_, _) => const ExpensesScreen(),
          ),
          GoRoute(
            path: Routes.staffSettings,
            builder: (_, _) => const StaffSettingsScreen(),
          ),
        ],
      ),

      // Staff full-screen routes (outside shell)
      GoRoute(
        path: Routes.staffAddCustomer,
        builder: (context, state) {
          final service = state.extra as ServiceModel?;
          return AddCustomerScreen(existingService: service);
        },
      ),
      GoRoute(
        path: Routes.staffAddStock,
        builder: (context, state) {
          final stock = state.extra as StockModel?;
          return AddStockScreen(existingStock: stock);
        },
      ),

      // ── Admin shell ───────────────────────────────────────────────────────
      ShellRoute(
        builder: (_, _, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: Routes.adminHome,
            builder: (_, _) => const AdminHomeScreen(),
          ),
          GoRoute(
            path: Routes.adminAnalytics,
            builder: (_, _) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: Routes.adminAttendance,
            builder: (_, _) => const AttendanceScreen(),
          ),
          GoRoute(
            path: Routes.adminStaff,
            builder: (_, _) => const StaffListScreen(),
          ),
          GoRoute(
            path: Routes.adminSettings,
            builder: (_, _) => const AdminSettingsScreen(),
          ),
        ],
      ),

      // Admin full-screen routes (outside shell)
      GoRoute(
        path: Routes.adminAddStaff,
        builder: (context, state) {
          final staff = state.extra as StaffModel?;
          return AddStaffScreen(existingStaff: staff);
        },
      ),
      GoRoute(
        path: Routes.adminReports,
        builder: (_, _) => const ReportsScreen(),
      ),
      GoRoute(
        path: Routes.adminHistory,
        builder: (_, _) => const ServiceHistoryScreen(),
      ),
      GoRoute(
        path: Routes.adminCustomerHistory,
        builder: (_, _) => const CustomerHistoryScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Center(
        child: Text(
          'Page not found: ${state.error}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    ),
  );
}
