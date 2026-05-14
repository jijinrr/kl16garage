import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// Displays an animated "You're offline" banner at the top of any screen
/// when the device has no network connectivity.
///
/// Usage: wrap your Scaffold body with [OfflineBanner] at the shell level.
class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key, required this.child});

  final Widget child;

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _slide;
  late final StreamSubscription<List<ConnectivityResult>> _sub;

  bool _isOffline = false;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slide = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    // Seed with current state
    Connectivity().checkConnectivity().then(_onResult);

    // Listen for changes
    _sub = Connectivity()
        .onConnectivityChanged
        .listen((results) => _onResult(results));
  }

  void _onResult(List<ConnectivityResult> results) {
    final offline = results.every((r) => r == ConnectivityResult.none);
    if (offline == _isOffline) return;
    setState(() => _isOffline = offline);
    if (offline) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizeTransition(
          sizeFactor: _slide,
          axisAlignment: -1,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.pagePaddingH,
              vertical: AppSizes.sm,
            ),
            color: AppColors.warning,
            child: Row(
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  size: AppSizes.iconSm,
                  color: Colors.black87,
                ),
                const SizedBox(width: AppSizes.sm),
                const Expanded(
                  child: Text(
                    'No internet connection — showing cached data',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: AppSizes.fontXs,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}
