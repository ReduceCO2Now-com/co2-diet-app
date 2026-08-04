import 'dart:async';

import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:co2diet/core/theme/spacing_tokens.dart';
import 'package:co2diet/core/theme/text_tokens.dart';
import 'package:co2diet/domain/services/ed_safety_net_checker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Which ED safety-net threshold triggered [showEdSafetyNetDialog].
///
/// Drives only the dialog's title copy — body copy, resource list, and
/// actions are identical regardless of trigger, per RESEARCH.md Pattern 4's
/// "one shared component" decision.
enum EdSafetyNetTriggerType {
  /// Calorie target override below [EdSafetyNetChecker.kcalFloor].
  calorieTarget,

  /// Target weight implying BMI below [EdSafetyNetChecker.bmiFloor].
  bmi,
}

/// Shows the shared ED safety-net blocking modal for [type].
///
/// Returns `true` only when the user explicitly taps "I understand,
/// continue" — every other outcome (declining, dismissing) resolves to
/// `false`, never `null`, so callers can treat any non-`true` result as
/// "do not save" without null-checking.
///
/// Per NFR-07/06-CONTEXT.md: this is a warning + resource, not an absolute
/// block — confirming still lets the value save (respects legitimate
/// medically-supervised edge cases). No trigger event is logged or
/// persisted anywhere in this function (zero-analytics principle).
Future<bool> showEdSafetyNetDialog(
  BuildContext context, {
  required EdSafetyNetTriggerType type,
}) async {
  final title = switch (type) {
    EdSafetyNetTriggerType.calorieTarget =>
      'This calorie target is below the safe minimum',
    EdSafetyNetTriggerType.bmi =>
      'This target weight is below a healthy weight range',
  };

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: const SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "This target is below what's generally considered safe for "
              "most adults. If you're working with a healthcare provider "
              "on a specific plan, that's fine — otherwise, here's a "
              'resource that can help.',
              style: AppTextTheme.bodyLg,
            ),
            SizedBox(height: AppSpacing.md),
            _HelplineResourceList(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Go back and revise'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('I understand, continue'),
        ),
      ],
    ),
  );

  return result ?? false;
}

/// Standalone, always-visible ED-resources info sheet — not tied to any
/// warning trigger. Consumed by the Legal Hub's "Concerned about eating or
/// your relationship with food?" entry point (Plan 06-08).
Future<void> showHelplineResourcesSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => const SafeArea(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.containerMargin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Concerned about eating or your relationship with food?',
              style: AppTextTheme.titleMd,
            ),
            SizedBox(height: AppSpacing.md),
            _HelplineResourceList(),
            SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    ),
  );
}

/// Tappable list of [EdSafetyNetResources.all] entries — phone numbers
/// launch via the `tel:` scheme, URLs via [launchUrl].
class _HelplineResourceList extends StatelessWidget {
  const _HelplineResourceList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final resource in EdSafetyNetResources.all)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.stackGap),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.name,
                  style: AppTextTheme.bodyLg.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (resource.phone.isNotEmpty)
                  InkWell(
                    onTap: () => unawaited(
                      launchUrl(Uri.parse('tel:${resource.phone}')),
                    ),
                    child: Text(
                      resource.phone,
                      style: AppTextTheme.bodySm.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                InkWell(
                  onTap: () => unawaited(
                    launchUrl(
                      Uri.parse(resource.url),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                  child: Text(
                    resource.url,
                    style: AppTextTheme.bodySm.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
