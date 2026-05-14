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

  // Staff shell tabs
  static const staffHome = '/staff/home';
  static const staffToday = '/staff/today';
  static const staffExpenses = '/staff/expenses';
  static const staffSettings = '/staff/settings';

  // Staff full-screen routes (push — no bottom nav)
  static const staffAddCustomer = '/staff/add-customer';
  static const staffStocks = '/staff/stocks';
  static const staffAddStock = '/staff/add-stock';

  // Admin shell tabs
  static const adminHome = '/admin/home';
  static const adminAnalytics = '/admin/analytics';
  static const adminAttendance = '/admin/attendance';
  static const adminStaff = '/admin/staff';
  static const adminSettings = '/admin/settings';

  // Admin full-screen routes (push — no bottom nav)
  static const adminAddStaff = '/admin/add-staff';
  static const adminReports = '/admin/reports';
  static const adminHistory = '/admin/history';
  static const adminCustomerHistory = '/admin/customer-history';
}

/// Creates and returns the GoRouter instance.
/// Uses [StatefulShellRoute.indexedStack] so each tab keeps its own
/// navigation stack and scroll position — zero flicker on tab switches.
GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: authProvider,
    redirect: (context, state) {
      final status = authProvider.status;
      final loc = state.matchedLocation;

      if (status == AuthStatus.unknown) {
        return loc == Routes.splash ? null : Routes.splash;
      }

      final isAuthRoute = loc == Routes.splash ||
          loc == Routes.roleSelection ||
          loc == Routes.login ||
          loc == Routes.forgotPassword;

      if (status == AuthStatus.unauthenticated && !isAuthRoute) {
        return Routes.roleSelection;
      }

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
        pageBuilder: (_, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (_, anim, _, child) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(
                CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 320),
        ),
      ),
      GoRoute(
        path: Routes.forgotPassword,
        builder: (_, _) => const ForgotPasswordScreen(),
      ),

      // ── Staff — persistent indexed shell (4 tabs) ─────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) =>
            StaffShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.staffHome,
              builder: (_, _) => const StaffHomeScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.staffToday,
              builder: (_, _) => const TodayScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.staffExpenses,
              builder: (_, _) => const ExpensesScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.staffSettings,
              builder: (_, _) => const StaffSettingsScreen(),
            ),
          ]),
        ],
      ),

      // ── Staff full-screen routes (push — outside shell) ───────────────────
      GoRoute(
        path: Routes.staffAddCustomer,
        builder: (_, state) =>
            AddCustomerScreen(existingService: state.extra as ServiceModel?),
      ),
      GoRoute(
        path: Routes.staffStocks,
        builder: (_, _) => const StockScreen(),
      ),
      GoRoute(
        path: Routes.staffAddStock,
        builder: (_, state) =>
            AddStockScreen(existingStock: state.extra as StockModel?),
      ),

      // ── Admin — persistent indexed shell (5 tabs) ─────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) =>
            AdminShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.adminHome,
              builder: (_, _) => const AdminHomeScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.adminAnalytics,
              builder: (_, _) => const AnalyticsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.adminAttendance,
              builder: (_, _) => const AttendanceScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.adminStaff,
              builder: (_, _) => const StaffListScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.adminSettings,
              builder: (_, _) => const AdminSettingsScreen(),
            ),
          ]),
        ],
      ),

      // ── Admin full-screen routes (push — outside shell) ───────────────────
      GoRoute(
        path: Routes.adminAddStaff,
        builder: (_, state) =>
            AddStaffScreen(existingStaff: state.extra as StaffModel?),
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
    errorBuilder: (_, state) => Scaffold(
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
