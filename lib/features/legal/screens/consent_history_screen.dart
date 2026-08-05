import 'package:co2diet/core/di/legal_providers.dart';
import 'package:co2diet/core/theme/spacing_tokens.dart';
import 'package:co2diet/core/theme/text_tokens.dart';
import 'package:co2diet/domain/entities/consent_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Translates each raw `consentsGiven` checkbox identifier (matching
/// `LegalConsentScreen`'s literal string set, Plan 06-07) into a short
/// plain-language display phrase -- the raw identifiers themselves must
/// never reach the UI (PRIV-06).
const Map<String, String> _consentLabels = {
  'terms': 'Terms of Service',
  'privacy': 'Privacy Policy',
  'not_medical_advice': 'Health Disclaimer',
  'user_responsibility': 'Responsibility acknowledgment',
  'age_16_plus': 'Age 16+ confirmation',
};

/// Formats a UTC [DateTime] as `'yyyy-MM-dd HH:mm'` UTC.
final _timestampFormat = DateFormat('yyyy-MM-dd HH:mm');

/// Read-only Consent History screen (PRIV-06) -- the first real UI
/// consumer of Phase 1's dormant `ConsentRecordsDao.watchConsents()`,
/// via `IConsentRepository.watchConsents()`.
///
/// Every `ConsentEvent` the user has ever recorded renders in plain
/// language: timestamp, app version, policy version, and a
/// human-readable translation of what was accepted. Never builds a new
/// mutation path -- this screen only reads.
class ConsentHistoryScreen extends ConsumerWidget {
  /// Creates the [ConsentHistoryScreen].
  const ConsentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(consentRepositoryProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Consent History'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: StreamBuilder<List<ConsentEvent>>(
          stream: repository.watchConsents(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(
                child: Text('Unable to load consent history.'),
              );
            }

            final events = snapshot.data ?? const [];
            if (events.isEmpty) {
              return const Center(
                child: Text('No consent recorded yet.'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.containerMargin),
              itemCount: events.length,
              itemBuilder: (context, index) =>
                  _ConsentEventCard(event: events[index]),
            );
          },
        ),
      ),
    );
  }
}

/// One recorded consent event, rendered as a [Card]: UTC timestamp, app
/// version, policy version, and a comma-joined plain-language list of
/// what was accepted.
class _ConsentEventCard extends StatelessWidget {
  const _ConsentEventCard({required this.event});

  final ConsentEvent event;

  @override
  Widget build(BuildContext context) {
    final consentLabels = event.consentsGiven
        .map((id) => _consentLabels[id] ?? id)
        .join(', ');
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.stackGap),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_timestampFormat.format(event.createdAt.toUtc())} UTC',
              style: AppTextTheme.bodyLg.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            Text(
              'App v${event.appVersion}',
              style: AppTextTheme.bodySm.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              'Policy v${event.policyVersion}',
              style: AppTextTheme.bodySm.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.base),
            Text(consentLabels, style: AppTextTheme.bodySm),
          ],
        ),
      ),
    );
  }
}
