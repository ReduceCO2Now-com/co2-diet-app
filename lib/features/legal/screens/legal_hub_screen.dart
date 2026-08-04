import 'dart:async';

import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:co2diet/core/theme/spacing_tokens.dart';
import 'package:co2diet/core/theme/text_tokens.dart';
import 'package:co2diet/core/widgets/ed_safety_net_dialog.dart';
import 'package:co2diet/features/legal/screens/legal_document_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

/// The real, current-until-legal-review contact address for this App
/// (`docs/legal/impressum.md`'s placeholder-but-plausible "Contact" line,
/// drafted in Plan 06-02) — every legal document that mentions "our
/// current contact details" ultimately resolves here.
const _contactEmail = 'contact@reduceco2now.example';

/// Maps a [LegalDocId] to the `doc=` query-param slug every Legal Hub
/// entry point uses, matching the snake_case convention
/// `LegalConsentScreen` (Plan 06-07) already committed to
/// (`doc=health_disclaimer`, not `doc=healthDisclaimer`) — `LegalDocId`'s
/// raw `.name` getter is camelCase for `healthDisclaimer`, so a direct
/// `docId.name` interpolation would silently diverge from the route
/// convention Plan 06-09's router wiring must parse uniformly.
extension _LegalDocRouteSlug on LegalDocId {
  String get routeSlug {
    switch (this) {
      case LegalDocId.terms:
        return 'terms';
      case LegalDocId.privacy:
        return 'privacy';
      case LegalDocId.healthDisclaimer:
        return 'health_disclaimer';
      case LegalDocId.impressum:
        return 'impressum';
    }
  }
}

/// The central "government-style clarity" Legal Hub (LEG-01/02/03):
/// About, all four Legal Documents, a redirect-only "Your Rights"
/// explainer, a link into the read-only Consent History screen
/// (PRIV-06), a standalone always-visible ED-resources entry point, and
/// a real contact address.
///
/// Deliberately contains no FAQ section and no Discord/community link --
/// cut for v1 per `06-CONTEXT.md`'s Deferred Ideas, same reasoning as
/// Phase 5's Weight Tracking "Learn More" cut.
///
/// Per `06-CONTEXT.md`/`06-RESEARCH.md`'s Anti-Pattern list, "Your
/// Rights" never builds a new mutation/action screen -- every action
/// tile pushes an existing Phase 5 screen (`/backup-restore`) verbatim.
class LegalHubScreen extends StatelessWidget {
  /// Creates the [LegalHubScreen].
  const LegalHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Legal & Privacy Hub'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.containerMargin),
          children: [
            // ── About ──────────────────────────────────────────────────
            const Text('About', style: AppTextTheme.titleMd),
            const SizedBox(height: AppSpacing.stackGap),
            const Text(
              'CO₂ Diet is a privacy-first, offline-first nutrition and '
              'CO₂ footprint tracker. Your data stays on your device by '
              'default, and the App works fully offline for its core '
              'features.',
              style: AppTextTheme.bodyLg,
            ),
            const SizedBox(height: AppSpacing.base),
            Text(
              'CO₂ Diet is built on open-source software -- see '
              '"Open source licenses" in Settings for every package '
              'license.',
              style: AppTextTheme.bodySm.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Legal Documents ────────────────────────────────────────
            const Text('Legal Documents', style: AppTextTheme.titleMd),
            const SizedBox(height: AppSpacing.stackGap),
            for (final docId in LegalDocId.values)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.description_outlined),
                title: Text(docId.title),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(
                  '/legal-hub/document?doc=${docId.routeSlug}',
                ),
              ),
            const Divider(height: AppSpacing.lg),

            // ── Your Rights ────────────────────────────────────────────
            const Text('Your Rights', style: AppTextTheme.titleMd),
            const SizedBox(height: AppSpacing.stackGap),
            const Text(
              'Under GDPR, you have rights over your data. Every one of '
              'these rights is already satisfied by existing App '
              'features -- nothing below is a new action:',
              style: AppTextTheme.bodyLg,
            ),
            const SizedBox(height: AppSpacing.stackGap),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.download_outlined),
              title: const Text('Access & Portability'),
              subtitle: const Text(
                'Export all your data at any time via Backup & Restore.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/backup-restore'),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.base),
              child: Text(
                'Rectify: you can edit or correct any entry directly, '
                'anywhere in the App -- this is already possible without '
                'a separate request.',
                style: AppTextTheme.bodySm,
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.delete_outline),
              title: const Text('Consent Withdrawal'),
              subtitle: const Text(
                'Delete all local data at any time via the Danger Zone '
                'in Backup & Restore. Uninstalling the App is also '
                'always an option.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/backup-restore'),
            ),
            const Divider(height: AppSpacing.lg),

            // ── View my consent history ───────────────────────────────
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history),
              title: const Text('View my consent history'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/legal-hub/consent-history'),
            ),
            const Divider(height: AppSpacing.lg),

            // ── Concerned about eating? ────────────────────────────────
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.favorite_border),
              title: const Text(
                'Concerned about eating or your relationship with food?',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => unawaited(showHelplineResourcesSheet(context)),
            ),
            const Divider(height: AppSpacing.lg),

            // ── Contact ────────────────────────────────────────────────
            const Text('Contact', style: AppTextTheme.titleMd),
            const SizedBox(height: AppSpacing.stackGap),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.email_outlined),
              title: const Text(_contactEmail),
              onTap: () => unawaited(
                launchUrl(Uri.parse('mailto:$_contactEmail')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
