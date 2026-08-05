import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:co2diet/core/theme/spacing_tokens.dart';
import 'package:co2diet/core/theme/text_tokens.dart';
import 'package:co2diet/features/onboarding/providers/onboarding_gate_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class _CarouselSlide {
  const _CarouselSlide({
    required this.icon,
    required this.heading,
    required this.body,
  });

  final IconData icon;
  final String heading;
  final String body;
}

const _slides = [
  _CarouselSlide(
    icon: Icons.restaurant,
    heading: 'Every food choice has an impact',
    body:
        'What you eat affects your health and the planet. CO₂ Diet '
        'helps you see both, side by side, without judgment.',
  ),
  _CarouselSlide(
    icon: Icons.query_stats,
    heading: 'How CO₂ scoring works',
    body:
        'Estimates combine production, transport, and processing '
        'factors. We show a confidence band (High/Medium/Low) with '
        'every number, never a false-precision figure — the data is '
        'an honest estimate, not a verdict.',
  ),
  _CarouselSlide(
    icon: Icons.trending_up,
    heading: 'What you can do',
    body:
        'Log meals in seconds, compare choices at a glance, and '
        'track your progress over time — all on your device, '
        'privately.',
  ),
];

/// Final onboarding screen ("How CO₂ Diet Works") — a 3-slide swipeable
/// carousel shown after Profile Setup, before the Dashboard.
///
/// Both exit paths ("Skip intro" and "Go to Dashboard") persist
/// [OnboardingGateNotifier.completeOnboarding] before navigating, so an
/// app restart never re-shows onboarding (ONBD-05).
class OnboardingCarouselScreen extends ConsumerStatefulWidget {
  /// Creates [OnboardingCarouselScreen].
  const OnboardingCarouselScreen({super.key});

  @override
  ConsumerState<OnboardingCarouselScreen> createState() =>
      _OnboardingCarouselScreenState();
}

class _OnboardingCarouselScreenState
    extends ConsumerState<OnboardingCarouselScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    await ref.read(onboardingGateProvider.notifier).completeOnboarding();
    if (mounted) context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final isLastSlide = _page == _slides.length - 1;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                ),
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: const Text('Skip intro'),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (page) => setState(() => _page = page),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(slide.icon, size: 72, color: AppColors.primary),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          slide.heading,
                          textAlign: TextAlign.center,
                          style: AppTextTheme.headlineLgMobile.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          slide.body,
                          textAlign: TextAlign.center,
                          style: AppTextTheme.bodyLg.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (index) {
                final isActive = index == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base / 2,
                  ),
                  width: isActive ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary
                        : colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: SizedBox(
                width: double.infinity,
                height: isLastSlide ? null : 0,
                child: isLastSlide
                    ? FilledButton(
                        onPressed: _finishOnboarding,
                        child: const Text('Go to Dashboard'),
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
