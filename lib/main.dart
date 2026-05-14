import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kl16pro/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_config.dart';
import 'core/theme/app_theme.dart';
import 'injection/injection.dart';
import 'providers/auth_provider.dart';
import 'providers/settings_provider.dart';
import 'routes/app_router.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase — skip in mock mode (no google-services.json needed)
  if (!kUseMockData) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // ── System UI ─────────────────────────────────────────────────────────────
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0D0D0D),
    systemNavigationBarIconBrightness: Brightness.light,),);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await SharedPreferences.getInstance();

  runApp(const KL16GarageProApp());
}

class KL16GarageProApp extends StatelessWidget {
  const KL16GarageProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppInjection(
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, _) => const _RouterRoot(),
      ),
    );
  }
}

class _RouterRoot extends StatefulWidget {
  const _RouterRoot();

  @override
  State<_RouterRoot> createState() => _RouterRootState();
}

class _RouterRootState extends State<_RouterRoot> {
  late final _router = createRouter(context.read<AuthProvider>());

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return MaterialApp.router(
      title: 'KL16 Garage Pro',
      debugShowCheckedModeBanner: false,
      themeMode:
          settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: _router,
    );
  }
}
