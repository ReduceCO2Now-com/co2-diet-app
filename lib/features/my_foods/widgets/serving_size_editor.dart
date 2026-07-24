import 'package:co2diet/core/theme/spacing_tokens.dart';
import 'package:co2diet/domain/entities/serving_size.dart';
import 'package:flutter/material.dart';

/// Dynamic list editor for a `UserFood.quickServingSizes` value.
///
/// Renders one label+grams [TextFormField] pair per [ServingSize], each with
/// a remove (×) action, plus a trailing "+ Add serving size" button that
/// appends a new empty row. Calls [onChanged] with the current list on every
/// edit (add, remove, or field change) so the parent form can hold the
/// authoritative value at save time.
class ServingSizeEditor extends StatefulWidget {
  /// Creates a [ServingSizeEditor] seeded with [initial] serving sizes.
  const ServingSizeEditor({
    required this.initial,
    required this.onChanged,
    super.key,
  });

  /// The initial list of serving sizes (e.g. when editing an existing
  /// `UserFood`).
  final List<ServingSize> initial;

  /// Invoked with the current list of serving sizes whenever a row is
  /// added, removed, or edited.
  final ValueChanged<List<ServingSize>> onChanged;

  @override
  State<ServingSizeEditor> createState() => _ServingSizeEditorState();
}

class _ServingSizeEditorState extends State<ServingSizeEditor> {
  final List<_ServingSizeRowControllers> _rows = [];

  @override
  void initState() {
    super.initState();
    for (final size in widget.initial) {
      _rows.add(_ServingSizeRowControllers.fromServingSize(size));
    }
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  void _emitChange() {
    widget.onChanged(_rows.map((row) => row.toServingSize()).toList());
  }

  void _addRow() {
    setState(() {
      _rows.add(_ServingSizeRowControllers.empty());
    });
    _emitChange();
  }

  void _removeRow(int index) {
    setState(() {
      _rows.removeAt(index).dispose();
    });
    _emitChange();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _rows.length; i++)
          Padding(
            key: ValueKey('serving-size-row-$i'),
            padding: const EdgeInsets.only(bottom: AppSpacing.stackGap),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    key: ValueKey('serving-size-label-$i'),
                    controller: _rows[i].label,
                    decoration: const InputDecoration(labelText: 'Label'),
                    onChanged: (_) => _emitChange(),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: TextFormField(
                    key: ValueKey('serving-size-grams-$i'),
                    controller: _rows[i].grams,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Grams'),
                    onChanged: (_) => _emitChange(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Remove serving size',
                  onPressed: () => _removeRow(i),
                ),
              ],
            ),
          ),
        TextButton.icon(
          onPressed: _addRow,
          icon: const Icon(Icons.add),
          label: const Text('Add serving size'),
        ),
      ],
    );
  }
}

/// Holds the [TextEditingController]s for a single serving-size row.
class _ServingSizeRowControllers {
  _ServingSizeRowControllers(this.label, this.grams);

  factory _ServingSizeRowControllers.empty() => _ServingSizeRowControllers(
    TextEditingController(),
    TextEditingController(),
  );

  factory _ServingSizeRowControllers.fromServingSize(ServingSize size) =>
      _ServingSizeRowControllers(
        TextEditingController(text: size.label),
        TextEditingController(text: _formatGrams(size.grams)),
      );

  final TextEditingController label;
  final TextEditingController grams;

  static String _formatGrams(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toString();

  ServingSize toServingSize() =>
      ServingSize(label: label.text, grams: double.tryParse(grams.text) ?? 0);

  void dispose() {
    label.dispose();
    grams.dispose();
  }
}
