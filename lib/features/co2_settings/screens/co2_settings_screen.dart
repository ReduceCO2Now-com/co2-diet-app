import 'dart:async';

import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:co2diet/core/theme/spacing_tokens.dart';
import 'package:co2diet/core/theme/text_tokens.dart';
import 'package:co2diet/domain/entities/co2_settings.dart';
import 'package:co2diet/features/co2_settings/providers/co2_settings_notifier.dart';
import 'package:co2diet/features/co2_settings/widgets/data_quality_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The CO2 Calculation Settings screen (CO2-03).
///
/// All 7 fields (location country/region, purchasing source, shopping
/// transport, cooking method, food storage, household size, food waste
/// level) are genuinely optional — every dropdown includes an explicit
/// "Not set" option and no field has a required-field validator. Every
/// change auto-saves immediately via `Co2SettingsNotifier.saveSettings`,
/// mirroring `ProfileScreen`/`ProfileForm`'s established no-blocking-
/// validation convention.
///
/// Not yet wired into `app_router.dart` or linked from any other screen —
/// Plan 05-18 adds the route and entry points once every Wave 5 screen
/// exists.
class Co2SettingsScreen extends ConsumerWidget {
  /// Creates the [Co2SettingsScreen].
  const Co2SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(co2SettingsProvider);
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'CO2 Calculation Settings',
          style: AppTextTheme.headlineLgMobile,
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: settingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) =>
              const Center(child: Text('Error loading CO2 settings')),
          data: (settings) => _Co2SettingsBody(
            settings: settings,
            onChanged: (updated) => unawaited(
              ref.read(co2SettingsProvider.notifier).saveSettings(updated),
            ),
          ),
        ),
      ),
    );
  }
}

/// Displays the Data Quality Indicator and the 7 optional settings fields.
class _Co2SettingsBody extends StatelessWidget {
  const _Co2SettingsBody({
    required this.settings,
    required this.onChanged,
  });

  final Co2Settings settings;
  final void Function(Co2Settings) onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.containerMargin),
      children: [
        Center(child: DataQualityIndicator(dataQuality: settings.dataQuality)),
        const SizedBox(height: AppSpacing.md),
        Text(
          'None of these fields are required. Fill in as many or as few '
          'as you like -- more fields improve the accuracy of your '
          'personal footprint estimate.',
          style: AppTextTheme.bodySm.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Location country
        TextFormField(
          key: ValueKey('location-country-${settings.locationCountry}'),
          initialValue: settings.locationCountry ?? '',
          decoration: const InputDecoration(labelText: 'Location country'),
          onChanged: (raw) => onChanged(
            settings.copyWith(
              locationCountry: raw.isEmpty ? null : raw,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.stackGap),

        // Location region
        TextFormField(
          key: ValueKey('location-region-${settings.locationRegion}'),
          initialValue: settings.locationRegion ?? '',
          decoration: const InputDecoration(labelText: 'Location region'),
          onChanged: (raw) => onChanged(
            settings.copyWith(
              locationRegion: raw.isEmpty ? null : raw,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.stackGap),

        // Purchasing source
        DropdownButtonFormField<String?>(
          key: ValueKey('purchasing-source-${settings.purchasingSource}'),
          initialValue: settings.purchasingSource,
          decoration: const InputDecoration(labelText: 'Purchasing source'),
          items: const [
            DropdownMenuItem(child: Text('Not set')),
            DropdownMenuItem(value: 'supermarket', child: Text('Supermarket')),
            DropdownMenuItem(value: 'local_farm', child: Text('Local farm')),
            DropdownMenuItem(value: 'mix', child: Text('Mix')),
          ],
          onChanged: (value) =>
              onChanged(settings.copyWith(purchasingSource: value)),
        ),
        const SizedBox(height: AppSpacing.stackGap),

        // Shopping transport
        DropdownButtonFormField<String?>(
          key: ValueKey('shopping-transport-${settings.shoppingTransport}'),
          initialValue: settings.shoppingTransport,
          decoration: const InputDecoration(labelText: 'Shopping transport'),
          items: const [
            DropdownMenuItem(child: Text('Not set')),
            DropdownMenuItem(value: 'car', child: Text('Car')),
            DropdownMenuItem(
              value: 'public',
              child: Text('Public transport'),
            ),
            DropdownMenuItem(
              value: 'walk_bike',
              child: Text('Walk or bike'),
            ),
          ],
          onChanged: (value) =>
              onChanged(settings.copyWith(shoppingTransport: value)),
        ),
        const SizedBox(height: AppSpacing.stackGap),

        // Cooking method
        DropdownButtonFormField<String?>(
          key: ValueKey('cooking-method-${settings.cookingMethod}'),
          initialValue: settings.cookingMethod,
          decoration: const InputDecoration(labelText: 'Cooking method'),
          items: const [
            DropdownMenuItem(child: Text('Not set')),
            DropdownMenuItem(value: 'electric', child: Text('Electric')),
            DropdownMenuItem(value: 'gas', child: Text('Gas')),
            DropdownMenuItem(value: 'induction', child: Text('Induction')),
          ],
          onChanged: (value) =>
              onChanged(settings.copyWith(cookingMethod: value)),
        ),
        const SizedBox(height: AppSpacing.stackGap),

        // Food storage
        DropdownButtonFormField<String?>(
          key: ValueKey('food-storage-${settings.foodStorage}'),
          initialValue: settings.foodStorage,
          decoration: const InputDecoration(labelText: 'Food storage'),
          items: const [
            DropdownMenuItem(child: Text('Not set')),
            DropdownMenuItem(
              value: 'small_fridge',
              child: Text('Small fridge'),
            ),
            DropdownMenuItem(
              value: 'large_fridge_freezer',
              child: Text('Large fridge + freezer'),
            ),
          ],
          onChanged: (value) =>
              onChanged(settings.copyWith(foodStorage: value)),
        ),
        const SizedBox(height: AppSpacing.stackGap),

        // Household size
        TextFormField(
          key: ValueKey('household-size-${settings.householdSize}'),
          initialValue: settings.householdSize?.toString() ?? '',
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Household size'),
          onChanged: (raw) => onChanged(
            settings.copyWith(householdSize: int.tryParse(raw)),
          ),
        ),
        const SizedBox(height: AppSpacing.stackGap),

        // Food waste level
        DropdownButtonFormField<String?>(
          key: ValueKey('food-waste-level-${settings.foodWasteLevel}'),
          initialValue: settings.foodWasteLevel,
          decoration: const InputDecoration(labelText: 'Food waste level'),
          items: const [
            DropdownMenuItem(child: Text('Not set')),
            DropdownMenuItem(value: 'low', child: Text('Low')),
            DropdownMenuItem(value: 'medium', child: Text('Medium')),
            DropdownMenuItem(value: 'high', child: Text('High')),
          ],
          onChanged: (value) =>
              onChanged(settings.copyWith(foodWasteLevel: value)),
        ),
      ],
    );
  }
}
