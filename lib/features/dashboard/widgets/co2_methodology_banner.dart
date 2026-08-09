import 'package:co2diet/domain/services/methodology_version_checker.dart';
import 'package:co2diet/features/dashboard/providers/methodology_banner_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The local-only CO2 methodology-update announcement banner (CO2-04),
/// shown at the top of the Dashboard -- above `ModeIndicator` -- only when
/// [showMethodologyBannerProvider] resolves `true`.
///
/// Structurally mirrors `Co2ProfilePromptCard` (Material card,
/// `colorScheme.surfaceContainerLow` background, `InkWell` body, dismiss
/// `IconButton`), with two independent tap targets: the card body ("Learn
/// more" -- reuses the existing Estimate Transparency panel via
/// `/data-analysis`) and the dismiss button (persists the current
/// methodology version so this exact version never reappears once
/// dismissed, per-version -- a future real version bump reopens it).
///
/// Renders `SizedBox.shrink()` while loading, on error, or when the
/// provider resolves `false` -- the mechanism stays fully dormant this
/// phase since [currentCo2MethodologyVersion] is never bumped.
class Co2MethodologyBanner extends ConsumerWidget {
  /// Creates a [Co2MethodologyBanner].
  const Co2MethodologyBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showAsync = ref.watch(showMethodologyBannerProvider);

    return showAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, st) => const SizedBox.shrink(),
      data: (show) {
        if (!show) return const SizedBox.shrink();

        final colorScheme = Theme.of(context).colorScheme;

        return Material(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () => context.push('/data-analysis'),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.eco_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'CO₂ estimates updated with methodology '
                      'v$currentCo2MethodologyVersion -- your past entries '
                      'keep their original estimates.',
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => ref
                        .read(methodologyBannerDismissalProvider.notifier)
                        .dismiss(currentCo2MethodologyVersion),
                    tooltip: 'Dismiss',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
