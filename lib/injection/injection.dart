import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_config.dart';
import '../providers/analytics_provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/service_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/staff_provider.dart';
import '../providers/stock_provider.dart';
import '../providers/user_provider.dart';
import '../repositories/analytics_repository.dart';
import '../repositories/attendance_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/expense_repository.dart';
import '../repositories/mock_analytics_repository.dart';
import '../repositories/mock_attendance_repository.dart';
import '../repositories/mock_expense_repository.dart';
import '../repositories/mock_service_repository.dart';
import '../repositories/mock_staff_repository.dart';
import '../repositories/mock_stock_repository.dart';
import '../repositories/service_repository.dart';
import '../repositories/staff_repository.dart';
import '../repositories/stock_repository.dart';

/// Root MultiProvider that wires all repositories and providers.
class AppInjection extends StatelessWidget {
  const AppInjection({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ── Repositories ───────────────────────────────────────────────────
        Provider<AuthRepository>(
          create: (_) => LocalAuthRepository(),
        ),
        Provider<ServiceRepository>(
          create: (_) => kUseMockData
              ? MockServiceRepository()
              : MockServiceRepository(), // swap → FirestoreServiceRepository()
        ),
        Provider<ExpenseRepository>(
          create: (_) => kUseMockData
              ? MockExpenseRepository()
              : MockExpenseRepository(), // swap → FirestoreExpenseRepository()
        ),
        Provider<AttendanceRepository>(
          create: (_) => kUseMockData
              ? MockAttendanceRepository()
              : MockAttendanceRepository(), // swap → FirestoreAttendanceRepository()
        ),
        Provider<StaffRepository>(
          create: (_) => kUseMockData
              ? MockStaffRepository()
              : MockStaffRepository(), // swap → FirestoreStaffRepository()
        ),
        Provider<AnalyticsRepository>(
          create: (_) => kUseMockData
              ? MockAnalyticsRepository()
              : MockAnalyticsRepository(), // swap → FirestoreAnalyticsRepository()
        ),
        Provider<StockRepository>(
          create: (_) => kUseMockData
              ? MockStockRepository()
              : MockStockRepository(), // swap → FirestoreStockRepository()
        ),

        // ── Settings (drives theme) ────────────────────────────────────────
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(),
        ),

        // ── Auth (drives routing) ──────────────────────────────────────────
        ChangeNotifierProvider<AuthProvider>(
          create: (ctx) => AuthProvider(ctx.read<AuthRepository>()),
        ),

        // ── User profile (synced globally) ────────────────────────────────
        ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
          create: (ctx) =>
              UserProvider(ctx.read<AuthProvider>().currentUser),
          update: (_, auth, previous) {
            final provider = previous ?? UserProvider(null);
            if (auth.isAuthenticated && auth.currentUser != null) {
              provider.populate(auth.currentUser!);
            } else if (!auth.isAuthenticated) {
              provider.clear();
            }
            return provider;
          },
        ),

        // ── Feature providers ─────────────────────────────────────────────
        ChangeNotifierProvider<ServiceProvider>(
          create: (ctx) => ServiceProvider(ctx.read<ServiceRepository>()),
        ),
        ChangeNotifierProvider<ExpenseProvider>(
          create: (ctx) => ExpenseProvider(ctx.read<ExpenseRepository>()),
        ),
        ChangeNotifierProvider<AttendanceProvider>(
          create: (ctx) =>
              AttendanceProvider(ctx.read<AttendanceRepository>()),
        ),
        ChangeNotifierProvider<StaffProvider>(
          create: (ctx) => StaffProvider(ctx.read<StaffRepository>()),
        ),
        ChangeNotifierProvider<AnalyticsProvider>(
          create: (ctx) =>
              AnalyticsProvider(ctx.read<AnalyticsRepository>()),
        ),
        ChangeNotifierProvider<StockProvider>(
          create: (ctx) => StockProvider(ctx.read<StockRepository>()),
        ),
      ],
      child: child,
    );
  }
}
