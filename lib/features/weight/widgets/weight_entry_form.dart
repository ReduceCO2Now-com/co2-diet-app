import 'package:co2diet/core/theme/color_tokens.dart';
import 'package:co2diet/core/theme/spacing_tokens.dart';
import 'package:co2diet/core/theme/text_tokens.dart';
import 'package:co2diet/domain/entities/weight_entry.dart';
import 'package:co2diet/domain/entities/weight_unit.dart';
import 'package:co2diet/features/weight/providers/weight_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Compact bottom-sheet-style form for logging a new weigh-in (WT-01).
///
/// Fields: numeric value, kg/lb unit toggle, date picker (defaults to
/// today), optional free-text note. The only required condition to save is
/// a parseable numeric value -- mirrors LOG-10's minimal-required-field
/// philosophy (no blocking validation beyond that).
///
/// Opened via `showModalBottomSheet` from `WeightScreen`'s "Log weight"
/// button (Plan 05-13 Task 2), mirroring
/// `showFoodDetailSheet`'s `showModalBottomSheet` pattern.
class WeightEntryForm extends ConsumerStatefulWidget {
  /// Creates a [WeightEntryForm].
  const WeightEntryForm({super.key});

  @override
  ConsumerState<WeightEntryForm> createState() => _WeightEntryFormState();
}

class _WeightEntryFormState extends ConsumerState<WeightEntryForm> {
  final _valueController = TextEditingController();
  final _noteController = TextEditingController();
  WeightUnit _unit = WeightUnit.kg;
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _valueController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final parsed = double.tryParse(_valueController.text);
    if (parsed == null) return;

    final draft = WeightEntry(
      id: '',
      value: parsed,
      unit: _unit,
      loggedAt: _date,
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );

    await ref.read(weightProvider.notifier).logWeight(draft);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: AppSpacing.containerMargin,
        right: AppSpacing.containerMargin,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Log weight', style: AppTextTheme.titleMd),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _valueController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Weight'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              SegmentedButton<WeightUnit>(
                segments: const [
                  ButtonSegment(value: WeightUnit.kg, label: Text('kg')),
                  ButtonSegment(value: WeightUnit.lb, label: Text('lb')),
                ],
                selected: {_unit},
                showSelectedIcon: false,
                onSelectionChanged: (selected) =>
                    setState(() => _unit = selected.first),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.stackGap),
          InkWell(
            onTap: _pickDate,
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Date'),
              child: Text(
                '${_date.year}-${_date.month.toString().padLeft(2, '0')}-'
                '${_date.day.toString().padLeft(2, '0')}',
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.stackGap),
          TextFormField(
            controller: _noteController,
            decoration: const InputDecoration(labelText: 'Note (optional)'),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
