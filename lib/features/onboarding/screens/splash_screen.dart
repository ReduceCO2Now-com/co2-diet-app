import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:co2diet/core/theme/spacing_tokens.dart';
import 'package:co2diet/core/theme/text_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// First screen shown on app launch. Auto-advances to the Welcome screen
/// (`/welcome`) after a short delay with no user interaction and no
/// buttons — per ONBD-01, the splash must not require a tap to proceed.
///
/// 2s auto-advance, the concrete constant chosen from ONBD-01's 2-3s
/// spec window.
class SplashScreen extends StatefulWidget {
  /// Creates [SplashScreen].
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go('/welcome');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.eco, size: 64, color: AppColors.primary),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'CO₂ Diet',
                style: AppTextTheme.displayLg.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Track calories, protein, and estimated CO₂ — '
                'privately, offline.',
                textAlign: TextAlign.center,
                style: AppTextTheme.bodyLg.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const CircularProgressIndicator(color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
