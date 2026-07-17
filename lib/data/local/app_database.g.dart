// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UserProfileTableTable extends UserProfileTable
    with TableInfo<$UserProfileTableTable, UserProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfileTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcMillisMeta = const VerificationMeta(
    'hlcMillis',
  );
  @override
  late final GeneratedColumn<BigInt> hlcMillis = GeneratedColumn<BigInt>(
    'hlc_millis',
    aliasedName,
    false,
    type: DriftSqlType.bigInt,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcCounterMeta = const VerificationMeta(
    'hlcCounter',
  );
  @override
  late final GeneratedColumn<int> hlcCounter = GeneratedColumn<int>(
    'hlc_counter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hlcNodeIdMeta = const VerificationMeta(
    'hlcNodeId',
  );
  @override
  late final GeneratedColumn<String> hlcNodeId = GeneratedColumn<String>(
    'hlc_node_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
    'age',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activityLevelMeta = const VerificationMeta(
    'activityLevel',
  );
  @override
  late final GeneratedColumn<String> activityLevel = GeneratedColumn<String>(
    'activity_level',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dietaryPreferenceMeta = const VerificationMeta(
    'dietaryPreference',
  );
  @override
  late final GeneratedColumn<String> dietaryPreference =
      GeneratedColumn<String>(
        'dietary_preference',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _goalMeta = const VerificationMeta('goal');
  @override
  late final GeneratedColumn<String> goal = GeneratedColumn<String>(
    'goal',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitsMeta = const VerificationMeta('units');
  @override
  late final GeneratedColumn<String> units = GeneratedColumn<String>(
    'units',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('metric'),
  );
  static const VerificationMeta _kcalTargetMeta = const VerificationMeta(
    'kcalTarget',
  );
  @override
  late final GeneratedColumn<double> kcalTarget = GeneratedColumn<double>(
    'kcal_target',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _proteinGTargetMeta = const VerificationMeta(
    'proteinGTarget',
  );
  @override
  late final GeneratedColumn<double> proteinGTarget = GeneratedColumn<double>(
    'protein_g_target',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _carbsGTargetMeta = const VerificationMeta(
    'carbsGTarget',
  );
  @override
  late final GeneratedColumn<double> carbsGTarget = GeneratedColumn<double>(
    'carbs_g_target',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fatGTargetMeta = const VerificationMeta(
    'fatGTarget',
  );
  @override
  late final GeneratedColumn<double> fatGTarget = GeneratedColumn<double>(
    'fat_g_target',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _co2GTargetMeta = const VerificationMeta(
    'co2GTarget',
  );
  @override
  late final GeneratedColumn<double> co2GTarget = GeneratedColumn<double>(
    'co2_g_target',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kcalIsOverriddenMeta = const VerificationMeta(
    'kcalIsOverridden',
  );
  @override
  late final GeneratedColumn<bool> kcalIsOverridden = GeneratedColumn<bool>(
    'kcal_is_overridden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("kcal_is_overridden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _proteinIsOverriddenMeta =
      const VerificationMeta('proteinIsOverridden');
  @override
  late final GeneratedColumn<bool> proteinIsOverridden = GeneratedColumn<bool>(
    'protein_is_overridden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("protein_is_overridden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _carbsIsOverriddenMeta = const VerificationMeta(
    'carbsIsOverridden',
  );
  @override
  late final GeneratedColumn<bool> carbsIsOverridden = GeneratedColumn<bool>(
    'carbs_is_overridden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("carbs_is_overridden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _fatIsOverriddenMeta = const VerificationMeta(
    'fatIsOverridden',
  );
  @override
  late final GeneratedColumn<bool> fatIsOverridden = GeneratedColumn<bool>(
    'fat_is_overridden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("fat_is_overridden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _co2IsOverriddenMeta = const VerificationMeta(
    'co2IsOverridden',
  );
  @override
  late final GeneratedColumn<bool> co2IsOverridden = GeneratedColumn<bool>(
    'co2_is_overridden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("co2_is_overridden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _co2MethodologyVersionMeta =
      const VerificationMeta('co2MethodologyVersion');
  @override
  late final GeneratedColumn<String> co2MethodologyVersion =
      GeneratedColumn<String>(
        'co2_methodology_version',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('1.0'),
      );
  static const VerificationMeta _localeTagMeta = const VerificationMeta(
    'localeTag',
  );
  @override
  late final GeneratedColumn<String> localeTag = GeneratedColumn<String>(
    'locale_tag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    hlcMillis,
    hlcCounter,
    hlcNodeId,
    dirty,
    deletedAt,
    age,
    gender,
    heightCm,
    weightKg,
    activityLevel,
    dietaryPreference,
    goal,
    units,
    kcalTarget,
    proteinGTarget,
    carbsGTarget,
    fatGTarget,
    co2GTarget,
    kcalIsOverridden,
    proteinIsOverridden,
    carbsIsOverridden,
    fatIsOverridden,
    co2IsOverridden,
    co2MethodologyVersion,
    localeTag,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profile_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('hlc_millis')) {
      context.handle(
        _hlcMillisMeta,
        hlcMillis.isAcceptableOrUnknown(data['hlc_millis']!, _hlcMillisMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcMillisMeta);
    }
    if (data.containsKey('hlc_counter')) {
      context.handle(
        _hlcCounterMeta,
        hlcCounter.isAcceptableOrUnknown(data['hlc_counter']!, _hlcCounterMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcCounterMeta);
    }
    if (data.containsKey('hlc_node_id')) {
      context.handle(
        _hlcNodeIdMeta,
        hlcNodeId.isAcceptableOrUnknown(data['hlc_node_id']!, _hlcNodeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_hlcNodeIdMeta);
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('age')) {
      context.handle(
        _ageMeta,
        age.isAcceptableOrUnknown(data['age']!, _ageMeta),
      );
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('activity_level')) {
      context.handle(
        _activityLevelMeta,
        activityLevel.isAcceptableOrUnknown(
          data['activity_level']!,
          _activityLevelMeta,
        ),
      );
    }
    if (data.containsKey('dietary_preference')) {
      context.handle(
        _dietaryPreferenceMeta,
        dietaryPreference.isAcceptableOrUnknown(
          data['dietary_preference']!,
          _dietaryPreferenceMeta,
        ),
      );
    }
    if (data.containsKey('goal')) {
      context.handle(
        _goalMeta,
        goal.isAcceptableOrUnknown(data['goal']!, _goalMeta),
      );
    }
    if (data.containsKey('units')) {
      context.handle(
        _unitsMeta,
        units.isAcceptableOrUnknown(data['units']!, _unitsMeta),
      );
    }
    if (data.containsKey('kcal_target')) {
      context.handle(
        _kcalTargetMeta,
        kcalTarget.isAcceptableOrUnknown(data['kcal_target']!, _kcalTargetMeta),
      );
    }
    if (data.containsKey('protein_g_target')) {
      context.handle(
        _proteinGTargetMeta,
        proteinGTarget.isAcceptableOrUnknown(
          data['protein_g_target']!,
          _proteinGTargetMeta,
        ),
      );
    }
    if (data.containsKey('carbs_g_target')) {
      context.handle(
        _carbsGTargetMeta,
        carbsGTarget.isAcceptableOrUnknown(
          data['carbs_g_target']!,
          _carbsGTargetMeta,
        ),
      );
    }
    if (data.containsKey('fat_g_target')) {
      context.handle(
        _fatGTargetMeta,
        fatGTarget.isAcceptableOrUnknown(
          data['fat_g_target']!,
          _fatGTargetMeta,
        ),
      );
    }
    if (data.containsKey('co2_g_target')) {
      context.handle(
        _co2GTargetMeta,
        co2GTarget.isAcceptableOrUnknown(
          data['co2_g_target']!,
          _co2GTargetMeta,
        ),
      );
    }
    if (data.containsKey('kcal_is_overridden')) {
      context.handle(
        _kcalIsOverriddenMeta,
        kcalIsOverridden.isAcceptableOrUnknown(
          data['kcal_is_overridden']!,
          _kcalIsOverriddenMeta,
        ),
      );
    }
    if (data.containsKey('protein_is_overridden')) {
      context.handle(
        _proteinIsOverriddenMeta,
        proteinIsOverridden.isAcceptableOrUnknown(
          data['protein_is_overridden']!,
          _proteinIsOverriddenMeta,
        ),
      );
    }
    if (data.containsKey('carbs_is_overridden')) {
      context.handle(
        _carbsIsOverriddenMeta,
        carbsIsOverridden.isAcceptableOrUnknown(
          data['carbs_is_overridden']!,
          _carbsIsOverriddenMeta,
        ),
      );
    }
    if (data.containsKey('fat_is_overridden')) {
      context.handle(
        _fatIsOverriddenMeta,
        fatIsOverridden.isAcceptableOrUnknown(
          data['fat_is_overridden']!,
          _fatIsOverriddenMeta,
        ),
      );
    }
    if (data.containsKey('co2_is_overridden')) {
      context.handle(
        _co2IsOverriddenMeta,
        co2IsOverridden.isAcceptableOrUnknown(
          data['co2_is_overridden']!,
          _co2IsOverriddenMeta,
        ),
      );
    }
    if (data.containsKey('co2_methodology_version')) {
      context.handle(
        _co2MethodologyVersionMeta,
        co2MethodologyVersion.isAcceptableOrUnknown(
          data['co2_methodology_version']!,
          _co2MethodologyVersionMeta,
        ),
      );
    }
    if (data.containsKey('locale_tag')) {
      context.handle(
        _localeTagMeta,
        localeTag.isAcceptableOrUnknown(data['locale_tag']!, _localeTagMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      hlcMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.bigInt,
        data['${effectivePrefix}hlc_millis'],
      )!,
      hlcCounter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hlc_counter'],
      )!,
      hlcNodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hlc_node_id'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      age: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age'],
      ),
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      ),
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      ),
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      activityLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_level'],
      ),
      dietaryPreference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dietary_preference'],
      ),
      goal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal'],
      ),
      units: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}units'],
      )!,
      kcalTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kcal_target'],
      ),
      proteinGTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_g_target'],
      ),
      carbsGTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs_g_target'],
      ),
      fatGTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_g_target'],
      ),
      co2GTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}co2_g_target'],
      ),
      kcalIsOverridden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}kcal_is_overridden'],
      )!,
      proteinIsOverridden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}protein_is_overridden'],
      )!,
      carbsIsOverridden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}carbs_is_overridden'],
      )!,
      fatIsOverridden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}fat_is_overridden'],
      )!,
      co2IsOverridden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}co2_is_overridden'],
      )!,
      co2MethodologyVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}co2_methodology_version'],
      )!,
      localeTag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale_tag'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
    );
  }

  @override
  $UserProfileTableTable createAlias(String alias) {
    return $UserProfileTableTable(attachedDatabase, alias);
  }
}

class UserProfileRow extends DataClass implements Insertable<UserProfileRow> {
  /// Primary key: UUID v7 stored as TEXT (time-ordered, globally unique).
  final String id;

  /// HLC wall-clock component: milliseconds since Unix epoch.
  /// Stored as int64 (BigInt in Dart) to fit 64-bit epoch millis.
  final BigInt hlcMillis;

  /// HLC logical counter: tie-breaking for same-millisecond writes.
  final int hlcCounter;

  /// HLC node identifier: stable device installation UUID (UUID v4).
  /// Generated once on first app install and persisted in secure storage.
  final String hlcNodeId;

  /// Dirty flag: true = row has local changes not yet synced to backend.
  /// Defaults to true on insert — every new row starts dirty until
  /// sync confirms receipt.
  final bool dirty;

  /// Tombstone: null = row is live; non-null = row was soft-deleted.
  /// Soft-deleted rows are retained for 90 days to allow sync to
  /// propagate the deletion.
  final DateTime? deletedAt;

  /// Age in years. Required for Mifflin-St Jéor TDEE calculation.
  final int? age;

  /// Biological sex for BMR calculation.
  /// Values: 'male', 'female', 'other'.
  /// 'other' uses the average of male and female BMR variants.
  final String? gender;

  /// Height in centimetres. Always stored in cm; imperial conversion
  /// happens in the app layer.
  final double? heightCm;

  /// Weight in kilograms. Always stored in kg; imperial conversion
  /// happens in the app layer.
  final double? weightKg;

  /// Activity level for TDEE multiplier.
  /// Values: 'low', 'medium', 'high'.
  final String? activityLevel;

  /// Dietary preference.
  /// Values: 'no_preference', 'vegetarian', 'vegan',
  /// 'flexitarian', 'low_meat', 'other'.
  final String? dietaryPreference;

  /// User's selected goal.
  /// Values: 'reduce_co2', 'lose_weight', 'maintain_weight',
  /// 'gain_muscle', 'improve_health', 'balanced_lifestyle',
  /// 'learn_and_explore'.
  final String? goal;

  /// Unit system preference. Values: 'metric', 'imperial'.
  /// Default 'metric' — locale detection on first profile save
  /// sets this per D-09.
  final String units;

  /// Daily energy target in kcal. Null until all Mifflin inputs
  /// are complete.
  final double? kcalTarget;

  /// Daily protein target in grams. Null until TDEE is calculated.
  final double? proteinGTarget;

  /// Daily carbohydrate target in grams. Null until TDEE is calculated.
  final double? carbsGTarget;

  /// Daily fat target in grams. Null until TDEE is calculated.
  final double? fatGTarget;

  /// Daily CO₂ target in grams. Stored but NOT shown in UI until
  /// Phase 3. The CO₂ factor table doesn't exist until Phase 3;
  /// this column is pre-provisioned per CO2-04 so no migration
  /// is needed later.
  final double? co2GTarget;

  /// True when the user has manually overridden the kcal target.
  final bool kcalIsOverridden;

  /// True when the user has manually overridden the protein target.
  final bool proteinIsOverridden;

  /// True when the user has manually overridden the carbs target.
  final bool carbsIsOverridden;

  /// True when the user has manually overridden the fat target.
  final bool fatIsOverridden;

  /// True when the user has manually overridden the CO₂ target.
  final bool co2IsOverridden;

  /// Version of the CO₂ calculation methodology used for this
  /// profile's targets. Defaults to '1.0' — the first methodology
  /// version in the app. This column is present from day 1 so
  /// methodology updates in Phase 7+ can trigger recalculation
  /// flows without a migration.
  final String co2MethodologyVersion;

  /// BCP 47 locale tag at the time of first profile save
  /// (e.g. 'de-DE', 'en-US'). Captured once via
  /// Localizations.localeOf(context) on the first save.
  final String? localeTag;

  /// UTC timestamp of initial profile creation.
  final DateTime createdAt;

  /// UTC timestamp of most recent profile update.
  /// Null until first update.
  final DateTime? updatedAt;
  const UserProfileRow({
    required this.id,
    required this.hlcMillis,
    required this.hlcCounter,
    required this.hlcNodeId,
    required this.dirty,
    this.deletedAt,
    this.age,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.activityLevel,
    this.dietaryPreference,
    this.goal,
    required this.units,
    this.kcalTarget,
    this.proteinGTarget,
    this.carbsGTarget,
    this.fatGTarget,
    this.co2GTarget,
    required this.kcalIsOverridden,
    required this.proteinIsOverridden,
    required this.carbsIsOverridden,
    required this.fatIsOverridden,
    required this.co2IsOverridden,
    required this.co2MethodologyVersion,
    this.localeTag,
    required this.createdAt,
    this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['hlc_millis'] = Variable<BigInt>(hlcMillis);
    map['hlc_counter'] = Variable<int>(hlcCounter);
    map['hlc_node_id'] = Variable<String>(hlcNodeId);
    map['dirty'] = Variable<bool>(dirty);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || age != null) {
      map['age'] = Variable<int>(age);
    }
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(gender);
    }
    if (!nullToAbsent || heightCm != null) {
      map['height_cm'] = Variable<double>(heightCm);
    }
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || activityLevel != null) {
      map['activity_level'] = Variable<String>(activityLevel);
    }
    if (!nullToAbsent || dietaryPreference != null) {
      map['dietary_preference'] = Variable<String>(dietaryPreference);
    }
    if (!nullToAbsent || goal != null) {
      map['goal'] = Variable<String>(goal);
    }
    map['units'] = Variable<String>(units);
    if (!nullToAbsent || kcalTarget != null) {
      map['kcal_target'] = Variable<double>(kcalTarget);
    }
    if (!nullToAbsent || proteinGTarget != null) {
      map['protein_g_target'] = Variable<double>(proteinGTarget);
    }
    if (!nullToAbsent || carbsGTarget != null) {
      map['carbs_g_target'] = Variable<double>(carbsGTarget);
    }
    if (!nullToAbsent || fatGTarget != null) {
      map['fat_g_target'] = Variable<double>(fatGTarget);
    }
    if (!nullToAbsent || co2GTarget != null) {
      map['co2_g_target'] = Variable<double>(co2GTarget);
    }
    map['kcal_is_overridden'] = Variable<bool>(kcalIsOverridden);
    map['protein_is_overridden'] = Variable<bool>(proteinIsOverridden);
    map['carbs_is_overridden'] = Variable<bool>(carbsIsOverridden);
    map['fat_is_overridden'] = Variable<bool>(fatIsOverridden);
    map['co2_is_overridden'] = Variable<bool>(co2IsOverridden);
    map['co2_methodology_version'] = Variable<String>(co2MethodologyVersion);
    if (!nullToAbsent || localeTag != null) {
      map['locale_tag'] = Variable<String>(localeTag);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  UserProfileTableCompanion toCompanion(bool nullToAbsent) {
    return UserProfileTableCompanion(
      id: Value(id),
      hlcMillis: Value(hlcMillis),
      hlcCounter: Value(hlcCounter),
      hlcNodeId: Value(hlcNodeId),
      dirty: Value(dirty),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      age: age == null && nullToAbsent ? const Value.absent() : Value(age),
      gender: gender == null && nullToAbsent
          ? const Value.absent()
          : Value(gender),
      heightCm: heightCm == null && nullToAbsent
          ? const Value.absent()
          : Value(heightCm),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      activityLevel: activityLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(activityLevel),
      dietaryPreference: dietaryPreference == null && nullToAbsent
          ? const Value.absent()
          : Value(dietaryPreference),
      goal: goal == null && nullToAbsent ? const Value.absent() : Value(goal),
      units: Value(units),
      kcalTarget: kcalTarget == null && nullToAbsent
          ? const Value.absent()
          : Value(kcalTarget),
      proteinGTarget: proteinGTarget == null && nullToAbsent
          ? const Value.absent()
          : Value(proteinGTarget),
      carbsGTarget: carbsGTarget == null && nullToAbsent
          ? const Value.absent()
          : Value(carbsGTarget),
      fatGTarget: fatGTarget == null && nullToAbsent
          ? const Value.absent()
          : Value(fatGTarget),
      co2GTarget: co2GTarget == null && nullToAbsent
          ? const Value.absent()
          : Value(co2GTarget),
      kcalIsOverridden: Value(kcalIsOverridden),
      proteinIsOverridden: Value(proteinIsOverridden),
      carbsIsOverridden: Value(carbsIsOverridden),
      fatIsOverridden: Value(fatIsOverridden),
      co2IsOverridden: Value(co2IsOverridden),
      co2MethodologyVersion: Value(co2MethodologyVersion),
      localeTag: localeTag == null && nullToAbsent
          ? const Value.absent()
          : Value(localeTag),
      createdAt: Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory UserProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfileRow(
      id: serializer.fromJson<String>(json['id']),
      hlcMillis: serializer.fromJson<BigInt>(json['hlcMillis']),
      hlcCounter: serializer.fromJson<int>(json['hlcCounter']),
      hlcNodeId: serializer.fromJson<String>(json['hlcNodeId']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      age: serializer.fromJson<int?>(json['age']),
      gender: serializer.fromJson<String?>(json['gender']),
      heightCm: serializer.fromJson<double?>(json['heightCm']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      activityLevel: serializer.fromJson<String?>(json['activityLevel']),
      dietaryPreference: serializer.fromJson<String?>(
        json['dietaryPreference'],
      ),
      goal: serializer.fromJson<String?>(json['goal']),
      units: serializer.fromJson<String>(json['units']),
      kcalTarget: serializer.fromJson<double?>(json['kcalTarget']),
      proteinGTarget: serializer.fromJson<double?>(json['proteinGTarget']),
      carbsGTarget: serializer.fromJson<double?>(json['carbsGTarget']),
      fatGTarget: serializer.fromJson<double?>(json['fatGTarget']),
      co2GTarget: serializer.fromJson<double?>(json['co2GTarget']),
      kcalIsOverridden: serializer.fromJson<bool>(json['kcalIsOverridden']),
      proteinIsOverridden: serializer.fromJson<bool>(
        json['proteinIsOverridden'],
      ),
      carbsIsOverridden: serializer.fromJson<bool>(json['carbsIsOverridden']),
      fatIsOverridden: serializer.fromJson<bool>(json['fatIsOverridden']),
      co2IsOverridden: serializer.fromJson<bool>(json['co2IsOverridden']),
      co2MethodologyVersion: serializer.fromJson<String>(
        json['co2MethodologyVersion'],
      ),
      localeTag: serializer.fromJson<String?>(json['localeTag']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'hlcMillis': serializer.toJson<BigInt>(hlcMillis),
      'hlcCounter': serializer.toJson<int>(hlcCounter),
      'hlcNodeId': serializer.toJson<String>(hlcNodeId),
      'dirty': serializer.toJson<bool>(dirty),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'age': serializer.toJson<int?>(age),
      'gender': serializer.toJson<String?>(gender),
      'heightCm': serializer.toJson<double?>(heightCm),
      'weightKg': serializer.toJson<double?>(weightKg),
      'activityLevel': serializer.toJson<String?>(activityLevel),
      'dietaryPreference': serializer.toJson<String?>(dietaryPreference),
      'goal': serializer.toJson<String?>(goal),
      'units': serializer.toJson<String>(units),
      'kcalTarget': serializer.toJson<double?>(kcalTarget),
      'proteinGTarget': serializer.toJson<double?>(proteinGTarget),
      'carbsGTarget': serializer.toJson<double?>(carbsGTarget),
      'fatGTarget': serializer.toJson<double?>(fatGTarget),
      'co2GTarget': serializer.toJson<double?>(co2GTarget),
      'kcalIsOverridden': serializer.toJson<bool>(kcalIsOverridden),
      'proteinIsOverridden': serializer.toJson<bool>(proteinIsOverridden),
      'carbsIsOverridden': serializer.toJson<bool>(carbsIsOverridden),
      'fatIsOverridden': serializer.toJson<bool>(fatIsOverridden),
      'co2IsOverridden': serializer.toJson<bool>(co2IsOverridden),
      'co2MethodologyVersion': serializer.toJson<String>(co2MethodologyVersion),
      'localeTag': serializer.toJson<String?>(localeTag),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  UserProfileRow copyWith({
    String? id,
    BigInt? hlcMillis,
    int? hlcCounter,
    String? hlcNodeId,
    bool? dirty,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<int?> age = const Value.absent(),
    Value<String?> gender = const Value.absent(),
    Value<double?> heightCm = const Value.absent(),
    Value<double?> weightKg = const Value.absent(),
    Value<String?> activityLevel = const Value.absent(),
    Value<String?> dietaryPreference = const Value.absent(),
    Value<String?> goal = const Value.absent(),
    String? units,
    Value<double?> kcalTarget = const Value.absent(),
    Value<double?> proteinGTarget = const Value.absent(),
    Value<double?> carbsGTarget = const Value.absent(),
    Value<double?> fatGTarget = const Value.absent(),
    Value<double?> co2GTarget = const Value.absent(),
    bool? kcalIsOverridden,
    bool? proteinIsOverridden,
    bool? carbsIsOverridden,
    bool? fatIsOverridden,
    bool? co2IsOverridden,
    String? co2MethodologyVersion,
    Value<String?> localeTag = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> updatedAt = const Value.absent(),
  }) => UserProfileRow(
    id: id ?? this.id,
    hlcMillis: hlcMillis ?? this.hlcMillis,
    hlcCounter: hlcCounter ?? this.hlcCounter,
    hlcNodeId: hlcNodeId ?? this.hlcNodeId,
    dirty: dirty ?? this.dirty,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    age: age.present ? age.value : this.age,
    gender: gender.present ? gender.value : this.gender,
    heightCm: heightCm.present ? heightCm.value : this.heightCm,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    activityLevel: activityLevel.present
        ? activityLevel.value
        : this.activityLevel,
    dietaryPreference: dietaryPreference.present
        ? dietaryPreference.value
        : this.dietaryPreference,
    goal: goal.present ? goal.value : this.goal,
    units: units ?? this.units,
    kcalTarget: kcalTarget.present ? kcalTarget.value : this.kcalTarget,
    proteinGTarget: proteinGTarget.present
        ? proteinGTarget.value
        : this.proteinGTarget,
    carbsGTarget: carbsGTarget.present ? carbsGTarget.value : this.carbsGTarget,
    fatGTarget: fatGTarget.present ? fatGTarget.value : this.fatGTarget,
    co2GTarget: co2GTarget.present ? co2GTarget.value : this.co2GTarget,
    kcalIsOverridden: kcalIsOverridden ?? this.kcalIsOverridden,
    proteinIsOverridden: proteinIsOverridden ?? this.proteinIsOverridden,
    carbsIsOverridden: carbsIsOverridden ?? this.carbsIsOverridden,
    fatIsOverridden: fatIsOverridden ?? this.fatIsOverridden,
    co2IsOverridden: co2IsOverridden ?? this.co2IsOverridden,
    co2MethodologyVersion: co2MethodologyVersion ?? this.co2MethodologyVersion,
    localeTag: localeTag.present ? localeTag.value : this.localeTag,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
  );
  UserProfileRow copyWithCompanion(UserProfileTableCompanion data) {
    return UserProfileRow(
      id: data.id.present ? data.id.value : this.id,
      hlcMillis: data.hlcMillis.present ? data.hlcMillis.value : this.hlcMillis,
      hlcCounter: data.hlcCounter.present
          ? data.hlcCounter.value
          : this.hlcCounter,
      hlcNodeId: data.hlcNodeId.present ? data.hlcNodeId.value : this.hlcNodeId,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      age: data.age.present ? data.age.value : this.age,
      gender: data.gender.present ? data.gender.value : this.gender,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      activityLevel: data.activityLevel.present
          ? data.activityLevel.value
          : this.activityLevel,
      dietaryPreference: data.dietaryPreference.present
          ? data.dietaryPreference.value
          : this.dietaryPreference,
      goal: data.goal.present ? data.goal.value : this.goal,
      units: data.units.present ? data.units.value : this.units,
      kcalTarget: data.kcalTarget.present
          ? data.kcalTarget.value
          : this.kcalTarget,
      proteinGTarget: data.proteinGTarget.present
          ? data.proteinGTarget.value
          : this.proteinGTarget,
      carbsGTarget: data.carbsGTarget.present
          ? data.carbsGTarget.value
          : this.carbsGTarget,
      fatGTarget: data.fatGTarget.present
          ? data.fatGTarget.value
          : this.fatGTarget,
      co2GTarget: data.co2GTarget.present
          ? data.co2GTarget.value
          : this.co2GTarget,
      kcalIsOverridden: data.kcalIsOverridden.present
          ? data.kcalIsOverridden.value
          : this.kcalIsOverridden,
      proteinIsOverridden: data.proteinIsOverridden.present
          ? data.proteinIsOverridden.value
          : this.proteinIsOverridden,
      carbsIsOverridden: data.carbsIsOverridden.present
          ? data.carbsIsOverridden.value
          : this.carbsIsOverridden,
      fatIsOverridden: data.fatIsOverridden.present
          ? data.fatIsOverridden.value
          : this.fatIsOverridden,
      co2IsOverridden: data.co2IsOverridden.present
          ? data.co2IsOverridden.value
          : this.co2IsOverridden,
      co2MethodologyVersion: data.co2MethodologyVersion.present
          ? data.co2MethodologyVersion.value
          : this.co2MethodologyVersion,
      localeTag: data.localeTag.present ? data.localeTag.value : this.localeTag,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileRow(')
          ..write('id: $id, ')
          ..write('hlcMillis: $hlcMillis, ')
          ..write('hlcCounter: $hlcCounter, ')
          ..write('hlcNodeId: $hlcNodeId, ')
          ..write('dirty: $dirty, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('age: $age, ')
          ..write('gender: $gender, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('activityLevel: $activityLevel, ')
          ..write('dietaryPreference: $dietaryPreference, ')
          ..write('goal: $goal, ')
          ..write('units: $units, ')
          ..write('kcalTarget: $kcalTarget, ')
          ..write('proteinGTarget: $proteinGTarget, ')
          ..write('carbsGTarget: $carbsGTarget, ')
          ..write('fatGTarget: $fatGTarget, ')
          ..write('co2GTarget: $co2GTarget, ')
          ..write('kcalIsOverridden: $kcalIsOverridden, ')
          ..write('proteinIsOverridden: $proteinIsOverridden, ')
          ..write('carbsIsOverridden: $carbsIsOverridden, ')
          ..write('fatIsOverridden: $fatIsOverridden, ')
          ..write('co2IsOverridden: $co2IsOverridden, ')
          ..write('co2MethodologyVersion: $co2MethodologyVersion, ')
          ..write('localeTag: $localeTag, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    hlcMillis,
    hlcCounter,
    hlcNodeId,
    dirty,
    deletedAt,
    age,
    gender,
    heightCm,
    weightKg,
    activityLevel,
    dietaryPreference,
    goal,
    units,
    kcalTarget,
    proteinGTarget,
    carbsGTarget,
    fatGTarget,
    co2GTarget,
    kcalIsOverridden,
    proteinIsOverridden,
    carbsIsOverridden,
    fatIsOverridden,
    co2IsOverridden,
    co2MethodologyVersion,
    localeTag,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfileRow &&
          other.id == this.id &&
          other.hlcMillis == this.hlcMillis &&
          other.hlcCounter == this.hlcCounter &&
          other.hlcNodeId == this.hlcNodeId &&
          other.dirty == this.dirty &&
          other.deletedAt == this.deletedAt &&
          other.age == this.age &&
          other.gender == this.gender &&
          other.heightCm == this.heightCm &&
          other.weightKg == this.weightKg &&
          other.activityLevel == this.activityLevel &&
          other.dietaryPreference == this.dietaryPreference &&
          other.goal == this.goal &&
          other.units == this.units &&
          other.kcalTarget == this.kcalTarget &&
          other.proteinGTarget == this.proteinGTarget &&
          other.carbsGTarget == this.carbsGTarget &&
          other.fatGTarget == this.fatGTarget &&
          other.co2GTarget == this.co2GTarget &&
          other.kcalIsOverridden == this.kcalIsOverridden &&
          other.proteinIsOverridden == this.proteinIsOverridden &&
          other.carbsIsOverridden == this.carbsIsOverridden &&
          other.fatIsOverridden == this.fatIsOverridden &&
          other.co2IsOverridden == this.co2IsOverridden &&
          other.co2MethodologyVersion == this.co2MethodologyVersion &&
          other.localeTag == this.localeTag &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UserProfileTableCompanion extends UpdateCompanion<UserProfileRow> {
  final Value<String> id;
  final Value<BigInt> hlcMillis;
  final Value<int> hlcCounter;
  final Value<String> hlcNodeId;
  final Value<bool> dirty;
  final Value<DateTime?> deletedAt;
  final Value<int?> age;
  final Value<String?> gender;
  final Value<double?> heightCm;
  final Value<double?> weightKg;
  final Value<String?> activityLevel;
  final Value<String?> dietaryPreference;
  final Value<String?> goal;
  final Value<String> units;
  final Value<double?> kcalTarget;
  final Value<double?> proteinGTarget;
  final Value<double?> carbsGTarget;
  final Value<double?> fatGTarget;
  final Value<double?> co2GTarget;
  final Value<bool> kcalIsOverridden;
  final Value<bool> proteinIsOverridden;
  final Value<bool> carbsIsOverridden;
  final Value<bool> fatIsOverridden;
  final Value<bool> co2IsOverridden;
  final Value<String> co2MethodologyVersion;
  final Value<String?> localeTag;
  final Value<DateTime> createdAt;
  final Value<DateTime?> updatedAt;
  final Value<int> rowid;
  const UserProfileTableCompanion({
    this.id = const Value.absent(),
    this.hlcMillis = const Value.absent(),
    this.hlcCounter = const Value.absent(),
    this.hlcNodeId = const Value.absent(),
    this.dirty = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.age = const Value.absent(),
    this.gender = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.activityLevel = const Value.absent(),
    this.dietaryPreference = const Value.absent(),
    this.goal = const Value.absent(),
    this.units = const Value.absent(),
    this.kcalTarget = const Value.absent(),
    this.proteinGTarget = const Value.absent(),
    this.carbsGTarget = const Value.absent(),
    this.fatGTarget = const Value.absent(),
    this.co2GTarget = const Value.absent(),
    this.kcalIsOverridden = const Value.absent(),
    this.proteinIsOverridden = const Value.absent(),
    this.carbsIsOverridden = const Value.absent(),
    this.fatIsOverridden = const Value.absent(),
    this.co2IsOverridden = const Value.absent(),
    this.co2MethodologyVersion = const Value.absent(),
    this.localeTag = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProfileTableCompanion.insert({
    required String id,
    required BigInt hlcMillis,
    required int hlcCounter,
    required String hlcNodeId,
    this.dirty = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.age = const Value.absent(),
    this.gender = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.activityLevel = const Value.absent(),
    this.dietaryPreference = const Value.absent(),
    this.goal = const Value.absent(),
    this.units = const Value.absent(),
    this.kcalTarget = const Value.absent(),
    this.proteinGTarget = const Value.absent(),
    this.carbsGTarget = const Value.absent(),
    this.fatGTarget = const Value.absent(),
    this.co2GTarget = const Value.absent(),
    this.kcalIsOverridden = const Value.absent(),
    this.proteinIsOverridden = const Value.absent(),
    this.carbsIsOverridden = const Value.absent(),
    this.fatIsOverridden = const Value.absent(),
    this.co2IsOverridden = const Value.absent(),
    this.co2MethodologyVersion = const Value.absent(),
    this.localeTag = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       hlcMillis = Value(hlcMillis),
       hlcCounter = Value(hlcCounter),
       hlcNodeId = Value(hlcNodeId);
  static Insertable<UserProfileRow> custom({
    Expression<String>? id,
    Expression<BigInt>? hlcMillis,
    Expression<int>? hlcCounter,
    Expression<String>? hlcNodeId,
    Expression<bool>? dirty,
    Expression<DateTime>? deletedAt,
    Expression<int>? age,
    Expression<String>? gender,
    Expression<double>? heightCm,
    Expression<double>? weightKg,
    Expression<String>? activityLevel,
    Expression<String>? dietaryPreference,
    Expression<String>? goal,
    Expression<String>? units,
    Expression<double>? kcalTarget,
    Expression<double>? proteinGTarget,
    Expression<double>? carbsGTarget,
    Expression<double>? fatGTarget,
    Expression<double>? co2GTarget,
    Expression<bool>? kcalIsOverridden,
    Expression<bool>? proteinIsOverridden,
    Expression<bool>? carbsIsOverridden,
    Expression<bool>? fatIsOverridden,
    Expression<bool>? co2IsOverridden,
    Expression<String>? co2MethodologyVersion,
    Expression<String>? localeTag,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hlcMillis != null) 'hlc_millis': hlcMillis,
      if (hlcCounter != null) 'hlc_counter': hlcCounter,
      if (hlcNodeId != null) 'hlc_node_id': hlcNodeId,
      if (dirty != null) 'dirty': dirty,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
      if (activityLevel != null) 'activity_level': activityLevel,
      if (dietaryPreference != null) 'dietary_preference': dietaryPreference,
      if (goal != null) 'goal': goal,
      if (units != null) 'units': units,
      if (kcalTarget != null) 'kcal_target': kcalTarget,
      if (proteinGTarget != null) 'protein_g_target': proteinGTarget,
      if (carbsGTarget != null) 'carbs_g_target': carbsGTarget,
      if (fatGTarget != null) 'fat_g_target': fatGTarget,
      if (co2GTarget != null) 'co2_g_target': co2GTarget,
      if (kcalIsOverridden != null) 'kcal_is_overridden': kcalIsOverridden,
      if (proteinIsOverridden != null)
        'protein_is_overridden': proteinIsOverridden,
      if (carbsIsOverridden != null) 'carbs_is_overridden': carbsIsOverridden,
      if (fatIsOverridden != null) 'fat_is_overridden': fatIsOverridden,
      if (co2IsOverridden != null) 'co2_is_overridden': co2IsOverridden,
      if (co2MethodologyVersion != null)
        'co2_methodology_version': co2MethodologyVersion,
      if (localeTag != null) 'locale_tag': localeTag,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProfileTableCompanion copyWith({
    Value<String>? id,
    Value<BigInt>? hlcMillis,
    Value<int>? hlcCounter,
    Value<String>? hlcNodeId,
    Value<bool>? dirty,
    Value<DateTime?>? deletedAt,
    Value<int?>? age,
    Value<String?>? gender,
    Value<double?>? heightCm,
    Value<double?>? weightKg,
    Value<String?>? activityLevel,
    Value<String?>? dietaryPreference,
    Value<String?>? goal,
    Value<String>? units,
    Value<double?>? kcalTarget,
    Value<double?>? proteinGTarget,
    Value<double?>? carbsGTarget,
    Value<double?>? fatGTarget,
    Value<double?>? co2GTarget,
    Value<bool>? kcalIsOverridden,
    Value<bool>? proteinIsOverridden,
    Value<bool>? carbsIsOverridden,
    Value<bool>? fatIsOverridden,
    Value<bool>? co2IsOverridden,
    Value<String>? co2MethodologyVersion,
    Value<String?>? localeTag,
    Value<DateTime>? createdAt,
    Value<DateTime?>? updatedAt,
    Value<int>? rowid,
  }) {
    return UserProfileTableCompanion(
      id: id ?? this.id,
      hlcMillis: hlcMillis ?? this.hlcMillis,
      hlcCounter: hlcCounter ?? this.hlcCounter,
      hlcNodeId: hlcNodeId ?? this.hlcNodeId,
      dirty: dirty ?? this.dirty,
      deletedAt: deletedAt ?? this.deletedAt,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      goal: goal ?? this.goal,
      units: units ?? this.units,
      kcalTarget: kcalTarget ?? this.kcalTarget,
      proteinGTarget: proteinGTarget ?? this.proteinGTarget,
      carbsGTarget: carbsGTarget ?? this.carbsGTarget,
      fatGTarget: fatGTarget ?? this.fatGTarget,
      co2GTarget: co2GTarget ?? this.co2GTarget,
      kcalIsOverridden: kcalIsOverridden ?? this.kcalIsOverridden,
      proteinIsOverridden: proteinIsOverridden ?? this.proteinIsOverridden,
      carbsIsOverridden: carbsIsOverridden ?? this.carbsIsOverridden,
      fatIsOverridden: fatIsOverridden ?? this.fatIsOverridden,
      co2IsOverridden: co2IsOverridden ?? this.co2IsOverridden,
      co2MethodologyVersion:
          co2MethodologyVersion ?? this.co2MethodologyVersion,
      localeTag: localeTag ?? this.localeTag,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (hlcMillis.present) {
      map['hlc_millis'] = Variable<BigInt>(hlcMillis.value);
    }
    if (hlcCounter.present) {
      map['hlc_counter'] = Variable<int>(hlcCounter.value);
    }
    if (hlcNodeId.present) {
      map['hlc_node_id'] = Variable<String>(hlcNodeId.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (activityLevel.present) {
      map['activity_level'] = Variable<String>(activityLevel.value);
    }
    if (dietaryPreference.present) {
      map['dietary_preference'] = Variable<String>(dietaryPreference.value);
    }
    if (goal.present) {
      map['goal'] = Variable<String>(goal.value);
    }
    if (units.present) {
      map['units'] = Variable<String>(units.value);
    }
    if (kcalTarget.present) {
      map['kcal_target'] = Variable<double>(kcalTarget.value);
    }
    if (proteinGTarget.present) {
      map['protein_g_target'] = Variable<double>(proteinGTarget.value);
    }
    if (carbsGTarget.present) {
      map['carbs_g_target'] = Variable<double>(carbsGTarget.value);
    }
    if (fatGTarget.present) {
      map['fat_g_target'] = Variable<double>(fatGTarget.value);
    }
    if (co2GTarget.present) {
      map['co2_g_target'] = Variable<double>(co2GTarget.value);
    }
    if (kcalIsOverridden.present) {
      map['kcal_is_overridden'] = Variable<bool>(kcalIsOverridden.value);
    }
    if (proteinIsOverridden.present) {
      map['protein_is_overridden'] = Variable<bool>(proteinIsOverridden.value);
    }
    if (carbsIsOverridden.present) {
      map['carbs_is_overridden'] = Variable<bool>(carbsIsOverridden.value);
    }
    if (fatIsOverridden.present) {
      map['fat_is_overridden'] = Variable<bool>(fatIsOverridden.value);
    }
    if (co2IsOverridden.present) {
      map['co2_is_overridden'] = Variable<bool>(co2IsOverridden.value);
    }
    if (co2MethodologyVersion.present) {
      map['co2_methodology_version'] = Variable<String>(
        co2MethodologyVersion.value,
      );
    }
    if (localeTag.present) {
      map['locale_tag'] = Variable<String>(localeTag.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileTableCompanion(')
          ..write('id: $id, ')
          ..write('hlcMillis: $hlcMillis, ')
          ..write('hlcCounter: $hlcCounter, ')
          ..write('hlcNodeId: $hlcNodeId, ')
          ..write('dirty: $dirty, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('age: $age, ')
          ..write('gender: $gender, ')
          ..write('heightCm: $heightCm, ')
          ..write('weightKg: $weightKg, ')
          ..write('activityLevel: $activityLevel, ')
          ..write('dietaryPreference: $dietaryPreference, ')
          ..write('goal: $goal, ')
          ..write('units: $units, ')
          ..write('kcalTarget: $kcalTarget, ')
          ..write('proteinGTarget: $proteinGTarget, ')
          ..write('carbsGTarget: $carbsGTarget, ')
          ..write('fatGTarget: $fatGTarget, ')
          ..write('co2GTarget: $co2GTarget, ')
          ..write('kcalIsOverridden: $kcalIsOverridden, ')
          ..write('proteinIsOverridden: $proteinIsOverridden, ')
          ..write('carbsIsOverridden: $carbsIsOverridden, ')
          ..write('fatIsOverridden: $fatIsOverridden, ')
          ..write('co2IsOverridden: $co2IsOverridden, ')
          ..write('co2MethodologyVersion: $co2MethodologyVersion, ')
          ..write('localeTag: $localeTag, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConsentRecordsTableTable extends ConsentRecordsTable
    with TableInfo<$ConsentRecordsTableTable, ConsentRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConsentRecordsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _appVersionMeta = const VerificationMeta(
    'appVersion',
  );
  @override
  late final GeneratedColumn<String> appVersion = GeneratedColumn<String>(
    'app_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _policyVersionMeta = const VerificationMeta(
    'policyVersion',
  );
  @override
  late final GeneratedColumn<String> policyVersion = GeneratedColumn<String>(
    'policy_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _consentsGivenMeta = const VerificationMeta(
    'consentsGiven',
  );
  @override
  late final GeneratedColumn<String> consentsGiven = GeneratedColumn<String>(
    'consents_given',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    appVersion,
    policyVersion,
    consentsGiven,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'consent_records_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConsentRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('app_version')) {
      context.handle(
        _appVersionMeta,
        appVersion.isAcceptableOrUnknown(data['app_version']!, _appVersionMeta),
      );
    } else if (isInserting) {
      context.missing(_appVersionMeta);
    }
    if (data.containsKey('policy_version')) {
      context.handle(
        _policyVersionMeta,
        policyVersion.isAcceptableOrUnknown(
          data['policy_version']!,
          _policyVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_policyVersionMeta);
    }
    if (data.containsKey('consents_given')) {
      context.handle(
        _consentsGivenMeta,
        consentsGiven.isAcceptableOrUnknown(
          data['consents_given']!,
          _consentsGivenMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_consentsGivenMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConsentRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConsentRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      appVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_version'],
      )!,
      policyVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}policy_version'],
      )!,
      consentsGiven: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}consents_given'],
      )!,
    );
  }

  @override
  $ConsentRecordsTableTable createAlias(String alias) {
    return $ConsentRecordsTableTable(attachedDatabase, alias);
  }
}

class ConsentRecord extends DataClass implements Insertable<ConsentRecord> {
  /// UUID v7 primary key — time-ordered for chronological audit access.
  final String id;

  /// UTC timestamp of when the consent event was recorded on device.
  final DateTime createdAt;

  /// App build version at the time of consent (e.g. '0.1.0+1').
  final String appVersion;

  /// Policy document version accepted at time of consent
  /// (e.g. '2026-07-16').
  final String policyVersion;

  /// JSON string array of checkbox IDs the user accepted.
  ///
  /// Required items: 'terms', 'privacy', 'not_medical_advice',
  /// 'user_responsibility'.
  /// Optional item: 'age_16_plus' (included only when the user checked
  /// the 5th self-declaration checkbox).
  final String consentsGiven;
  const ConsentRecord({
    required this.id,
    required this.createdAt,
    required this.appVersion,
    required this.policyVersion,
    required this.consentsGiven,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['app_version'] = Variable<String>(appVersion);
    map['policy_version'] = Variable<String>(policyVersion);
    map['consents_given'] = Variable<String>(consentsGiven);
    return map;
  }

  ConsentRecordsTableCompanion toCompanion(bool nullToAbsent) {
    return ConsentRecordsTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      appVersion: Value(appVersion),
      policyVersion: Value(policyVersion),
      consentsGiven: Value(consentsGiven),
    );
  }

  factory ConsentRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConsentRecord(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      appVersion: serializer.fromJson<String>(json['appVersion']),
      policyVersion: serializer.fromJson<String>(json['policyVersion']),
      consentsGiven: serializer.fromJson<String>(json['consentsGiven']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'appVersion': serializer.toJson<String>(appVersion),
      'policyVersion': serializer.toJson<String>(policyVersion),
      'consentsGiven': serializer.toJson<String>(consentsGiven),
    };
  }

  ConsentRecord copyWith({
    String? id,
    DateTime? createdAt,
    String? appVersion,
    String? policyVersion,
    String? consentsGiven,
  }) => ConsentRecord(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    appVersion: appVersion ?? this.appVersion,
    policyVersion: policyVersion ?? this.policyVersion,
    consentsGiven: consentsGiven ?? this.consentsGiven,
  );
  ConsentRecord copyWithCompanion(ConsentRecordsTableCompanion data) {
    return ConsentRecord(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      appVersion: data.appVersion.present
          ? data.appVersion.value
          : this.appVersion,
      policyVersion: data.policyVersion.present
          ? data.policyVersion.value
          : this.policyVersion,
      consentsGiven: data.consentsGiven.present
          ? data.consentsGiven.value
          : this.consentsGiven,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConsentRecord(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('appVersion: $appVersion, ')
          ..write('policyVersion: $policyVersion, ')
          ..write('consentsGiven: $consentsGiven')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, appVersion, policyVersion, consentsGiven);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConsentRecord &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.appVersion == this.appVersion &&
          other.policyVersion == this.policyVersion &&
          other.consentsGiven == this.consentsGiven);
}

class ConsentRecordsTableCompanion extends UpdateCompanion<ConsentRecord> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<String> appVersion;
  final Value<String> policyVersion;
  final Value<String> consentsGiven;
  final Value<int> rowid;
  const ConsentRecordsTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.appVersion = const Value.absent(),
    this.policyVersion = const Value.absent(),
    this.consentsGiven = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConsentRecordsTableCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    required String appVersion,
    required String policyVersion,
    required String consentsGiven,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       appVersion = Value(appVersion),
       policyVersion = Value(policyVersion),
       consentsGiven = Value(consentsGiven);
  static Insertable<ConsentRecord> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<String>? appVersion,
    Expression<String>? policyVersion,
    Expression<String>? consentsGiven,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (appVersion != null) 'app_version': appVersion,
      if (policyVersion != null) 'policy_version': policyVersion,
      if (consentsGiven != null) 'consents_given': consentsGiven,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConsentRecordsTableCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<String>? appVersion,
    Value<String>? policyVersion,
    Value<String>? consentsGiven,
    Value<int>? rowid,
  }) {
    return ConsentRecordsTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      appVersion: appVersion ?? this.appVersion,
      policyVersion: policyVersion ?? this.policyVersion,
      consentsGiven: consentsGiven ?? this.consentsGiven,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (appVersion.present) {
      map['app_version'] = Variable<String>(appVersion.value);
    }
    if (policyVersion.present) {
      map['policy_version'] = Variable<String>(policyVersion.value);
    }
    if (consentsGiven.present) {
      map['consents_given'] = Variable<String>(consentsGiven.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConsentRecordsTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('appVersion: $appVersion, ')
          ..write('policyVersion: $policyVersion, ')
          ..write('consentsGiven: $consentsGiven, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserProfileTableTable userProfileTable = $UserProfileTableTable(
    this,
  );
  late final $ConsentRecordsTableTable consentRecordsTable =
      $ConsentRecordsTableTable(this);
  late final UserProfileDao userProfileDao = UserProfileDao(
    this as AppDatabase,
  );
  late final ConsentRecordsDao consentRecordsDao = ConsentRecordsDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userProfileTable,
    consentRecordsTable,
  ];
}

typedef $$UserProfileTableTableCreateCompanionBuilder =
    UserProfileTableCompanion Function({
      required String id,
      required BigInt hlcMillis,
      required int hlcCounter,
      required String hlcNodeId,
      Value<bool> dirty,
      Value<DateTime?> deletedAt,
      Value<int?> age,
      Value<String?> gender,
      Value<double?> heightCm,
      Value<double?> weightKg,
      Value<String?> activityLevel,
      Value<String?> dietaryPreference,
      Value<String?> goal,
      Value<String> units,
      Value<double?> kcalTarget,
      Value<double?> proteinGTarget,
      Value<double?> carbsGTarget,
      Value<double?> fatGTarget,
      Value<double?> co2GTarget,
      Value<bool> kcalIsOverridden,
      Value<bool> proteinIsOverridden,
      Value<bool> carbsIsOverridden,
      Value<bool> fatIsOverridden,
      Value<bool> co2IsOverridden,
      Value<String> co2MethodologyVersion,
      Value<String?> localeTag,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });
typedef $$UserProfileTableTableUpdateCompanionBuilder =
    UserProfileTableCompanion Function({
      Value<String> id,
      Value<BigInt> hlcMillis,
      Value<int> hlcCounter,
      Value<String> hlcNodeId,
      Value<bool> dirty,
      Value<DateTime?> deletedAt,
      Value<int?> age,
      Value<String?> gender,
      Value<double?> heightCm,
      Value<double?> weightKg,
      Value<String?> activityLevel,
      Value<String?> dietaryPreference,
      Value<String?> goal,
      Value<String> units,
      Value<double?> kcalTarget,
      Value<double?> proteinGTarget,
      Value<double?> carbsGTarget,
      Value<double?> fatGTarget,
      Value<double?> co2GTarget,
      Value<bool> kcalIsOverridden,
      Value<bool> proteinIsOverridden,
      Value<bool> carbsIsOverridden,
      Value<bool> fatIsOverridden,
      Value<bool> co2IsOverridden,
      Value<String> co2MethodologyVersion,
      Value<String?> localeTag,
      Value<DateTime> createdAt,
      Value<DateTime?> updatedAt,
      Value<int> rowid,
    });

class $$UserProfileTableTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfileTableTable> {
  $$UserProfileTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<BigInt> get hlcMillis => $composableBuilder(
    column: $table.hlcMillis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hlcCounter => $composableBuilder(
    column: $table.hlcCounter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hlcNodeId => $composableBuilder(
    column: $table.hlcNodeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activityLevel => $composableBuilder(
    column: $table.activityLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dietaryPreference => $composableBuilder(
    column: $table.dietaryPreference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get units => $composableBuilder(
    column: $table.units,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kcalTarget => $composableBuilder(
    column: $table.kcalTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinGTarget => $composableBuilder(
    column: $table.proteinGTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbsGTarget => $composableBuilder(
    column: $table.carbsGTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatGTarget => $composableBuilder(
    column: $table.fatGTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get co2GTarget => $composableBuilder(
    column: $table.co2GTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get kcalIsOverridden => $composableBuilder(
    column: $table.kcalIsOverridden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get proteinIsOverridden => $composableBuilder(
    column: $table.proteinIsOverridden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get carbsIsOverridden => $composableBuilder(
    column: $table.carbsIsOverridden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get fatIsOverridden => $composableBuilder(
    column: $table.fatIsOverridden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get co2IsOverridden => $composableBuilder(
    column: $table.co2IsOverridden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get co2MethodologyVersion => $composableBuilder(
    column: $table.co2MethodologyVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localeTag => $composableBuilder(
    column: $table.localeTag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfileTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfileTableTable> {
  $$UserProfileTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<BigInt> get hlcMillis => $composableBuilder(
    column: $table.hlcMillis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hlcCounter => $composableBuilder(
    column: $table.hlcCounter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hlcNodeId => $composableBuilder(
    column: $table.hlcNodeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activityLevel => $composableBuilder(
    column: $table.activityLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dietaryPreference => $composableBuilder(
    column: $table.dietaryPreference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get units => $composableBuilder(
    column: $table.units,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kcalTarget => $composableBuilder(
    column: $table.kcalTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinGTarget => $composableBuilder(
    column: $table.proteinGTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbsGTarget => $composableBuilder(
    column: $table.carbsGTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatGTarget => $composableBuilder(
    column: $table.fatGTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get co2GTarget => $composableBuilder(
    column: $table.co2GTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get kcalIsOverridden => $composableBuilder(
    column: $table.kcalIsOverridden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get proteinIsOverridden => $composableBuilder(
    column: $table.proteinIsOverridden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get carbsIsOverridden => $composableBuilder(
    column: $table.carbsIsOverridden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get fatIsOverridden => $composableBuilder(
    column: $table.fatIsOverridden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get co2IsOverridden => $composableBuilder(
    column: $table.co2IsOverridden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get co2MethodologyVersion => $composableBuilder(
    column: $table.co2MethodologyVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localeTag => $composableBuilder(
    column: $table.localeTag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfileTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfileTableTable> {
  $$UserProfileTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<BigInt> get hlcMillis =>
      $composableBuilder(column: $table.hlcMillis, builder: (column) => column);

  GeneratedColumn<int> get hlcCounter => $composableBuilder(
    column: $table.hlcCounter,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hlcNodeId =>
      $composableBuilder(column: $table.hlcNodeId, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<String> get activityLevel => $composableBuilder(
    column: $table.activityLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dietaryPreference => $composableBuilder(
    column: $table.dietaryPreference,
    builder: (column) => column,
  );

  GeneratedColumn<String> get goal =>
      $composableBuilder(column: $table.goal, builder: (column) => column);

  GeneratedColumn<String> get units =>
      $composableBuilder(column: $table.units, builder: (column) => column);

  GeneratedColumn<double> get kcalTarget => $composableBuilder(
    column: $table.kcalTarget,
    builder: (column) => column,
  );

  GeneratedColumn<double> get proteinGTarget => $composableBuilder(
    column: $table.proteinGTarget,
    builder: (column) => column,
  );

  GeneratedColumn<double> get carbsGTarget => $composableBuilder(
    column: $table.carbsGTarget,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fatGTarget => $composableBuilder(
    column: $table.fatGTarget,
    builder: (column) => column,
  );

  GeneratedColumn<double> get co2GTarget => $composableBuilder(
    column: $table.co2GTarget,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get kcalIsOverridden => $composableBuilder(
    column: $table.kcalIsOverridden,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get proteinIsOverridden => $composableBuilder(
    column: $table.proteinIsOverridden,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get carbsIsOverridden => $composableBuilder(
    column: $table.carbsIsOverridden,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get fatIsOverridden => $composableBuilder(
    column: $table.fatIsOverridden,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get co2IsOverridden => $composableBuilder(
    column: $table.co2IsOverridden,
    builder: (column) => column,
  );

  GeneratedColumn<String> get co2MethodologyVersion => $composableBuilder(
    column: $table.co2MethodologyVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localeTag =>
      $composableBuilder(column: $table.localeTag, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserProfileTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfileTableTable,
          UserProfileRow,
          $$UserProfileTableTableFilterComposer,
          $$UserProfileTableTableOrderingComposer,
          $$UserProfileTableTableAnnotationComposer,
          $$UserProfileTableTableCreateCompanionBuilder,
          $$UserProfileTableTableUpdateCompanionBuilder,
          (
            UserProfileRow,
            BaseReferences<
              _$AppDatabase,
              $UserProfileTableTable,
              UserProfileRow
            >,
          ),
          UserProfileRow,
          PrefetchHooks Function()
        > {
  $$UserProfileTableTableTableManager(
    _$AppDatabase db,
    $UserProfileTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfileTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfileTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfileTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<BigInt> hlcMillis = const Value.absent(),
                Value<int> hlcCounter = const Value.absent(),
                Value<String> hlcNodeId = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> age = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<String?> activityLevel = const Value.absent(),
                Value<String?> dietaryPreference = const Value.absent(),
                Value<String?> goal = const Value.absent(),
                Value<String> units = const Value.absent(),
                Value<double?> kcalTarget = const Value.absent(),
                Value<double?> proteinGTarget = const Value.absent(),
                Value<double?> carbsGTarget = const Value.absent(),
                Value<double?> fatGTarget = const Value.absent(),
                Value<double?> co2GTarget = const Value.absent(),
                Value<bool> kcalIsOverridden = const Value.absent(),
                Value<bool> proteinIsOverridden = const Value.absent(),
                Value<bool> carbsIsOverridden = const Value.absent(),
                Value<bool> fatIsOverridden = const Value.absent(),
                Value<bool> co2IsOverridden = const Value.absent(),
                Value<String> co2MethodologyVersion = const Value.absent(),
                Value<String?> localeTag = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfileTableCompanion(
                id: id,
                hlcMillis: hlcMillis,
                hlcCounter: hlcCounter,
                hlcNodeId: hlcNodeId,
                dirty: dirty,
                deletedAt: deletedAt,
                age: age,
                gender: gender,
                heightCm: heightCm,
                weightKg: weightKg,
                activityLevel: activityLevel,
                dietaryPreference: dietaryPreference,
                goal: goal,
                units: units,
                kcalTarget: kcalTarget,
                proteinGTarget: proteinGTarget,
                carbsGTarget: carbsGTarget,
                fatGTarget: fatGTarget,
                co2GTarget: co2GTarget,
                kcalIsOverridden: kcalIsOverridden,
                proteinIsOverridden: proteinIsOverridden,
                carbsIsOverridden: carbsIsOverridden,
                fatIsOverridden: fatIsOverridden,
                co2IsOverridden: co2IsOverridden,
                co2MethodologyVersion: co2MethodologyVersion,
                localeTag: localeTag,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required BigInt hlcMillis,
                required int hlcCounter,
                required String hlcNodeId,
                Value<bool> dirty = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> age = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<double?> heightCm = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<String?> activityLevel = const Value.absent(),
                Value<String?> dietaryPreference = const Value.absent(),
                Value<String?> goal = const Value.absent(),
                Value<String> units = const Value.absent(),
                Value<double?> kcalTarget = const Value.absent(),
                Value<double?> proteinGTarget = const Value.absent(),
                Value<double?> carbsGTarget = const Value.absent(),
                Value<double?> fatGTarget = const Value.absent(),
                Value<double?> co2GTarget = const Value.absent(),
                Value<bool> kcalIsOverridden = const Value.absent(),
                Value<bool> proteinIsOverridden = const Value.absent(),
                Value<bool> carbsIsOverridden = const Value.absent(),
                Value<bool> fatIsOverridden = const Value.absent(),
                Value<bool> co2IsOverridden = const Value.absent(),
                Value<String> co2MethodologyVersion = const Value.absent(),
                Value<String?> localeTag = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfileTableCompanion.insert(
                id: id,
                hlcMillis: hlcMillis,
                hlcCounter: hlcCounter,
                hlcNodeId: hlcNodeId,
                dirty: dirty,
                deletedAt: deletedAt,
                age: age,
                gender: gender,
                heightCm: heightCm,
                weightKg: weightKg,
                activityLevel: activityLevel,
                dietaryPreference: dietaryPreference,
                goal: goal,
                units: units,
                kcalTarget: kcalTarget,
                proteinGTarget: proteinGTarget,
                carbsGTarget: carbsGTarget,
                fatGTarget: fatGTarget,
                co2GTarget: co2GTarget,
                kcalIsOverridden: kcalIsOverridden,
                proteinIsOverridden: proteinIsOverridden,
                carbsIsOverridden: carbsIsOverridden,
                fatIsOverridden: fatIsOverridden,
                co2IsOverridden: co2IsOverridden,
                co2MethodologyVersion: co2MethodologyVersion,
                localeTag: localeTag,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfileTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfileTableTable,
      UserProfileRow,
      $$UserProfileTableTableFilterComposer,
      $$UserProfileTableTableOrderingComposer,
      $$UserProfileTableTableAnnotationComposer,
      $$UserProfileTableTableCreateCompanionBuilder,
      $$UserProfileTableTableUpdateCompanionBuilder,
      (
        UserProfileRow,
        BaseReferences<_$AppDatabase, $UserProfileTableTable, UserProfileRow>,
      ),
      UserProfileRow,
      PrefetchHooks Function()
    >;
typedef $$ConsentRecordsTableTableCreateCompanionBuilder =
    ConsentRecordsTableCompanion Function({
      required String id,
      Value<DateTime> createdAt,
      required String appVersion,
      required String policyVersion,
      required String consentsGiven,
      Value<int> rowid,
    });
typedef $$ConsentRecordsTableTableUpdateCompanionBuilder =
    ConsentRecordsTableCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<String> appVersion,
      Value<String> policyVersion,
      Value<String> consentsGiven,
      Value<int> rowid,
    });

class $$ConsentRecordsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ConsentRecordsTableTable> {
  $$ConsentRecordsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get policyVersion => $composableBuilder(
    column: $table.policyVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get consentsGiven => $composableBuilder(
    column: $table.consentsGiven,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConsentRecordsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ConsentRecordsTableTable> {
  $$ConsentRecordsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get policyVersion => $composableBuilder(
    column: $table.policyVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get consentsGiven => $composableBuilder(
    column: $table.consentsGiven,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConsentRecordsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConsentRecordsTableTable> {
  $$ConsentRecordsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get policyVersion => $composableBuilder(
    column: $table.policyVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get consentsGiven => $composableBuilder(
    column: $table.consentsGiven,
    builder: (column) => column,
  );
}

class $$ConsentRecordsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConsentRecordsTableTable,
          ConsentRecord,
          $$ConsentRecordsTableTableFilterComposer,
          $$ConsentRecordsTableTableOrderingComposer,
          $$ConsentRecordsTableTableAnnotationComposer,
          $$ConsentRecordsTableTableCreateCompanionBuilder,
          $$ConsentRecordsTableTableUpdateCompanionBuilder,
          (
            ConsentRecord,
            BaseReferences<
              _$AppDatabase,
              $ConsentRecordsTableTable,
              ConsentRecord
            >,
          ),
          ConsentRecord,
          PrefetchHooks Function()
        > {
  $$ConsentRecordsTableTableTableManager(
    _$AppDatabase db,
    $ConsentRecordsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConsentRecordsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConsentRecordsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ConsentRecordsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> appVersion = const Value.absent(),
                Value<String> policyVersion = const Value.absent(),
                Value<String> consentsGiven = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConsentRecordsTableCompanion(
                id: id,
                createdAt: createdAt,
                appVersion: appVersion,
                policyVersion: policyVersion,
                consentsGiven: consentsGiven,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<DateTime> createdAt = const Value.absent(),
                required String appVersion,
                required String policyVersion,
                required String consentsGiven,
                Value<int> rowid = const Value.absent(),
              }) => ConsentRecordsTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                appVersion: appVersion,
                policyVersion: policyVersion,
                consentsGiven: consentsGiven,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConsentRecordsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConsentRecordsTableTable,
      ConsentRecord,
      $$ConsentRecordsTableTableFilterComposer,
      $$ConsentRecordsTableTableOrderingComposer,
      $$ConsentRecordsTableTableAnnotationComposer,
      $$ConsentRecordsTableTableCreateCompanionBuilder,
      $$ConsentRecordsTableTableUpdateCompanionBuilder,
      (
        ConsentRecord,
        BaseReferences<_$AppDatabase, $ConsentRecordsTableTable, ConsentRecord>,
      ),
      ConsentRecord,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserProfileTableTableTableManager get userProfileTable =>
      $$UserProfileTableTableTableManager(_db, _db.userProfileTable);
  $$ConsentRecordsTableTableTableManager get consentRecordsTable =>
      $$ConsentRecordsTableTableTableManager(_db, _db.consentRecordsTable);
}
