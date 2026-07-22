import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Offline methodology documentation screen satisfying LEG-05.
///
/// Displays AGRIBALYSE v3.1.1 attribution, confidence band definitions,
/// and a link to the full methodology doc on GitHub. This screen is
/// accessible from [ConfidenceExplanationSheet] via the '/methodology' route.
///
/// T-03-04-01 (accept): GitHub link opens in system browser — no PII sent.
class MethodologyScreen extends StatelessWidget {
  /// Creates [MethodologyScreen].
  const MethodologyScreen({super.key});

  static const String _methodologyUrl =
      'https://github.com/ReduceCO2Now/Co2-diet-app/blob/main/docs/CO2_METHODOLOGY.md';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('CO₂ Methodology')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- About CO₂e estimates ---
            Text('About CO₂e estimates', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'CO₂e (carbon dioxide equivalent) measures the climate impact of '
              'food production per kg of product. Values include production, '
              'processing, and packaging — not transport to your home.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            // --- Data source ---
            Text('Data source', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Source ADEME, données AGRIBALYSE v3.1.1',
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'INRAE/ADEME, 2023. AGRIBALYSE v3.1.1. '
              'Licence Ouverte / Open Licence v2.0 (Etalab). '
              'Available at: data.ademe.fr',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'DOI: 10.57745/B5DTRR (DATAVERSE)',
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 24),

            // --- Confidence bands ---
            Text('Confidence bands', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            const _ConfidenceBandRow(
              band: 'High',
              description:
                  'Product-specific LCA value: the exact barcode was matched '
                  'to a CIQUAL product code with a measured lifecycle assessment.',
            ),
            const SizedBox(height: 8),
            const _ConfidenceBandRow(
              band: 'Medium',
              description:
                  "Category-average estimate: the product's food category was "
                  'matched to an AGRIBALYSE food group; the displayed value is '
                  'the median CO₂e for that group.',
            ),
            const SizedBox(height: 8),
            Text(
              'No CO₂ estimate shown: the app shows no CO₂ estimate rather '
              'than display a poorly-sourced guess.',
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 24),

            // --- Full documentation ---
            Text('Full documentation', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: const Text('View full methodology on GitHub'),
              onPressed: () => unawaited(
                launchUrl(
                  Uri.parse(_methodologyUrl),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single confidence band description row inside [MethodologyScreen].
class _ConfidenceBandRow extends StatelessWidget {
  const _ConfidenceBandRow({
    required this.band,
    required this.description,
  });

  final String band;
  final String description;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$band: ',
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        Expanded(
          child: Text(description, style: textTheme.bodyMedium),
        ),
      ],
    );
  }
}
