import 'dart:async';

import 'package:co2diet/core/di/app_providers.dart';
import 'package:co2diet/core/di/meal_logging_providers.dart';
import 'package:co2diet/core/theme/spacing_tokens.dart';
import 'package:co2diet/domain/entities/food_item.dart';
import 'package:co2diet/domain/entities/serving_size.dart';
import 'package:co2diet/domain/entities/user_food.dart';
import 'package:co2diet/features/barcode_scan/widgets/confidence_chip.dart';
import 'package:co2diet/features/my_foods/providers/user_food_notifier.dart';
import 'package:co2diet/features/my_foods/widgets/serving_size_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Custom-food/override authoring form (LOG-10/LOG-11).
///
/// Route: `/custom-food-stub` — see the route contract documented in
/// `04-08-PLAN.md`'s `<objective>`. Accepts up to four optional query
/// params, mutually exclusive in priority order:
///
/// 1. [userFoodId] — edits an existing [UserFood] row directly.
/// 2. [overrideOf] + [overrideOfSource] — pre-fills from the original
///    catalog/cache product and saves as a new personal override.
/// 3. [barcode] — pre-fills only the barcode field (barcode no-match flow).
/// 4. [name] — pre-fills only the name field (search no-results flow).
/// 5. None of the above — a fully blank form (My Foods "+ Add Custom Food").
///
/// Only [name] and `calories` are required to save (LOG-10) — every other
/// field is optional. The CO2 estimate is resolved at save time: category
/// mode looks up `off_ref.co2_factors` via `FoodCatalogDao.getCo2ForCategory`
/// (confidence band 'medium'); manual mode stores the user-provided value
/// verbatim with no confidence band, per the "no false-precision" project
/// invariant.
class CustomFoodFormScreen extends ConsumerStatefulWidget {
  /// Creates the [CustomFoodFormScreen].
  const CustomFoodFormScreen({
    this.barcode,
    this.name,
    this.overrideOf,
    this.overrideOfSource,
    this.userFoodId,
    super.key,
  });

  /// Pre-fills the barcode field (barcode no-match flow).
  final String? barcode;

  /// Pre-fills the name field (search no-results flow).
  final String? name;

  /// The `foodRef` being overridden, when opened from "Edit this food".
  final String? overrideOf;

  /// The `foodRefSource` of [overrideOf] (`'off_ref'` or
  /// `'user_food_cache'`).
  final String? overrideOfSource;

  /// The id of an existing [UserFood] row to edit directly (My Foods list).
  final String? userFoodId;

  @override
  ConsumerState<CustomFoodFormScreen> createState() =>
      _CustomFoodFormScreenState();
}

class _CustomFoodFormScreenState extends ConsumerState<CustomFoodFormScreen> {
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _referenceAmountController = TextEditingController(text: '100');
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _sugarController = TextEditingController();
  final _fatController = TextEditingController();
  final _fiberController = TextEditingController();
  final _saltController = TextEditingController();
  final _manualCo2Controller = TextEditingController();
  final _barcodeController = TextEditingController();

  List<String> _categories = [];
  String? _selectedCategory;
  bool _manualCo2Mode = false;
  List<ServingSize> _servingSizes = const [];

  String? _existingId;
  String? _overrideOfRef;
  String? _overrideOfSource;
  bool _loading = true;

  bool get _isOverride => _overrideOfRef != null;

  bool get _isValid =>
      _nameController.text.trim().isNotEmpty &&
      double.tryParse(_caloriesController.text) != null;

  @override
  void initState() {
    super.initState();
    for (final controller in [_nameController, _caloriesController]) {
      controller.addListener(_onValidityFieldChanged);
    }
    unawaited(_initialize());
  }

  void _onValidityFieldChanged() => setState(() {});

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _referenceAmountController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _sugarController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    _saltController.dispose();
    _manualCo2Controller.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    final categories = await ref
        .read(foodCatalogDaoProvider)
        .getAvailableCo2Categories();

    UserFood? existing;
    FoodItem? original;

    final userFoodId = widget.userFoodId;
    final overrideOf = widget.overrideOf;
    final overrideOfSource = widget.overrideOfSource;

    if (userFoodId != null) {
      existing = await ref
          .read(userFoodRepositoryProvider)
          .getById(
            userFoodId,
          );
    } else if (overrideOf != null && overrideOfSource != null) {
      if (overrideOfSource == 'user_foods') {
        existing = await ref
            .read(userFoodRepositoryProvider)
            .getById(
              overrideOf,
            );
      } else {
        original = await ref
            .read(foodCatalogRepositoryProvider)
            .lookupByBarcode(
              overrideOf,
            );
      }
    }

    if (!mounted) return;

    setState(() {
      _categories = categories;
      if (existing != null) {
        _applyExisting(existing);
      } else if (original != null) {
        _applyOriginal(original);
      } else if (widget.barcode != null) {
        _barcodeController.text = widget.barcode!;
      } else if (widget.name != null) {
        _nameController.text = widget.name!;
      }
      _loading = false;
    });
  }

  void _applyExisting(UserFood food) {
    _existingId = food.id;
    _overrideOfRef = food.overrideOfRef;
    _overrideOfSource = food.overrideOfSource;
    _nameController.text = food.name;
    _brandController.text = food.brand ?? '';
    _selectedCategory = food.category;
    _referenceAmountController.text = _fmt(food.referenceAmountG);
    _caloriesController.text = _fmt(food.calories);
    _proteinController.text = _fmt(food.protein);
    _carbsController.text = _fmt(food.carbs);
    _sugarController.text = _fmt(food.sugar);
    _fatController.text = _fmt(food.fat);
    _fiberController.text = _fmt(food.fiber);
    _saltController.text = _fmt(food.salt);
    _barcodeController.text = food.barcode ?? '';
    _servingSizes = food.quickServingSizes;
    _manualCo2Mode = food.co2Source == 'manual';
    if (_manualCo2Mode) {
      _manualCo2Controller.text = _fmt(food.co2e100g);
    }
  }

  void _applyOriginal(FoodItem item) {
    _nameController.text = item.productName;
    _brandController.text = item.brand ?? '';
    _caloriesController.text = _fmt(item.calories100g);
    _proteinController.text = _fmt(item.protein100g);
    _carbsController.text = _fmt(item.carbs100g);
    _fatController.text = _fmt(item.fat100g);
    _barcodeController.text = item.barcode ?? '';
    _overrideOfRef = widget.overrideOf;
    _overrideOfSource = widget.overrideOfSource;
  }

  String _fmt(double? value) {
    if (value == null) return '';
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toString();
  }

  Future<void> _handleSave() async {
    final referenceAmount =
        double.tryParse(_referenceAmountController.text) ?? 100;
    final calories = double.tryParse(_caloriesController.text);
    if (_nameController.text.trim().isEmpty || calories == null) return;

    double? co2e100g;
    String? confidenceBand;
    String? co2Source;

    if (_manualCo2Mode) {
      final manual = double.tryParse(_manualCo2Controller.text);
      if (manual != null) {
        co2e100g = manual;
        co2Source = 'manual';
      }
    } else if (_selectedCategory != null) {
      final resolved = await ref
          .read(foodCatalogDaoProvider)
          .getCo2ForCategory(_selectedCategory!);
      if (resolved != null) {
        co2e100g = resolved;
        confidenceBand = 'medium';
        co2Source = 'category_estimate';
      }
    }

    final draft = UserFood(
      id: _existingId ?? '',
      name: _nameController.text.trim(),
      brand: _brandController.text.trim().isEmpty
          ? null
          : _brandController.text.trim(),
      category: _selectedCategory,
      referenceAmountG: referenceAmount,
      calories: calories,
      protein: double.tryParse(_proteinController.text),
      carbs: double.tryParse(_carbsController.text),
      sugar: double.tryParse(_sugarController.text),
      fat: double.tryParse(_fatController.text),
      fiber: double.tryParse(_fiberController.text),
      salt: double.tryParse(_saltController.text),
      co2e100g: co2e100g,
      confidenceBand: confidenceBand,
      co2Source: co2Source,
      barcode: _barcodeController.text.trim().isEmpty
          ? null
          : _barcodeController.text.trim(),
      quickServingSizes: _servingSizes,
      overrideOfRef: _overrideOfRef,
      overrideOfSource: _overrideOfSource,
    );

    final notifier = ref.read(userFoodProvider.notifier);
    if (_overrideOfRef != null) {
      await notifier.saveOverride(draft);
    } else {
      await notifier.saveCustomFood(draft);
    }

    if (!mounted) return;
    context.pop();
  }

  Future<void> _handleRevert() async {
    final idToRevert = widget.userFoodId ?? _existingId;
    if (idToRevert != null) {
      await ref.read(userFoodProvider.notifier).revertOverride(idToRevert);
    }
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.userFoodId != null
        ? 'Edit Custom Food'
        : (widget.overrideOf != null ? 'Override Food' : 'Add Custom Food');

    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.containerMargin),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(height: AppSpacing.stackGap),
                    TextFormField(
                      controller: _brandController,
                      decoration: const InputDecoration(labelText: 'Brand'),
                    ),
                    const SizedBox(height: AppSpacing.stackGap),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                      ),
                      items: [
                        for (final category in _categories)
                          DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ),
                      ],
                      onChanged: (value) =>
                          setState(() => _selectedCategory = value),
                    ),
                    const SizedBox(height: AppSpacing.stackGap),
                    TextFormField(
                      controller: _referenceAmountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Reference amount (g)',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.stackGap),
                    TextFormField(
                      controller: _caloriesController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Calories (required)',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.stackGap),
                    TextFormField(
                      controller: _proteinController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Protein (g)',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.stackGap),
                    TextFormField(
                      controller: _carbsController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Carbs (g)',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.stackGap),
                    TextFormField(
                      controller: _sugarController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Sugar (g)',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.stackGap),
                    TextFormField(
                      controller: _fatController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(labelText: 'Fat (g)'),
                    ),
                    const SizedBox(height: AppSpacing.stackGap),
                    TextFormField(
                      controller: _fiberController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Fiber (g)',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.stackGap),
                    TextFormField(
                      controller: _saltController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Salt (g)',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'CO2 estimate',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.stackGap),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: false,
                          label: Text('Estimate from category'),
                        ),
                        ButtonSegment(
                          value: true,
                          label: Text('Enter manually'),
                        ),
                      ],
                      selected: {_manualCo2Mode},
                      onSelectionChanged: (selection) =>
                          setState(() => _manualCo2Mode = selection.first),
                    ),
                    const SizedBox(height: AppSpacing.stackGap),
                    if (_manualCo2Mode)
                      TextFormField(
                        controller: _manualCo2Controller,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'kg CO2e per kg (user-provided)',
                        ),
                      )
                    else
                      const ConfidenceChip(band: 'medium'),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _barcodeController,
                      decoration: const InputDecoration(
                        labelText: 'Barcode',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Quick serving sizes',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.stackGap),
                    ServingSizeEditor(
                      initial: _servingSizes,
                      onChanged: (sizes) => _servingSizes = sizes,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton(
                      onPressed: _isValid
                          ? () => unawaited(_handleSave())
                          : null,
                      child: const Text('Save'),
                    ),
                    if (_isOverride) ...[
                      const SizedBox(height: AppSpacing.stackGap),
                      TextButton(
                        onPressed: () => unawaited(_handleRevert()),
                        child: const Text('Revert to original'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
