// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class UserFoodCacheFts extends Table
    with
        TableInfo<UserFoodCacheFts, UserFoodCacheFt>,
        VirtualTableInfo<UserFoodCacheFts, UserFoodCacheFt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  UserFoodCacheFts(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  static const VerificationMeta _productNameEnMeta = const VerificationMeta(
    'productNameEn',
  );
  late final GeneratedColumn<String> productNameEn = GeneratedColumn<String>(
    'product_name_en',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [productName, productNameEn, brand];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_food_cache_fts';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserFoodCacheFt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('product_name_en')) {
      context.handle(
        _productNameEnMeta,
        productNameEn.isAcceptableOrUnknown(
          data['product_name_en']!,
          _productNameEnMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameEnMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    } else if (isInserting) {
      context.missing(_brandMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  UserFoodCacheFt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserFoodCacheFt(
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      )!,
      productNameEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name_en'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      )!,
    );
  }

  @override
  UserFoodCacheFts createAlias(String alias) {
    return UserFoodCacheFts(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
  @override
  String get moduleAndArgs =>
      'fts5(product_name, product_name_en, brand, content=\'user_food_cache_table\', content_rowid=\'rowid\', tokenize=\'unicode61 remove_diacritics 2\', prefix=\'2 3 4\')';
}

class UserFoodCacheFt extends DataClass implements Insertable<UserFoodCacheFt> {
  final String productName;
  final String productNameEn;
  final String brand;
  const UserFoodCacheFt({
    required this.productName,
    required this.productNameEn,
    required this.brand,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['product_name'] = Variable<String>(productName);
    map['product_name_en'] = Variable<String>(productNameEn);
    map['brand'] = Variable<String>(brand);
    return map;
  }

  UserFoodCacheFtsCompanion toCompanion(bool nullToAbsent) {
    return UserFoodCacheFtsCompanion(
      productName: Value(productName),
      productNameEn: Value(productNameEn),
      brand: Value(brand),
    );
  }

  factory UserFoodCacheFt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserFoodCacheFt(
      productName: serializer.fromJson<String>(json['product_name']),
      productNameEn: serializer.fromJson<String>(json['product_name_en']),
      brand: serializer.fromJson<String>(json['brand']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'product_name': serializer.toJson<String>(productName),
      'product_name_en': serializer.toJson<String>(productNameEn),
      'brand': serializer.toJson<String>(brand),
    };
  }

  UserFoodCacheFt copyWith({
    String? productName,
    String? productNameEn,
    String? brand,
  }) => UserFoodCacheFt(
    productName: productName ?? this.productName,
    productNameEn: productNameEn ?? this.productNameEn,
    brand: brand ?? this.brand,
  );
  UserFoodCacheFt copyWithCompanion(UserFoodCacheFtsCompanion data) {
    return UserFoodCacheFt(
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      productNameEn: data.productNameEn.present
          ? data.productNameEn.value
          : this.productNameEn,
      brand: data.brand.present ? data.brand.value : this.brand,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserFoodCacheFt(')
          ..write('productName: $productName, ')
          ..write('productNameEn: $productNameEn, ')
          ..write('brand: $brand')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(productName, productNameEn, brand);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserFoodCacheFt &&
          other.productName == this.productName &&
          other.productNameEn == this.productNameEn &&
          other.brand == this.brand);
}

class UserFoodCacheFtsCompanion extends UpdateCompanion<UserFoodCacheFt> {
  final Value<String> productName;
  final Value<String> productNameEn;
  final Value<String> brand;
  final Value<int> rowid;
  const UserFoodCacheFtsCompanion({
    this.productName = const Value.absent(),
    this.productNameEn = const Value.absent(),
    this.brand = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserFoodCacheFtsCompanion.insert({
    required String productName,
    required String productNameEn,
    required String brand,
    this.rowid = const Value.absent(),
  }) : productName = Value(productName),
       productNameEn = Value(productNameEn),
       brand = Value(brand);
  static Insertable<UserFoodCacheFt> custom({
    Expression<String>? productName,
    Expression<String>? productNameEn,
    Expression<String>? brand,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (productName != null) 'product_name': productName,
      if (productNameEn != null) 'product_name_en': productNameEn,
      if (brand != null) 'brand': brand,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserFoodCacheFtsCompanion copyWith({
    Value<String>? productName,
    Value<String>? productNameEn,
    Value<String>? brand,
    Value<int>? rowid,
  }) {
    return UserFoodCacheFtsCompanion(
      productName: productName ?? this.productName,
      productNameEn: productNameEn ?? this.productNameEn,
      brand: brand ?? this.brand,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (productNameEn.present) {
      map['product_name_en'] = Variable<String>(productNameEn.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserFoodCacheFtsCompanion(')
          ..write('productName: $productName, ')
          ..write('productNameEn: $productNameEn, ')
          ..write('brand: $brand, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

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

class $UserFoodCacheTableTable extends UserFoodCacheTable
    with TableInfo<$UserFoodCacheTableTable, UserFoodCacheRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserFoodCacheTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productNameEnMeta = const VerificationMeta(
    'productNameEn',
  );
  @override
  late final GeneratedColumn<String> productNameEn = GeneratedColumn<String>(
    'product_name_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _calories100gMeta = const VerificationMeta(
    'calories100g',
  );
  @override
  late final GeneratedColumn<double> calories100g = GeneratedColumn<double>(
    'calories100g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _protein100gMeta = const VerificationMeta(
    'protein100g',
  );
  @override
  late final GeneratedColumn<double> protein100g = GeneratedColumn<double>(
    'protein100g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _carbs100gMeta = const VerificationMeta(
    'carbs100g',
  );
  @override
  late final GeneratedColumn<double> carbs100g = GeneratedColumn<double>(
    'carbs100g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fat100gMeta = const VerificationMeta(
    'fat100g',
  );
  @override
  late final GeneratedColumn<double> fat100g = GeneratedColumn<double>(
    'fat100g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoriesTagsMeta = const VerificationMeta(
    'categoriesTags',
  );
  @override
  late final GeneratedColumn<String> categoriesTags = GeneratedColumn<String>(
    'categories_tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    barcode,
    productName,
    productNameEn,
    brand,
    calories100g,
    protein100g,
    carbs100g,
    fat100g,
    categoriesTags,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_food_cache_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserFoodCacheRow> instance, {
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
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('product_name_en')) {
      context.handle(
        _productNameEnMeta,
        productNameEn.isAcceptableOrUnknown(
          data['product_name_en']!,
          _productNameEnMeta,
        ),
      );
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('calories100g')) {
      context.handle(
        _calories100gMeta,
        calories100g.isAcceptableOrUnknown(
          data['calories100g']!,
          _calories100gMeta,
        ),
      );
    }
    if (data.containsKey('protein100g')) {
      context.handle(
        _protein100gMeta,
        protein100g.isAcceptableOrUnknown(
          data['protein100g']!,
          _protein100gMeta,
        ),
      );
    }
    if (data.containsKey('carbs100g')) {
      context.handle(
        _carbs100gMeta,
        carbs100g.isAcceptableOrUnknown(data['carbs100g']!, _carbs100gMeta),
      );
    }
    if (data.containsKey('fat100g')) {
      context.handle(
        _fat100gMeta,
        fat100g.isAcceptableOrUnknown(data['fat100g']!, _fat100gMeta),
      );
    }
    if (data.containsKey('categories_tags')) {
      context.handle(
        _categoriesTagsMeta,
        categoriesTags.isAcceptableOrUnknown(
          data['categories_tags']!,
          _categoriesTagsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserFoodCacheRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserFoodCacheRow(
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
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      )!,
      productNameEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name_en'],
      ),
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      calories100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories100g'],
      ),
      protein100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein100g'],
      ),
      carbs100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs100g'],
      ),
      fat100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat100g'],
      ),
      categoriesTags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categories_tags'],
      ),
    );
  }

  @override
  $UserFoodCacheTableTable createAlias(String alias) {
    return $UserFoodCacheTableTable(attachedDatabase, alias);
  }
}

class UserFoodCacheRow extends DataClass
    implements Insertable<UserFoodCacheRow> {
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

  /// EAN barcode; nullable because some API results may lack a barcode.
  final String? barcode;

  /// Primary product name. Always present — rows with empty product_name
  /// are rejected at the repository layer before insert.
  final String productName;

  /// English product name, nullable. Absent for non-English products.
  final String? productNameEn;

  /// Brand name, nullable.
  final String? brand;

  /// Energy in kcal per 100 g, nullable when not reported.
  final double? calories100g;

  /// Protein in g per 100 g, nullable when not reported.
  final double? protein100g;

  /// Carbohydrates in g per 100 g, nullable when not reported.
  final double? carbs100g;

  /// Fat in g per 100 g, nullable when not reported.
  final double? fat100g;

  /// Comma-separated OFF categories_tags, nullable.
  /// Stored for Phase 4+ category filtering — consumer not yet wired.
  final String? categoriesTags;
  const UserFoodCacheRow({
    required this.id,
    required this.hlcMillis,
    required this.hlcCounter,
    required this.hlcNodeId,
    required this.dirty,
    this.deletedAt,
    this.barcode,
    required this.productName,
    this.productNameEn,
    this.brand,
    this.calories100g,
    this.protein100g,
    this.carbs100g,
    this.fat100g,
    this.categoriesTags,
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
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['product_name'] = Variable<String>(productName);
    if (!nullToAbsent || productNameEn != null) {
      map['product_name_en'] = Variable<String>(productNameEn);
    }
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    if (!nullToAbsent || calories100g != null) {
      map['calories100g'] = Variable<double>(calories100g);
    }
    if (!nullToAbsent || protein100g != null) {
      map['protein100g'] = Variable<double>(protein100g);
    }
    if (!nullToAbsent || carbs100g != null) {
      map['carbs100g'] = Variable<double>(carbs100g);
    }
    if (!nullToAbsent || fat100g != null) {
      map['fat100g'] = Variable<double>(fat100g);
    }
    if (!nullToAbsent || categoriesTags != null) {
      map['categories_tags'] = Variable<String>(categoriesTags);
    }
    return map;
  }

  UserFoodCacheTableCompanion toCompanion(bool nullToAbsent) {
    return UserFoodCacheTableCompanion(
      id: Value(id),
      hlcMillis: Value(hlcMillis),
      hlcCounter: Value(hlcCounter),
      hlcNodeId: Value(hlcNodeId),
      dirty: Value(dirty),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      productName: Value(productName),
      productNameEn: productNameEn == null && nullToAbsent
          ? const Value.absent()
          : Value(productNameEn),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      calories100g: calories100g == null && nullToAbsent
          ? const Value.absent()
          : Value(calories100g),
      protein100g: protein100g == null && nullToAbsent
          ? const Value.absent()
          : Value(protein100g),
      carbs100g: carbs100g == null && nullToAbsent
          ? const Value.absent()
          : Value(carbs100g),
      fat100g: fat100g == null && nullToAbsent
          ? const Value.absent()
          : Value(fat100g),
      categoriesTags: categoriesTags == null && nullToAbsent
          ? const Value.absent()
          : Value(categoriesTags),
    );
  }

  factory UserFoodCacheRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserFoodCacheRow(
      id: serializer.fromJson<String>(json['id']),
      hlcMillis: serializer.fromJson<BigInt>(json['hlcMillis']),
      hlcCounter: serializer.fromJson<int>(json['hlcCounter']),
      hlcNodeId: serializer.fromJson<String>(json['hlcNodeId']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      productName: serializer.fromJson<String>(json['productName']),
      productNameEn: serializer.fromJson<String?>(json['productNameEn']),
      brand: serializer.fromJson<String?>(json['brand']),
      calories100g: serializer.fromJson<double?>(json['calories100g']),
      protein100g: serializer.fromJson<double?>(json['protein100g']),
      carbs100g: serializer.fromJson<double?>(json['carbs100g']),
      fat100g: serializer.fromJson<double?>(json['fat100g']),
      categoriesTags: serializer.fromJson<String?>(json['categoriesTags']),
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
      'barcode': serializer.toJson<String?>(barcode),
      'productName': serializer.toJson<String>(productName),
      'productNameEn': serializer.toJson<String?>(productNameEn),
      'brand': serializer.toJson<String?>(brand),
      'calories100g': serializer.toJson<double?>(calories100g),
      'protein100g': serializer.toJson<double?>(protein100g),
      'carbs100g': serializer.toJson<double?>(carbs100g),
      'fat100g': serializer.toJson<double?>(fat100g),
      'categoriesTags': serializer.toJson<String?>(categoriesTags),
    };
  }

  UserFoodCacheRow copyWith({
    String? id,
    BigInt? hlcMillis,
    int? hlcCounter,
    String? hlcNodeId,
    bool? dirty,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> barcode = const Value.absent(),
    String? productName,
    Value<String?> productNameEn = const Value.absent(),
    Value<String?> brand = const Value.absent(),
    Value<double?> calories100g = const Value.absent(),
    Value<double?> protein100g = const Value.absent(),
    Value<double?> carbs100g = const Value.absent(),
    Value<double?> fat100g = const Value.absent(),
    Value<String?> categoriesTags = const Value.absent(),
  }) => UserFoodCacheRow(
    id: id ?? this.id,
    hlcMillis: hlcMillis ?? this.hlcMillis,
    hlcCounter: hlcCounter ?? this.hlcCounter,
    hlcNodeId: hlcNodeId ?? this.hlcNodeId,
    dirty: dirty ?? this.dirty,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    barcode: barcode.present ? barcode.value : this.barcode,
    productName: productName ?? this.productName,
    productNameEn: productNameEn.present
        ? productNameEn.value
        : this.productNameEn,
    brand: brand.present ? brand.value : this.brand,
    calories100g: calories100g.present ? calories100g.value : this.calories100g,
    protein100g: protein100g.present ? protein100g.value : this.protein100g,
    carbs100g: carbs100g.present ? carbs100g.value : this.carbs100g,
    fat100g: fat100g.present ? fat100g.value : this.fat100g,
    categoriesTags: categoriesTags.present
        ? categoriesTags.value
        : this.categoriesTags,
  );
  UserFoodCacheRow copyWithCompanion(UserFoodCacheTableCompanion data) {
    return UserFoodCacheRow(
      id: data.id.present ? data.id.value : this.id,
      hlcMillis: data.hlcMillis.present ? data.hlcMillis.value : this.hlcMillis,
      hlcCounter: data.hlcCounter.present
          ? data.hlcCounter.value
          : this.hlcCounter,
      hlcNodeId: data.hlcNodeId.present ? data.hlcNodeId.value : this.hlcNodeId,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      productNameEn: data.productNameEn.present
          ? data.productNameEn.value
          : this.productNameEn,
      brand: data.brand.present ? data.brand.value : this.brand,
      calories100g: data.calories100g.present
          ? data.calories100g.value
          : this.calories100g,
      protein100g: data.protein100g.present
          ? data.protein100g.value
          : this.protein100g,
      carbs100g: data.carbs100g.present ? data.carbs100g.value : this.carbs100g,
      fat100g: data.fat100g.present ? data.fat100g.value : this.fat100g,
      categoriesTags: data.categoriesTags.present
          ? data.categoriesTags.value
          : this.categoriesTags,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserFoodCacheRow(')
          ..write('id: $id, ')
          ..write('hlcMillis: $hlcMillis, ')
          ..write('hlcCounter: $hlcCounter, ')
          ..write('hlcNodeId: $hlcNodeId, ')
          ..write('dirty: $dirty, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('barcode: $barcode, ')
          ..write('productName: $productName, ')
          ..write('productNameEn: $productNameEn, ')
          ..write('brand: $brand, ')
          ..write('calories100g: $calories100g, ')
          ..write('protein100g: $protein100g, ')
          ..write('carbs100g: $carbs100g, ')
          ..write('fat100g: $fat100g, ')
          ..write('categoriesTags: $categoriesTags')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    hlcMillis,
    hlcCounter,
    hlcNodeId,
    dirty,
    deletedAt,
    barcode,
    productName,
    productNameEn,
    brand,
    calories100g,
    protein100g,
    carbs100g,
    fat100g,
    categoriesTags,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserFoodCacheRow &&
          other.id == this.id &&
          other.hlcMillis == this.hlcMillis &&
          other.hlcCounter == this.hlcCounter &&
          other.hlcNodeId == this.hlcNodeId &&
          other.dirty == this.dirty &&
          other.deletedAt == this.deletedAt &&
          other.barcode == this.barcode &&
          other.productName == this.productName &&
          other.productNameEn == this.productNameEn &&
          other.brand == this.brand &&
          other.calories100g == this.calories100g &&
          other.protein100g == this.protein100g &&
          other.carbs100g == this.carbs100g &&
          other.fat100g == this.fat100g &&
          other.categoriesTags == this.categoriesTags);
}

class UserFoodCacheTableCompanion extends UpdateCompanion<UserFoodCacheRow> {
  final Value<String> id;
  final Value<BigInt> hlcMillis;
  final Value<int> hlcCounter;
  final Value<String> hlcNodeId;
  final Value<bool> dirty;
  final Value<DateTime?> deletedAt;
  final Value<String?> barcode;
  final Value<String> productName;
  final Value<String?> productNameEn;
  final Value<String?> brand;
  final Value<double?> calories100g;
  final Value<double?> protein100g;
  final Value<double?> carbs100g;
  final Value<double?> fat100g;
  final Value<String?> categoriesTags;
  final Value<int> rowid;
  const UserFoodCacheTableCompanion({
    this.id = const Value.absent(),
    this.hlcMillis = const Value.absent(),
    this.hlcCounter = const Value.absent(),
    this.hlcNodeId = const Value.absent(),
    this.dirty = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.barcode = const Value.absent(),
    this.productName = const Value.absent(),
    this.productNameEn = const Value.absent(),
    this.brand = const Value.absent(),
    this.calories100g = const Value.absent(),
    this.protein100g = const Value.absent(),
    this.carbs100g = const Value.absent(),
    this.fat100g = const Value.absent(),
    this.categoriesTags = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserFoodCacheTableCompanion.insert({
    required String id,
    required BigInt hlcMillis,
    required int hlcCounter,
    required String hlcNodeId,
    this.dirty = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.barcode = const Value.absent(),
    required String productName,
    this.productNameEn = const Value.absent(),
    this.brand = const Value.absent(),
    this.calories100g = const Value.absent(),
    this.protein100g = const Value.absent(),
    this.carbs100g = const Value.absent(),
    this.fat100g = const Value.absent(),
    this.categoriesTags = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       hlcMillis = Value(hlcMillis),
       hlcCounter = Value(hlcCounter),
       hlcNodeId = Value(hlcNodeId),
       productName = Value(productName);
  static Insertable<UserFoodCacheRow> custom({
    Expression<String>? id,
    Expression<BigInt>? hlcMillis,
    Expression<int>? hlcCounter,
    Expression<String>? hlcNodeId,
    Expression<bool>? dirty,
    Expression<DateTime>? deletedAt,
    Expression<String>? barcode,
    Expression<String>? productName,
    Expression<String>? productNameEn,
    Expression<String>? brand,
    Expression<double>? calories100g,
    Expression<double>? protein100g,
    Expression<double>? carbs100g,
    Expression<double>? fat100g,
    Expression<String>? categoriesTags,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hlcMillis != null) 'hlc_millis': hlcMillis,
      if (hlcCounter != null) 'hlc_counter': hlcCounter,
      if (hlcNodeId != null) 'hlc_node_id': hlcNodeId,
      if (dirty != null) 'dirty': dirty,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (barcode != null) 'barcode': barcode,
      if (productName != null) 'product_name': productName,
      if (productNameEn != null) 'product_name_en': productNameEn,
      if (brand != null) 'brand': brand,
      if (calories100g != null) 'calories100g': calories100g,
      if (protein100g != null) 'protein100g': protein100g,
      if (carbs100g != null) 'carbs100g': carbs100g,
      if (fat100g != null) 'fat100g': fat100g,
      if (categoriesTags != null) 'categories_tags': categoriesTags,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserFoodCacheTableCompanion copyWith({
    Value<String>? id,
    Value<BigInt>? hlcMillis,
    Value<int>? hlcCounter,
    Value<String>? hlcNodeId,
    Value<bool>? dirty,
    Value<DateTime?>? deletedAt,
    Value<String?>? barcode,
    Value<String>? productName,
    Value<String?>? productNameEn,
    Value<String?>? brand,
    Value<double?>? calories100g,
    Value<double?>? protein100g,
    Value<double?>? carbs100g,
    Value<double?>? fat100g,
    Value<String?>? categoriesTags,
    Value<int>? rowid,
  }) {
    return UserFoodCacheTableCompanion(
      id: id ?? this.id,
      hlcMillis: hlcMillis ?? this.hlcMillis,
      hlcCounter: hlcCounter ?? this.hlcCounter,
      hlcNodeId: hlcNodeId ?? this.hlcNodeId,
      dirty: dirty ?? this.dirty,
      deletedAt: deletedAt ?? this.deletedAt,
      barcode: barcode ?? this.barcode,
      productName: productName ?? this.productName,
      productNameEn: productNameEn ?? this.productNameEn,
      brand: brand ?? this.brand,
      calories100g: calories100g ?? this.calories100g,
      protein100g: protein100g ?? this.protein100g,
      carbs100g: carbs100g ?? this.carbs100g,
      fat100g: fat100g ?? this.fat100g,
      categoriesTags: categoriesTags ?? this.categoriesTags,
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
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (productNameEn.present) {
      map['product_name_en'] = Variable<String>(productNameEn.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (calories100g.present) {
      map['calories100g'] = Variable<double>(calories100g.value);
    }
    if (protein100g.present) {
      map['protein100g'] = Variable<double>(protein100g.value);
    }
    if (carbs100g.present) {
      map['carbs100g'] = Variable<double>(carbs100g.value);
    }
    if (fat100g.present) {
      map['fat100g'] = Variable<double>(fat100g.value);
    }
    if (categoriesTags.present) {
      map['categories_tags'] = Variable<String>(categoriesTags.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserFoodCacheTableCompanion(')
          ..write('id: $id, ')
          ..write('hlcMillis: $hlcMillis, ')
          ..write('hlcCounter: $hlcCounter, ')
          ..write('hlcNodeId: $hlcNodeId, ')
          ..write('dirty: $dirty, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('barcode: $barcode, ')
          ..write('productName: $productName, ')
          ..write('productNameEn: $productNameEn, ')
          ..write('brand: $brand, ')
          ..write('calories100g: $calories100g, ')
          ..write('protein100g: $protein100g, ')
          ..write('carbs100g: $carbs100g, ')
          ..write('fat100g: $fat100g, ')
          ..write('categoriesTags: $categoriesTags, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MealEntryTableTable extends MealEntryTable
    with TableInfo<$MealEntryTableTable, MealEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MealEntryTableTable(this.attachedDatabase, [this._alias]);
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
  @override
  late final GeneratedColumnWithTypeConverter<MealSlot, String> mealSlot =
      GeneratedColumn<String>(
        'meal_slot',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MealSlot>($MealEntryTableTable.$convertermealSlot);
  static const VerificationMeta _foodRefMeta = const VerificationMeta(
    'foodRef',
  );
  @override
  late final GeneratedColumn<String> foodRef = GeneratedColumn<String>(
    'food_ref',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foodRefSourceMeta = const VerificationMeta(
    'foodRefSource',
  );
  @override
  late final GeneratedColumn<String> foodRefSource = GeneratedColumn<String>(
    'food_ref_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PortionUnit, String> unit =
      GeneratedColumn<String>(
        'unit',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PortionUnit>($MealEntryTableTable.$converterunit);
  static const VerificationMeta _productNameSnapshotMeta =
      const VerificationMeta('productNameSnapshot');
  @override
  late final GeneratedColumn<String> productNameSnapshot =
      GeneratedColumn<String>(
        'product_name_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _brandSnapshotMeta = const VerificationMeta(
    'brandSnapshot',
  );
  @override
  late final GeneratedColumn<String> brandSnapshot = GeneratedColumn<String>(
    'brand_snapshot',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _calories100gSnapshotMeta =
      const VerificationMeta('calories100gSnapshot');
  @override
  late final GeneratedColumn<double> calories100gSnapshot =
      GeneratedColumn<double>(
        'calories100g_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _protein100gSnapshotMeta =
      const VerificationMeta('protein100gSnapshot');
  @override
  late final GeneratedColumn<double> protein100gSnapshot =
      GeneratedColumn<double>(
        'protein100g_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _carbs100gSnapshotMeta = const VerificationMeta(
    'carbs100gSnapshot',
  );
  @override
  late final GeneratedColumn<double> carbs100gSnapshot =
      GeneratedColumn<double>(
        'carbs100g_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _fat100gSnapshotMeta = const VerificationMeta(
    'fat100gSnapshot',
  );
  @override
  late final GeneratedColumn<double> fat100gSnapshot = GeneratedColumn<double>(
    'fat100g_snapshot',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sugar100gSnapshotMeta = const VerificationMeta(
    'sugar100gSnapshot',
  );
  @override
  late final GeneratedColumn<double> sugar100gSnapshot =
      GeneratedColumn<double>(
        'sugar100g_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _fiber100gSnapshotMeta = const VerificationMeta(
    'fiber100gSnapshot',
  );
  @override
  late final GeneratedColumn<double> fiber100gSnapshot =
      GeneratedColumn<double>(
        'fiber100g_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _saltSnapshotMeta = const VerificationMeta(
    'saltSnapshot',
  );
  @override
  late final GeneratedColumn<double> saltSnapshot = GeneratedColumn<double>(
    'salt_snapshot',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _co2e100gSnapshotMeta = const VerificationMeta(
    'co2e100gSnapshot',
  );
  @override
  late final GeneratedColumn<double> co2e100gSnapshot = GeneratedColumn<double>(
    'co2e100g_snapshot',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confidenceBandSnapshotMeta =
      const VerificationMeta('confidenceBandSnapshot');
  @override
  late final GeneratedColumn<String> confidenceBandSnapshot =
      GeneratedColumn<String>(
        'confidence_band_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _co2MethodologyVersionSnapshotMeta =
      const VerificationMeta('co2MethodologyVersionSnapshot');
  @override
  late final GeneratedColumn<String> co2MethodologyVersionSnapshot =
      GeneratedColumn<String>(
        'co2_methodology_version_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _loggedAtMeta = const VerificationMeta(
    'loggedAt',
  );
  @override
  late final GeneratedColumn<DateTime> loggedAt = GeneratedColumn<DateTime>(
    'logged_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _logDateMeta = const VerificationMeta(
    'logDate',
  );
  @override
  late final GeneratedColumn<String> logDate = GeneratedColumn<String>(
    'log_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    hlcMillis,
    hlcCounter,
    hlcNodeId,
    dirty,
    deletedAt,
    mealSlot,
    foodRef,
    foodRefSource,
    quantity,
    unit,
    productNameSnapshot,
    brandSnapshot,
    calories100gSnapshot,
    protein100gSnapshot,
    carbs100gSnapshot,
    fat100gSnapshot,
    sugar100gSnapshot,
    fiber100gSnapshot,
    saltSnapshot,
    co2e100gSnapshot,
    confidenceBandSnapshot,
    co2MethodologyVersionSnapshot,
    loggedAt,
    logDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meal_entry_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<MealEntryRow> instance, {
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
    if (data.containsKey('food_ref')) {
      context.handle(
        _foodRefMeta,
        foodRef.isAcceptableOrUnknown(data['food_ref']!, _foodRefMeta),
      );
    } else if (isInserting) {
      context.missing(_foodRefMeta);
    }
    if (data.containsKey('food_ref_source')) {
      context.handle(
        _foodRefSourceMeta,
        foodRefSource.isAcceptableOrUnknown(
          data['food_ref_source']!,
          _foodRefSourceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_foodRefSourceMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('product_name_snapshot')) {
      context.handle(
        _productNameSnapshotMeta,
        productNameSnapshot.isAcceptableOrUnknown(
          data['product_name_snapshot']!,
          _productNameSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameSnapshotMeta);
    }
    if (data.containsKey('brand_snapshot')) {
      context.handle(
        _brandSnapshotMeta,
        brandSnapshot.isAcceptableOrUnknown(
          data['brand_snapshot']!,
          _brandSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('calories100g_snapshot')) {
      context.handle(
        _calories100gSnapshotMeta,
        calories100gSnapshot.isAcceptableOrUnknown(
          data['calories100g_snapshot']!,
          _calories100gSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('protein100g_snapshot')) {
      context.handle(
        _protein100gSnapshotMeta,
        protein100gSnapshot.isAcceptableOrUnknown(
          data['protein100g_snapshot']!,
          _protein100gSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('carbs100g_snapshot')) {
      context.handle(
        _carbs100gSnapshotMeta,
        carbs100gSnapshot.isAcceptableOrUnknown(
          data['carbs100g_snapshot']!,
          _carbs100gSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('fat100g_snapshot')) {
      context.handle(
        _fat100gSnapshotMeta,
        fat100gSnapshot.isAcceptableOrUnknown(
          data['fat100g_snapshot']!,
          _fat100gSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('sugar100g_snapshot')) {
      context.handle(
        _sugar100gSnapshotMeta,
        sugar100gSnapshot.isAcceptableOrUnknown(
          data['sugar100g_snapshot']!,
          _sugar100gSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('fiber100g_snapshot')) {
      context.handle(
        _fiber100gSnapshotMeta,
        fiber100gSnapshot.isAcceptableOrUnknown(
          data['fiber100g_snapshot']!,
          _fiber100gSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('salt_snapshot')) {
      context.handle(
        _saltSnapshotMeta,
        saltSnapshot.isAcceptableOrUnknown(
          data['salt_snapshot']!,
          _saltSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('co2e100g_snapshot')) {
      context.handle(
        _co2e100gSnapshotMeta,
        co2e100gSnapshot.isAcceptableOrUnknown(
          data['co2e100g_snapshot']!,
          _co2e100gSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('confidence_band_snapshot')) {
      context.handle(
        _confidenceBandSnapshotMeta,
        confidenceBandSnapshot.isAcceptableOrUnknown(
          data['confidence_band_snapshot']!,
          _confidenceBandSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('co2_methodology_version_snapshot')) {
      context.handle(
        _co2MethodologyVersionSnapshotMeta,
        co2MethodologyVersionSnapshot.isAcceptableOrUnknown(
          data['co2_methodology_version_snapshot']!,
          _co2MethodologyVersionSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('logged_at')) {
      context.handle(
        _loggedAtMeta,
        loggedAt.isAcceptableOrUnknown(data['logged_at']!, _loggedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_loggedAtMeta);
    }
    if (data.containsKey('log_date')) {
      context.handle(
        _logDateMeta,
        logDate.isAcceptableOrUnknown(data['log_date']!, _logDateMeta),
      );
    } else if (isInserting) {
      context.missing(_logDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MealEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MealEntryRow(
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
      mealSlot: $MealEntryTableTable.$convertermealSlot.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}meal_slot'],
        )!,
      ),
      foodRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_ref'],
      )!,
      foodRefSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_ref_source'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      unit: $MealEntryTableTable.$converterunit.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}unit'],
        )!,
      ),
      productNameSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name_snapshot'],
      )!,
      brandSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand_snapshot'],
      ),
      calories100gSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories100g_snapshot'],
      ),
      protein100gSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein100g_snapshot'],
      ),
      carbs100gSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs100g_snapshot'],
      ),
      fat100gSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat100g_snapshot'],
      ),
      sugar100gSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sugar100g_snapshot'],
      ),
      fiber100gSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fiber100g_snapshot'],
      ),
      saltSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}salt_snapshot'],
      ),
      co2e100gSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}co2e100g_snapshot'],
      ),
      confidenceBandSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}confidence_band_snapshot'],
      ),
      co2MethodologyVersionSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}co2_methodology_version_snapshot'],
      ),
      loggedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}logged_at'],
      )!,
      logDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}log_date'],
      )!,
    );
  }

  @override
  $MealEntryTableTable createAlias(String alias) {
    return $MealEntryTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MealSlot, String, String> $convertermealSlot =
      const EnumNameConverter<MealSlot>(MealSlot.values);
  static JsonTypeConverter2<PortionUnit, String, String> $converterunit =
      const EnumNameConverter<PortionUnit>(PortionUnit.values);
}

class MealEntryRow extends DataClass implements Insertable<MealEntryRow> {
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

  /// Which meal slot this entry belongs to (breakfast/lunch/dinner/snack).
  /// Stored via `textEnum` as `Enum.name` — append-only, see [MealSlot].
  final MealSlot mealSlot;

  /// Reference to the source food: a barcode (off_ref/user_food_cache) or
  /// a `UserFoodTable.id` (user_foods). Never a Drift `.references()` FK
  /// (RESEARCH.md Pitfall 1 — cross-attached-DB FK is impossible and would
  /// fight the snapshot data model).
  final String foodRef;

  /// One of `'off_ref'`, `'user_food_cache'`, `'user_foods'` — identifies
  /// which table/database [foodRef] resolves against.
  final String foodRefSource;

  /// Logged quantity, in [unit].
  final double quantity;

  /// Unit the [quantity] is expressed in (g/ml/piece/cup/portion).
  final PortionUnit unit;

  /// Product name captured at log time. See class doc for the
  /// "snapshot, not reference" principle.
  final String productNameSnapshot;

  /// Brand captured at log time, nullable.
  final String? brandSnapshot;

  /// Energy in kcal per 100 g/ml, captured at log time.
  final double? calories100gSnapshot;

  /// Protein in g per 100 g/ml, captured at log time.
  final double? protein100gSnapshot;

  /// Carbohydrates in g per 100 g/ml, captured at log time.
  final double? carbs100gSnapshot;

  /// Fat in g per 100 g/ml, captured at log time.
  final double? fat100gSnapshot;

  /// Sugar in g per 100 g/ml, captured at log time. Added in Phase 5
  /// (NUTR-01) — see class doc for nullability rules.
  final double? sugar100gSnapshot;

  /// Fiber in g per 100 g/ml, captured at log time. Added in Phase 5
  /// (NUTR-01) — see class doc for nullability rules.
  final double? fiber100gSnapshot;

  /// Salt in g per 100 g/ml, captured at log time (this app's EU-label
  /// "sodium" convention — see class doc). Added in Phase 5 (NUTR-01) —
  /// see class doc for nullability rules.
  final double? saltSnapshot;

  /// kg CO2e per kg product, captured at log time.
  final double? co2e100gSnapshot;

  /// Confidence band ('high'/'medium'/'low'), captured at log time.
  final String? confidenceBandSnapshot;

  /// Version of the CO₂ calculation methodology that produced
  /// [co2e100gSnapshot], captured at log time (CO2-04 — per
  /// `01-CONTEXT.md`'s locked decision that every CO₂-bearing table
  /// created in later phases carries this column, matching
  /// `UserProfileTable.co2MethodologyVersion`'s precedent). Nullable and
  /// only meaningful alongside a non-null [co2e100gSnapshot] — a future
  /// methodology recalculation flow (Phase 7+) can identify which
  /// already-logged entries were computed under an older methodology
  /// without needing to re-derive it from [loggedAt].
  final String? co2MethodologyVersionSnapshot;

  /// Wall-clock timestamp of when the entry was logged.
  final DateTime loggedAt;

  /// `'YYYY-MM-DD'` local calendar day, computed once in Dart at write
  /// time (RESEARCH.md Pattern 3 / Pitfall 2 — never derived via SQL
  /// `strftime`). Used for the same-slot/same-day merge check and for
  /// grouping the dashboard entries list.
  final String logDate;
  const MealEntryRow({
    required this.id,
    required this.hlcMillis,
    required this.hlcCounter,
    required this.hlcNodeId,
    required this.dirty,
    this.deletedAt,
    required this.mealSlot,
    required this.foodRef,
    required this.foodRefSource,
    required this.quantity,
    required this.unit,
    required this.productNameSnapshot,
    this.brandSnapshot,
    this.calories100gSnapshot,
    this.protein100gSnapshot,
    this.carbs100gSnapshot,
    this.fat100gSnapshot,
    this.sugar100gSnapshot,
    this.fiber100gSnapshot,
    this.saltSnapshot,
    this.co2e100gSnapshot,
    this.confidenceBandSnapshot,
    this.co2MethodologyVersionSnapshot,
    required this.loggedAt,
    required this.logDate,
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
    {
      map['meal_slot'] = Variable<String>(
        $MealEntryTableTable.$convertermealSlot.toSql(mealSlot),
      );
    }
    map['food_ref'] = Variable<String>(foodRef);
    map['food_ref_source'] = Variable<String>(foodRefSource);
    map['quantity'] = Variable<double>(quantity);
    {
      map['unit'] = Variable<String>(
        $MealEntryTableTable.$converterunit.toSql(unit),
      );
    }
    map['product_name_snapshot'] = Variable<String>(productNameSnapshot);
    if (!nullToAbsent || brandSnapshot != null) {
      map['brand_snapshot'] = Variable<String>(brandSnapshot);
    }
    if (!nullToAbsent || calories100gSnapshot != null) {
      map['calories100g_snapshot'] = Variable<double>(calories100gSnapshot);
    }
    if (!nullToAbsent || protein100gSnapshot != null) {
      map['protein100g_snapshot'] = Variable<double>(protein100gSnapshot);
    }
    if (!nullToAbsent || carbs100gSnapshot != null) {
      map['carbs100g_snapshot'] = Variable<double>(carbs100gSnapshot);
    }
    if (!nullToAbsent || fat100gSnapshot != null) {
      map['fat100g_snapshot'] = Variable<double>(fat100gSnapshot);
    }
    if (!nullToAbsent || sugar100gSnapshot != null) {
      map['sugar100g_snapshot'] = Variable<double>(sugar100gSnapshot);
    }
    if (!nullToAbsent || fiber100gSnapshot != null) {
      map['fiber100g_snapshot'] = Variable<double>(fiber100gSnapshot);
    }
    if (!nullToAbsent || saltSnapshot != null) {
      map['salt_snapshot'] = Variable<double>(saltSnapshot);
    }
    if (!nullToAbsent || co2e100gSnapshot != null) {
      map['co2e100g_snapshot'] = Variable<double>(co2e100gSnapshot);
    }
    if (!nullToAbsent || confidenceBandSnapshot != null) {
      map['confidence_band_snapshot'] = Variable<String>(
        confidenceBandSnapshot,
      );
    }
    if (!nullToAbsent || co2MethodologyVersionSnapshot != null) {
      map['co2_methodology_version_snapshot'] = Variable<String>(
        co2MethodologyVersionSnapshot,
      );
    }
    map['logged_at'] = Variable<DateTime>(loggedAt);
    map['log_date'] = Variable<String>(logDate);
    return map;
  }

  MealEntryTableCompanion toCompanion(bool nullToAbsent) {
    return MealEntryTableCompanion(
      id: Value(id),
      hlcMillis: Value(hlcMillis),
      hlcCounter: Value(hlcCounter),
      hlcNodeId: Value(hlcNodeId),
      dirty: Value(dirty),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      mealSlot: Value(mealSlot),
      foodRef: Value(foodRef),
      foodRefSource: Value(foodRefSource),
      quantity: Value(quantity),
      unit: Value(unit),
      productNameSnapshot: Value(productNameSnapshot),
      brandSnapshot: brandSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(brandSnapshot),
      calories100gSnapshot: calories100gSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(calories100gSnapshot),
      protein100gSnapshot: protein100gSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(protein100gSnapshot),
      carbs100gSnapshot: carbs100gSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(carbs100gSnapshot),
      fat100gSnapshot: fat100gSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(fat100gSnapshot),
      sugar100gSnapshot: sugar100gSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(sugar100gSnapshot),
      fiber100gSnapshot: fiber100gSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(fiber100gSnapshot),
      saltSnapshot: saltSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(saltSnapshot),
      co2e100gSnapshot: co2e100gSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(co2e100gSnapshot),
      confidenceBandSnapshot: confidenceBandSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(confidenceBandSnapshot),
      co2MethodologyVersionSnapshot:
          co2MethodologyVersionSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(co2MethodologyVersionSnapshot),
      loggedAt: Value(loggedAt),
      logDate: Value(logDate),
    );
  }

  factory MealEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MealEntryRow(
      id: serializer.fromJson<String>(json['id']),
      hlcMillis: serializer.fromJson<BigInt>(json['hlcMillis']),
      hlcCounter: serializer.fromJson<int>(json['hlcCounter']),
      hlcNodeId: serializer.fromJson<String>(json['hlcNodeId']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      mealSlot: $MealEntryTableTable.$convertermealSlot.fromJson(
        serializer.fromJson<String>(json['mealSlot']),
      ),
      foodRef: serializer.fromJson<String>(json['foodRef']),
      foodRefSource: serializer.fromJson<String>(json['foodRefSource']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unit: $MealEntryTableTable.$converterunit.fromJson(
        serializer.fromJson<String>(json['unit']),
      ),
      productNameSnapshot: serializer.fromJson<String>(
        json['productNameSnapshot'],
      ),
      brandSnapshot: serializer.fromJson<String?>(json['brandSnapshot']),
      calories100gSnapshot: serializer.fromJson<double?>(
        json['calories100gSnapshot'],
      ),
      protein100gSnapshot: serializer.fromJson<double?>(
        json['protein100gSnapshot'],
      ),
      carbs100gSnapshot: serializer.fromJson<double?>(
        json['carbs100gSnapshot'],
      ),
      fat100gSnapshot: serializer.fromJson<double?>(json['fat100gSnapshot']),
      sugar100gSnapshot: serializer.fromJson<double?>(
        json['sugar100gSnapshot'],
      ),
      fiber100gSnapshot: serializer.fromJson<double?>(
        json['fiber100gSnapshot'],
      ),
      saltSnapshot: serializer.fromJson<double?>(json['saltSnapshot']),
      co2e100gSnapshot: serializer.fromJson<double?>(json['co2e100gSnapshot']),
      confidenceBandSnapshot: serializer.fromJson<String?>(
        json['confidenceBandSnapshot'],
      ),
      co2MethodologyVersionSnapshot: serializer.fromJson<String?>(
        json['co2MethodologyVersionSnapshot'],
      ),
      loggedAt: serializer.fromJson<DateTime>(json['loggedAt']),
      logDate: serializer.fromJson<String>(json['logDate']),
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
      'mealSlot': serializer.toJson<String>(
        $MealEntryTableTable.$convertermealSlot.toJson(mealSlot),
      ),
      'foodRef': serializer.toJson<String>(foodRef),
      'foodRefSource': serializer.toJson<String>(foodRefSource),
      'quantity': serializer.toJson<double>(quantity),
      'unit': serializer.toJson<String>(
        $MealEntryTableTable.$converterunit.toJson(unit),
      ),
      'productNameSnapshot': serializer.toJson<String>(productNameSnapshot),
      'brandSnapshot': serializer.toJson<String?>(brandSnapshot),
      'calories100gSnapshot': serializer.toJson<double?>(calories100gSnapshot),
      'protein100gSnapshot': serializer.toJson<double?>(protein100gSnapshot),
      'carbs100gSnapshot': serializer.toJson<double?>(carbs100gSnapshot),
      'fat100gSnapshot': serializer.toJson<double?>(fat100gSnapshot),
      'sugar100gSnapshot': serializer.toJson<double?>(sugar100gSnapshot),
      'fiber100gSnapshot': serializer.toJson<double?>(fiber100gSnapshot),
      'saltSnapshot': serializer.toJson<double?>(saltSnapshot),
      'co2e100gSnapshot': serializer.toJson<double?>(co2e100gSnapshot),
      'confidenceBandSnapshot': serializer.toJson<String?>(
        confidenceBandSnapshot,
      ),
      'co2MethodologyVersionSnapshot': serializer.toJson<String?>(
        co2MethodologyVersionSnapshot,
      ),
      'loggedAt': serializer.toJson<DateTime>(loggedAt),
      'logDate': serializer.toJson<String>(logDate),
    };
  }

  MealEntryRow copyWith({
    String? id,
    BigInt? hlcMillis,
    int? hlcCounter,
    String? hlcNodeId,
    bool? dirty,
    Value<DateTime?> deletedAt = const Value.absent(),
    MealSlot? mealSlot,
    String? foodRef,
    String? foodRefSource,
    double? quantity,
    PortionUnit? unit,
    String? productNameSnapshot,
    Value<String?> brandSnapshot = const Value.absent(),
    Value<double?> calories100gSnapshot = const Value.absent(),
    Value<double?> protein100gSnapshot = const Value.absent(),
    Value<double?> carbs100gSnapshot = const Value.absent(),
    Value<double?> fat100gSnapshot = const Value.absent(),
    Value<double?> sugar100gSnapshot = const Value.absent(),
    Value<double?> fiber100gSnapshot = const Value.absent(),
    Value<double?> saltSnapshot = const Value.absent(),
    Value<double?> co2e100gSnapshot = const Value.absent(),
    Value<String?> confidenceBandSnapshot = const Value.absent(),
    Value<String?> co2MethodologyVersionSnapshot = const Value.absent(),
    DateTime? loggedAt,
    String? logDate,
  }) => MealEntryRow(
    id: id ?? this.id,
    hlcMillis: hlcMillis ?? this.hlcMillis,
    hlcCounter: hlcCounter ?? this.hlcCounter,
    hlcNodeId: hlcNodeId ?? this.hlcNodeId,
    dirty: dirty ?? this.dirty,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    mealSlot: mealSlot ?? this.mealSlot,
    foodRef: foodRef ?? this.foodRef,
    foodRefSource: foodRefSource ?? this.foodRefSource,
    quantity: quantity ?? this.quantity,
    unit: unit ?? this.unit,
    productNameSnapshot: productNameSnapshot ?? this.productNameSnapshot,
    brandSnapshot: brandSnapshot.present
        ? brandSnapshot.value
        : this.brandSnapshot,
    calories100gSnapshot: calories100gSnapshot.present
        ? calories100gSnapshot.value
        : this.calories100gSnapshot,
    protein100gSnapshot: protein100gSnapshot.present
        ? protein100gSnapshot.value
        : this.protein100gSnapshot,
    carbs100gSnapshot: carbs100gSnapshot.present
        ? carbs100gSnapshot.value
        : this.carbs100gSnapshot,
    fat100gSnapshot: fat100gSnapshot.present
        ? fat100gSnapshot.value
        : this.fat100gSnapshot,
    sugar100gSnapshot: sugar100gSnapshot.present
        ? sugar100gSnapshot.value
        : this.sugar100gSnapshot,
    fiber100gSnapshot: fiber100gSnapshot.present
        ? fiber100gSnapshot.value
        : this.fiber100gSnapshot,
    saltSnapshot: saltSnapshot.present ? saltSnapshot.value : this.saltSnapshot,
    co2e100gSnapshot: co2e100gSnapshot.present
        ? co2e100gSnapshot.value
        : this.co2e100gSnapshot,
    confidenceBandSnapshot: confidenceBandSnapshot.present
        ? confidenceBandSnapshot.value
        : this.confidenceBandSnapshot,
    co2MethodologyVersionSnapshot: co2MethodologyVersionSnapshot.present
        ? co2MethodologyVersionSnapshot.value
        : this.co2MethodologyVersionSnapshot,
    loggedAt: loggedAt ?? this.loggedAt,
    logDate: logDate ?? this.logDate,
  );
  MealEntryRow copyWithCompanion(MealEntryTableCompanion data) {
    return MealEntryRow(
      id: data.id.present ? data.id.value : this.id,
      hlcMillis: data.hlcMillis.present ? data.hlcMillis.value : this.hlcMillis,
      hlcCounter: data.hlcCounter.present
          ? data.hlcCounter.value
          : this.hlcCounter,
      hlcNodeId: data.hlcNodeId.present ? data.hlcNodeId.value : this.hlcNodeId,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      mealSlot: data.mealSlot.present ? data.mealSlot.value : this.mealSlot,
      foodRef: data.foodRef.present ? data.foodRef.value : this.foodRef,
      foodRefSource: data.foodRefSource.present
          ? data.foodRefSource.value
          : this.foodRefSource,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      productNameSnapshot: data.productNameSnapshot.present
          ? data.productNameSnapshot.value
          : this.productNameSnapshot,
      brandSnapshot: data.brandSnapshot.present
          ? data.brandSnapshot.value
          : this.brandSnapshot,
      calories100gSnapshot: data.calories100gSnapshot.present
          ? data.calories100gSnapshot.value
          : this.calories100gSnapshot,
      protein100gSnapshot: data.protein100gSnapshot.present
          ? data.protein100gSnapshot.value
          : this.protein100gSnapshot,
      carbs100gSnapshot: data.carbs100gSnapshot.present
          ? data.carbs100gSnapshot.value
          : this.carbs100gSnapshot,
      fat100gSnapshot: data.fat100gSnapshot.present
          ? data.fat100gSnapshot.value
          : this.fat100gSnapshot,
      sugar100gSnapshot: data.sugar100gSnapshot.present
          ? data.sugar100gSnapshot.value
          : this.sugar100gSnapshot,
      fiber100gSnapshot: data.fiber100gSnapshot.present
          ? data.fiber100gSnapshot.value
          : this.fiber100gSnapshot,
      saltSnapshot: data.saltSnapshot.present
          ? data.saltSnapshot.value
          : this.saltSnapshot,
      co2e100gSnapshot: data.co2e100gSnapshot.present
          ? data.co2e100gSnapshot.value
          : this.co2e100gSnapshot,
      confidenceBandSnapshot: data.confidenceBandSnapshot.present
          ? data.confidenceBandSnapshot.value
          : this.confidenceBandSnapshot,
      co2MethodologyVersionSnapshot: data.co2MethodologyVersionSnapshot.present
          ? data.co2MethodologyVersionSnapshot.value
          : this.co2MethodologyVersionSnapshot,
      loggedAt: data.loggedAt.present ? data.loggedAt.value : this.loggedAt,
      logDate: data.logDate.present ? data.logDate.value : this.logDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MealEntryRow(')
          ..write('id: $id, ')
          ..write('hlcMillis: $hlcMillis, ')
          ..write('hlcCounter: $hlcCounter, ')
          ..write('hlcNodeId: $hlcNodeId, ')
          ..write('dirty: $dirty, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('mealSlot: $mealSlot, ')
          ..write('foodRef: $foodRef, ')
          ..write('foodRefSource: $foodRefSource, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('productNameSnapshot: $productNameSnapshot, ')
          ..write('brandSnapshot: $brandSnapshot, ')
          ..write('calories100gSnapshot: $calories100gSnapshot, ')
          ..write('protein100gSnapshot: $protein100gSnapshot, ')
          ..write('carbs100gSnapshot: $carbs100gSnapshot, ')
          ..write('fat100gSnapshot: $fat100gSnapshot, ')
          ..write('sugar100gSnapshot: $sugar100gSnapshot, ')
          ..write('fiber100gSnapshot: $fiber100gSnapshot, ')
          ..write('saltSnapshot: $saltSnapshot, ')
          ..write('co2e100gSnapshot: $co2e100gSnapshot, ')
          ..write('confidenceBandSnapshot: $confidenceBandSnapshot, ')
          ..write(
            'co2MethodologyVersionSnapshot: $co2MethodologyVersionSnapshot, ',
          )
          ..write('loggedAt: $loggedAt, ')
          ..write('logDate: $logDate')
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
    mealSlot,
    foodRef,
    foodRefSource,
    quantity,
    unit,
    productNameSnapshot,
    brandSnapshot,
    calories100gSnapshot,
    protein100gSnapshot,
    carbs100gSnapshot,
    fat100gSnapshot,
    sugar100gSnapshot,
    fiber100gSnapshot,
    saltSnapshot,
    co2e100gSnapshot,
    confidenceBandSnapshot,
    co2MethodologyVersionSnapshot,
    loggedAt,
    logDate,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MealEntryRow &&
          other.id == this.id &&
          other.hlcMillis == this.hlcMillis &&
          other.hlcCounter == this.hlcCounter &&
          other.hlcNodeId == this.hlcNodeId &&
          other.dirty == this.dirty &&
          other.deletedAt == this.deletedAt &&
          other.mealSlot == this.mealSlot &&
          other.foodRef == this.foodRef &&
          other.foodRefSource == this.foodRefSource &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.productNameSnapshot == this.productNameSnapshot &&
          other.brandSnapshot == this.brandSnapshot &&
          other.calories100gSnapshot == this.calories100gSnapshot &&
          other.protein100gSnapshot == this.protein100gSnapshot &&
          other.carbs100gSnapshot == this.carbs100gSnapshot &&
          other.fat100gSnapshot == this.fat100gSnapshot &&
          other.sugar100gSnapshot == this.sugar100gSnapshot &&
          other.fiber100gSnapshot == this.fiber100gSnapshot &&
          other.saltSnapshot == this.saltSnapshot &&
          other.co2e100gSnapshot == this.co2e100gSnapshot &&
          other.confidenceBandSnapshot == this.confidenceBandSnapshot &&
          other.co2MethodologyVersionSnapshot ==
              this.co2MethodologyVersionSnapshot &&
          other.loggedAt == this.loggedAt &&
          other.logDate == this.logDate);
}

class MealEntryTableCompanion extends UpdateCompanion<MealEntryRow> {
  final Value<String> id;
  final Value<BigInt> hlcMillis;
  final Value<int> hlcCounter;
  final Value<String> hlcNodeId;
  final Value<bool> dirty;
  final Value<DateTime?> deletedAt;
  final Value<MealSlot> mealSlot;
  final Value<String> foodRef;
  final Value<String> foodRefSource;
  final Value<double> quantity;
  final Value<PortionUnit> unit;
  final Value<String> productNameSnapshot;
  final Value<String?> brandSnapshot;
  final Value<double?> calories100gSnapshot;
  final Value<double?> protein100gSnapshot;
  final Value<double?> carbs100gSnapshot;
  final Value<double?> fat100gSnapshot;
  final Value<double?> sugar100gSnapshot;
  final Value<double?> fiber100gSnapshot;
  final Value<double?> saltSnapshot;
  final Value<double?> co2e100gSnapshot;
  final Value<String?> confidenceBandSnapshot;
  final Value<String?> co2MethodologyVersionSnapshot;
  final Value<DateTime> loggedAt;
  final Value<String> logDate;
  final Value<int> rowid;
  const MealEntryTableCompanion({
    this.id = const Value.absent(),
    this.hlcMillis = const Value.absent(),
    this.hlcCounter = const Value.absent(),
    this.hlcNodeId = const Value.absent(),
    this.dirty = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.mealSlot = const Value.absent(),
    this.foodRef = const Value.absent(),
    this.foodRefSource = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.productNameSnapshot = const Value.absent(),
    this.brandSnapshot = const Value.absent(),
    this.calories100gSnapshot = const Value.absent(),
    this.protein100gSnapshot = const Value.absent(),
    this.carbs100gSnapshot = const Value.absent(),
    this.fat100gSnapshot = const Value.absent(),
    this.sugar100gSnapshot = const Value.absent(),
    this.fiber100gSnapshot = const Value.absent(),
    this.saltSnapshot = const Value.absent(),
    this.co2e100gSnapshot = const Value.absent(),
    this.confidenceBandSnapshot = const Value.absent(),
    this.co2MethodologyVersionSnapshot = const Value.absent(),
    this.loggedAt = const Value.absent(),
    this.logDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MealEntryTableCompanion.insert({
    required String id,
    required BigInt hlcMillis,
    required int hlcCounter,
    required String hlcNodeId,
    this.dirty = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required MealSlot mealSlot,
    required String foodRef,
    required String foodRefSource,
    required double quantity,
    required PortionUnit unit,
    required String productNameSnapshot,
    this.brandSnapshot = const Value.absent(),
    this.calories100gSnapshot = const Value.absent(),
    this.protein100gSnapshot = const Value.absent(),
    this.carbs100gSnapshot = const Value.absent(),
    this.fat100gSnapshot = const Value.absent(),
    this.sugar100gSnapshot = const Value.absent(),
    this.fiber100gSnapshot = const Value.absent(),
    this.saltSnapshot = const Value.absent(),
    this.co2e100gSnapshot = const Value.absent(),
    this.confidenceBandSnapshot = const Value.absent(),
    this.co2MethodologyVersionSnapshot = const Value.absent(),
    required DateTime loggedAt,
    required String logDate,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       hlcMillis = Value(hlcMillis),
       hlcCounter = Value(hlcCounter),
       hlcNodeId = Value(hlcNodeId),
       mealSlot = Value(mealSlot),
       foodRef = Value(foodRef),
       foodRefSource = Value(foodRefSource),
       quantity = Value(quantity),
       unit = Value(unit),
       productNameSnapshot = Value(productNameSnapshot),
       loggedAt = Value(loggedAt),
       logDate = Value(logDate);
  static Insertable<MealEntryRow> custom({
    Expression<String>? id,
    Expression<BigInt>? hlcMillis,
    Expression<int>? hlcCounter,
    Expression<String>? hlcNodeId,
    Expression<bool>? dirty,
    Expression<DateTime>? deletedAt,
    Expression<String>? mealSlot,
    Expression<String>? foodRef,
    Expression<String>? foodRefSource,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<String>? productNameSnapshot,
    Expression<String>? brandSnapshot,
    Expression<double>? calories100gSnapshot,
    Expression<double>? protein100gSnapshot,
    Expression<double>? carbs100gSnapshot,
    Expression<double>? fat100gSnapshot,
    Expression<double>? sugar100gSnapshot,
    Expression<double>? fiber100gSnapshot,
    Expression<double>? saltSnapshot,
    Expression<double>? co2e100gSnapshot,
    Expression<String>? confidenceBandSnapshot,
    Expression<String>? co2MethodologyVersionSnapshot,
    Expression<DateTime>? loggedAt,
    Expression<String>? logDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hlcMillis != null) 'hlc_millis': hlcMillis,
      if (hlcCounter != null) 'hlc_counter': hlcCounter,
      if (hlcNodeId != null) 'hlc_node_id': hlcNodeId,
      if (dirty != null) 'dirty': dirty,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (mealSlot != null) 'meal_slot': mealSlot,
      if (foodRef != null) 'food_ref': foodRef,
      if (foodRefSource != null) 'food_ref_source': foodRefSource,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (productNameSnapshot != null)
        'product_name_snapshot': productNameSnapshot,
      if (brandSnapshot != null) 'brand_snapshot': brandSnapshot,
      if (calories100gSnapshot != null)
        'calories100g_snapshot': calories100gSnapshot,
      if (protein100gSnapshot != null)
        'protein100g_snapshot': protein100gSnapshot,
      if (carbs100gSnapshot != null) 'carbs100g_snapshot': carbs100gSnapshot,
      if (fat100gSnapshot != null) 'fat100g_snapshot': fat100gSnapshot,
      if (sugar100gSnapshot != null) 'sugar100g_snapshot': sugar100gSnapshot,
      if (fiber100gSnapshot != null) 'fiber100g_snapshot': fiber100gSnapshot,
      if (saltSnapshot != null) 'salt_snapshot': saltSnapshot,
      if (co2e100gSnapshot != null) 'co2e100g_snapshot': co2e100gSnapshot,
      if (confidenceBandSnapshot != null)
        'confidence_band_snapshot': confidenceBandSnapshot,
      if (co2MethodologyVersionSnapshot != null)
        'co2_methodology_version_snapshot': co2MethodologyVersionSnapshot,
      if (loggedAt != null) 'logged_at': loggedAt,
      if (logDate != null) 'log_date': logDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MealEntryTableCompanion copyWith({
    Value<String>? id,
    Value<BigInt>? hlcMillis,
    Value<int>? hlcCounter,
    Value<String>? hlcNodeId,
    Value<bool>? dirty,
    Value<DateTime?>? deletedAt,
    Value<MealSlot>? mealSlot,
    Value<String>? foodRef,
    Value<String>? foodRefSource,
    Value<double>? quantity,
    Value<PortionUnit>? unit,
    Value<String>? productNameSnapshot,
    Value<String?>? brandSnapshot,
    Value<double?>? calories100gSnapshot,
    Value<double?>? protein100gSnapshot,
    Value<double?>? carbs100gSnapshot,
    Value<double?>? fat100gSnapshot,
    Value<double?>? sugar100gSnapshot,
    Value<double?>? fiber100gSnapshot,
    Value<double?>? saltSnapshot,
    Value<double?>? co2e100gSnapshot,
    Value<String?>? confidenceBandSnapshot,
    Value<String?>? co2MethodologyVersionSnapshot,
    Value<DateTime>? loggedAt,
    Value<String>? logDate,
    Value<int>? rowid,
  }) {
    return MealEntryTableCompanion(
      id: id ?? this.id,
      hlcMillis: hlcMillis ?? this.hlcMillis,
      hlcCounter: hlcCounter ?? this.hlcCounter,
      hlcNodeId: hlcNodeId ?? this.hlcNodeId,
      dirty: dirty ?? this.dirty,
      deletedAt: deletedAt ?? this.deletedAt,
      mealSlot: mealSlot ?? this.mealSlot,
      foodRef: foodRef ?? this.foodRef,
      foodRefSource: foodRefSource ?? this.foodRefSource,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      productNameSnapshot: productNameSnapshot ?? this.productNameSnapshot,
      brandSnapshot: brandSnapshot ?? this.brandSnapshot,
      calories100gSnapshot: calories100gSnapshot ?? this.calories100gSnapshot,
      protein100gSnapshot: protein100gSnapshot ?? this.protein100gSnapshot,
      carbs100gSnapshot: carbs100gSnapshot ?? this.carbs100gSnapshot,
      fat100gSnapshot: fat100gSnapshot ?? this.fat100gSnapshot,
      sugar100gSnapshot: sugar100gSnapshot ?? this.sugar100gSnapshot,
      fiber100gSnapshot: fiber100gSnapshot ?? this.fiber100gSnapshot,
      saltSnapshot: saltSnapshot ?? this.saltSnapshot,
      co2e100gSnapshot: co2e100gSnapshot ?? this.co2e100gSnapshot,
      confidenceBandSnapshot:
          confidenceBandSnapshot ?? this.confidenceBandSnapshot,
      co2MethodologyVersionSnapshot:
          co2MethodologyVersionSnapshot ?? this.co2MethodologyVersionSnapshot,
      loggedAt: loggedAt ?? this.loggedAt,
      logDate: logDate ?? this.logDate,
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
    if (mealSlot.present) {
      map['meal_slot'] = Variable<String>(
        $MealEntryTableTable.$convertermealSlot.toSql(mealSlot.value),
      );
    }
    if (foodRef.present) {
      map['food_ref'] = Variable<String>(foodRef.value);
    }
    if (foodRefSource.present) {
      map['food_ref_source'] = Variable<String>(foodRefSource.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(
        $MealEntryTableTable.$converterunit.toSql(unit.value),
      );
    }
    if (productNameSnapshot.present) {
      map['product_name_snapshot'] = Variable<String>(
        productNameSnapshot.value,
      );
    }
    if (brandSnapshot.present) {
      map['brand_snapshot'] = Variable<String>(brandSnapshot.value);
    }
    if (calories100gSnapshot.present) {
      map['calories100g_snapshot'] = Variable<double>(
        calories100gSnapshot.value,
      );
    }
    if (protein100gSnapshot.present) {
      map['protein100g_snapshot'] = Variable<double>(protein100gSnapshot.value);
    }
    if (carbs100gSnapshot.present) {
      map['carbs100g_snapshot'] = Variable<double>(carbs100gSnapshot.value);
    }
    if (fat100gSnapshot.present) {
      map['fat100g_snapshot'] = Variable<double>(fat100gSnapshot.value);
    }
    if (sugar100gSnapshot.present) {
      map['sugar100g_snapshot'] = Variable<double>(sugar100gSnapshot.value);
    }
    if (fiber100gSnapshot.present) {
      map['fiber100g_snapshot'] = Variable<double>(fiber100gSnapshot.value);
    }
    if (saltSnapshot.present) {
      map['salt_snapshot'] = Variable<double>(saltSnapshot.value);
    }
    if (co2e100gSnapshot.present) {
      map['co2e100g_snapshot'] = Variable<double>(co2e100gSnapshot.value);
    }
    if (confidenceBandSnapshot.present) {
      map['confidence_band_snapshot'] = Variable<String>(
        confidenceBandSnapshot.value,
      );
    }
    if (co2MethodologyVersionSnapshot.present) {
      map['co2_methodology_version_snapshot'] = Variable<String>(
        co2MethodologyVersionSnapshot.value,
      );
    }
    if (loggedAt.present) {
      map['logged_at'] = Variable<DateTime>(loggedAt.value);
    }
    if (logDate.present) {
      map['log_date'] = Variable<String>(logDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MealEntryTableCompanion(')
          ..write('id: $id, ')
          ..write('hlcMillis: $hlcMillis, ')
          ..write('hlcCounter: $hlcCounter, ')
          ..write('hlcNodeId: $hlcNodeId, ')
          ..write('dirty: $dirty, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('mealSlot: $mealSlot, ')
          ..write('foodRef: $foodRef, ')
          ..write('foodRefSource: $foodRefSource, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('productNameSnapshot: $productNameSnapshot, ')
          ..write('brandSnapshot: $brandSnapshot, ')
          ..write('calories100gSnapshot: $calories100gSnapshot, ')
          ..write('protein100gSnapshot: $protein100gSnapshot, ')
          ..write('carbs100gSnapshot: $carbs100gSnapshot, ')
          ..write('fat100gSnapshot: $fat100gSnapshot, ')
          ..write('sugar100gSnapshot: $sugar100gSnapshot, ')
          ..write('fiber100gSnapshot: $fiber100gSnapshot, ')
          ..write('saltSnapshot: $saltSnapshot, ')
          ..write('co2e100gSnapshot: $co2e100gSnapshot, ')
          ..write('confidenceBandSnapshot: $confidenceBandSnapshot, ')
          ..write(
            'co2MethodologyVersionSnapshot: $co2MethodologyVersionSnapshot, ',
          )
          ..write('loggedAt: $loggedAt, ')
          ..write('logDate: $logDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FavoriteTableTable extends FavoriteTable
    with TableInfo<$FavoriteTableTable, FavoriteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoriteTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _foodRefMeta = const VerificationMeta(
    'foodRef',
  );
  @override
  late final GeneratedColumn<String> foodRef = GeneratedColumn<String>(
    'food_ref',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foodRefSourceMeta = const VerificationMeta(
    'foodRefSource',
  );
  @override
  late final GeneratedColumn<String> foodRefSource = GeneratedColumn<String>(
    'food_ref_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productNameSnapshotMeta =
      const VerificationMeta('productNameSnapshot');
  @override
  late final GeneratedColumn<String> productNameSnapshot =
      GeneratedColumn<String>(
        'product_name_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _brandSnapshotMeta = const VerificationMeta(
    'brandSnapshot',
  );
  @override
  late final GeneratedColumn<String> brandSnapshot = GeneratedColumn<String>(
    'brand_snapshot',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _calories100gSnapshotMeta =
      const VerificationMeta('calories100gSnapshot');
  @override
  late final GeneratedColumn<double> calories100gSnapshot =
      GeneratedColumn<double>(
        'calories100g_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _co2e100gSnapshotMeta = const VerificationMeta(
    'co2e100gSnapshot',
  );
  @override
  late final GeneratedColumn<double> co2e100gSnapshot = GeneratedColumn<double>(
    'co2e100g_snapshot',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confidenceBandSnapshotMeta =
      const VerificationMeta('confidenceBandSnapshot');
  @override
  late final GeneratedColumn<String> confidenceBandSnapshot =
      GeneratedColumn<String>(
        'confidence_band_snapshot',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastQuantityMeta = const VerificationMeta(
    'lastQuantity',
  );
  @override
  late final GeneratedColumn<double> lastQuantity = GeneratedColumn<double>(
    'last_quantity',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PortionUnit?, String> lastUnit =
      GeneratedColumn<String>(
        'last_unit',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<PortionUnit?>($FavoriteTableTable.$converterlastUnitn);
  static const VerificationMeta _favoritedAtMeta = const VerificationMeta(
    'favoritedAt',
  );
  @override
  late final GeneratedColumn<DateTime> favoritedAt = GeneratedColumn<DateTime>(
    'favorited_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    hlcMillis,
    hlcCounter,
    hlcNodeId,
    dirty,
    deletedAt,
    foodRef,
    foodRefSource,
    productNameSnapshot,
    brandSnapshot,
    calories100gSnapshot,
    co2e100gSnapshot,
    confidenceBandSnapshot,
    lastQuantity,
    lastUnit,
    favoritedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorite_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteRow> instance, {
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
    if (data.containsKey('food_ref')) {
      context.handle(
        _foodRefMeta,
        foodRef.isAcceptableOrUnknown(data['food_ref']!, _foodRefMeta),
      );
    } else if (isInserting) {
      context.missing(_foodRefMeta);
    }
    if (data.containsKey('food_ref_source')) {
      context.handle(
        _foodRefSourceMeta,
        foodRefSource.isAcceptableOrUnknown(
          data['food_ref_source']!,
          _foodRefSourceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_foodRefSourceMeta);
    }
    if (data.containsKey('product_name_snapshot')) {
      context.handle(
        _productNameSnapshotMeta,
        productNameSnapshot.isAcceptableOrUnknown(
          data['product_name_snapshot']!,
          _productNameSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameSnapshotMeta);
    }
    if (data.containsKey('brand_snapshot')) {
      context.handle(
        _brandSnapshotMeta,
        brandSnapshot.isAcceptableOrUnknown(
          data['brand_snapshot']!,
          _brandSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('calories100g_snapshot')) {
      context.handle(
        _calories100gSnapshotMeta,
        calories100gSnapshot.isAcceptableOrUnknown(
          data['calories100g_snapshot']!,
          _calories100gSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('co2e100g_snapshot')) {
      context.handle(
        _co2e100gSnapshotMeta,
        co2e100gSnapshot.isAcceptableOrUnknown(
          data['co2e100g_snapshot']!,
          _co2e100gSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('confidence_band_snapshot')) {
      context.handle(
        _confidenceBandSnapshotMeta,
        confidenceBandSnapshot.isAcceptableOrUnknown(
          data['confidence_band_snapshot']!,
          _confidenceBandSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('last_quantity')) {
      context.handle(
        _lastQuantityMeta,
        lastQuantity.isAcceptableOrUnknown(
          data['last_quantity']!,
          _lastQuantityMeta,
        ),
      );
    }
    if (data.containsKey('favorited_at')) {
      context.handle(
        _favoritedAtMeta,
        favoritedAt.isAcceptableOrUnknown(
          data['favorited_at']!,
          _favoritedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_favoritedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FavoriteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteRow(
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
      foodRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_ref'],
      )!,
      foodRefSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_ref_source'],
      )!,
      productNameSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name_snapshot'],
      )!,
      brandSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand_snapshot'],
      ),
      calories100gSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories100g_snapshot'],
      ),
      co2e100gSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}co2e100g_snapshot'],
      ),
      confidenceBandSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}confidence_band_snapshot'],
      ),
      lastQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}last_quantity'],
      ),
      lastUnit: $FavoriteTableTable.$converterlastUnitn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}last_unit'],
        ),
      ),
      favoritedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}favorited_at'],
      )!,
    );
  }

  @override
  $FavoriteTableTable createAlias(String alias) {
    return $FavoriteTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PortionUnit, String, String> $converterlastUnit =
      const EnumNameConverter<PortionUnit>(PortionUnit.values);
  static JsonTypeConverter2<PortionUnit?, String?, String?>
  $converterlastUnitn = JsonTypeConverter2.asNullable($converterlastUnit);
}

class FavoriteRow extends DataClass implements Insertable<FavoriteRow> {
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

  /// Reference to the source food: a barcode (off_ref/user_food_cache) or
  /// a `UserFoodTable.id` (user_foods). Never a Drift `.references()` FK
  /// (RESEARCH.md Pitfall 1 — cross-attached-DB FK is impossible).
  final String foodRef;

  /// One of `'off_ref'`, `'user_food_cache'`, `'user_foods'` — identifies
  /// which table/database [foodRef] resolves against.
  final String foodRefSource;

  /// Product name captured when favorited.
  final String productNameSnapshot;

  /// Brand captured when favorited, nullable.
  final String? brandSnapshot;

  /// Energy in kcal per 100 g/ml, captured when favorited.
  final double? calories100gSnapshot;

  /// kg CO2e per kg product, captured when favorited.
  final double? co2e100gSnapshot;

  /// Confidence band ('high'/'medium'/'low'), captured when favorited.
  final String? confidenceBandSnapshot;

  /// Last quantity logged via the one-tap path from this favorite, in
  /// [lastUnit]. Null until the favorite has been logged at least once
  /// via the one-tap path; falls back to a generic default (100g) when
  /// null.
  final double? lastQuantity;

  /// Unit of [lastQuantity], nullable until logged at least once.
  final PortionUnit? lastUnit;

  /// Wall-clock timestamp of when the food was favorited.
  final DateTime favoritedAt;
  const FavoriteRow({
    required this.id,
    required this.hlcMillis,
    required this.hlcCounter,
    required this.hlcNodeId,
    required this.dirty,
    this.deletedAt,
    required this.foodRef,
    required this.foodRefSource,
    required this.productNameSnapshot,
    this.brandSnapshot,
    this.calories100gSnapshot,
    this.co2e100gSnapshot,
    this.confidenceBandSnapshot,
    this.lastQuantity,
    this.lastUnit,
    required this.favoritedAt,
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
    map['food_ref'] = Variable<String>(foodRef);
    map['food_ref_source'] = Variable<String>(foodRefSource);
    map['product_name_snapshot'] = Variable<String>(productNameSnapshot);
    if (!nullToAbsent || brandSnapshot != null) {
      map['brand_snapshot'] = Variable<String>(brandSnapshot);
    }
    if (!nullToAbsent || calories100gSnapshot != null) {
      map['calories100g_snapshot'] = Variable<double>(calories100gSnapshot);
    }
    if (!nullToAbsent || co2e100gSnapshot != null) {
      map['co2e100g_snapshot'] = Variable<double>(co2e100gSnapshot);
    }
    if (!nullToAbsent || confidenceBandSnapshot != null) {
      map['confidence_band_snapshot'] = Variable<String>(
        confidenceBandSnapshot,
      );
    }
    if (!nullToAbsent || lastQuantity != null) {
      map['last_quantity'] = Variable<double>(lastQuantity);
    }
    if (!nullToAbsent || lastUnit != null) {
      map['last_unit'] = Variable<String>(
        $FavoriteTableTable.$converterlastUnitn.toSql(lastUnit),
      );
    }
    map['favorited_at'] = Variable<DateTime>(favoritedAt);
    return map;
  }

  FavoriteTableCompanion toCompanion(bool nullToAbsent) {
    return FavoriteTableCompanion(
      id: Value(id),
      hlcMillis: Value(hlcMillis),
      hlcCounter: Value(hlcCounter),
      hlcNodeId: Value(hlcNodeId),
      dirty: Value(dirty),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      foodRef: Value(foodRef),
      foodRefSource: Value(foodRefSource),
      productNameSnapshot: Value(productNameSnapshot),
      brandSnapshot: brandSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(brandSnapshot),
      calories100gSnapshot: calories100gSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(calories100gSnapshot),
      co2e100gSnapshot: co2e100gSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(co2e100gSnapshot),
      confidenceBandSnapshot: confidenceBandSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(confidenceBandSnapshot),
      lastQuantity: lastQuantity == null && nullToAbsent
          ? const Value.absent()
          : Value(lastQuantity),
      lastUnit: lastUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUnit),
      favoritedAt: Value(favoritedAt),
    );
  }

  factory FavoriteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteRow(
      id: serializer.fromJson<String>(json['id']),
      hlcMillis: serializer.fromJson<BigInt>(json['hlcMillis']),
      hlcCounter: serializer.fromJson<int>(json['hlcCounter']),
      hlcNodeId: serializer.fromJson<String>(json['hlcNodeId']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      foodRef: serializer.fromJson<String>(json['foodRef']),
      foodRefSource: serializer.fromJson<String>(json['foodRefSource']),
      productNameSnapshot: serializer.fromJson<String>(
        json['productNameSnapshot'],
      ),
      brandSnapshot: serializer.fromJson<String?>(json['brandSnapshot']),
      calories100gSnapshot: serializer.fromJson<double?>(
        json['calories100gSnapshot'],
      ),
      co2e100gSnapshot: serializer.fromJson<double?>(json['co2e100gSnapshot']),
      confidenceBandSnapshot: serializer.fromJson<String?>(
        json['confidenceBandSnapshot'],
      ),
      lastQuantity: serializer.fromJson<double?>(json['lastQuantity']),
      lastUnit: $FavoriteTableTable.$converterlastUnitn.fromJson(
        serializer.fromJson<String?>(json['lastUnit']),
      ),
      favoritedAt: serializer.fromJson<DateTime>(json['favoritedAt']),
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
      'foodRef': serializer.toJson<String>(foodRef),
      'foodRefSource': serializer.toJson<String>(foodRefSource),
      'productNameSnapshot': serializer.toJson<String>(productNameSnapshot),
      'brandSnapshot': serializer.toJson<String?>(brandSnapshot),
      'calories100gSnapshot': serializer.toJson<double?>(calories100gSnapshot),
      'co2e100gSnapshot': serializer.toJson<double?>(co2e100gSnapshot),
      'confidenceBandSnapshot': serializer.toJson<String?>(
        confidenceBandSnapshot,
      ),
      'lastQuantity': serializer.toJson<double?>(lastQuantity),
      'lastUnit': serializer.toJson<String?>(
        $FavoriteTableTable.$converterlastUnitn.toJson(lastUnit),
      ),
      'favoritedAt': serializer.toJson<DateTime>(favoritedAt),
    };
  }

  FavoriteRow copyWith({
    String? id,
    BigInt? hlcMillis,
    int? hlcCounter,
    String? hlcNodeId,
    bool? dirty,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? foodRef,
    String? foodRefSource,
    String? productNameSnapshot,
    Value<String?> brandSnapshot = const Value.absent(),
    Value<double?> calories100gSnapshot = const Value.absent(),
    Value<double?> co2e100gSnapshot = const Value.absent(),
    Value<String?> confidenceBandSnapshot = const Value.absent(),
    Value<double?> lastQuantity = const Value.absent(),
    Value<PortionUnit?> lastUnit = const Value.absent(),
    DateTime? favoritedAt,
  }) => FavoriteRow(
    id: id ?? this.id,
    hlcMillis: hlcMillis ?? this.hlcMillis,
    hlcCounter: hlcCounter ?? this.hlcCounter,
    hlcNodeId: hlcNodeId ?? this.hlcNodeId,
    dirty: dirty ?? this.dirty,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    foodRef: foodRef ?? this.foodRef,
    foodRefSource: foodRefSource ?? this.foodRefSource,
    productNameSnapshot: productNameSnapshot ?? this.productNameSnapshot,
    brandSnapshot: brandSnapshot.present
        ? brandSnapshot.value
        : this.brandSnapshot,
    calories100gSnapshot: calories100gSnapshot.present
        ? calories100gSnapshot.value
        : this.calories100gSnapshot,
    co2e100gSnapshot: co2e100gSnapshot.present
        ? co2e100gSnapshot.value
        : this.co2e100gSnapshot,
    confidenceBandSnapshot: confidenceBandSnapshot.present
        ? confidenceBandSnapshot.value
        : this.confidenceBandSnapshot,
    lastQuantity: lastQuantity.present ? lastQuantity.value : this.lastQuantity,
    lastUnit: lastUnit.present ? lastUnit.value : this.lastUnit,
    favoritedAt: favoritedAt ?? this.favoritedAt,
  );
  FavoriteRow copyWithCompanion(FavoriteTableCompanion data) {
    return FavoriteRow(
      id: data.id.present ? data.id.value : this.id,
      hlcMillis: data.hlcMillis.present ? data.hlcMillis.value : this.hlcMillis,
      hlcCounter: data.hlcCounter.present
          ? data.hlcCounter.value
          : this.hlcCounter,
      hlcNodeId: data.hlcNodeId.present ? data.hlcNodeId.value : this.hlcNodeId,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      foodRef: data.foodRef.present ? data.foodRef.value : this.foodRef,
      foodRefSource: data.foodRefSource.present
          ? data.foodRefSource.value
          : this.foodRefSource,
      productNameSnapshot: data.productNameSnapshot.present
          ? data.productNameSnapshot.value
          : this.productNameSnapshot,
      brandSnapshot: data.brandSnapshot.present
          ? data.brandSnapshot.value
          : this.brandSnapshot,
      calories100gSnapshot: data.calories100gSnapshot.present
          ? data.calories100gSnapshot.value
          : this.calories100gSnapshot,
      co2e100gSnapshot: data.co2e100gSnapshot.present
          ? data.co2e100gSnapshot.value
          : this.co2e100gSnapshot,
      confidenceBandSnapshot: data.confidenceBandSnapshot.present
          ? data.confidenceBandSnapshot.value
          : this.confidenceBandSnapshot,
      lastQuantity: data.lastQuantity.present
          ? data.lastQuantity.value
          : this.lastQuantity,
      lastUnit: data.lastUnit.present ? data.lastUnit.value : this.lastUnit,
      favoritedAt: data.favoritedAt.present
          ? data.favoritedAt.value
          : this.favoritedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteRow(')
          ..write('id: $id, ')
          ..write('hlcMillis: $hlcMillis, ')
          ..write('hlcCounter: $hlcCounter, ')
          ..write('hlcNodeId: $hlcNodeId, ')
          ..write('dirty: $dirty, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('foodRef: $foodRef, ')
          ..write('foodRefSource: $foodRefSource, ')
          ..write('productNameSnapshot: $productNameSnapshot, ')
          ..write('brandSnapshot: $brandSnapshot, ')
          ..write('calories100gSnapshot: $calories100gSnapshot, ')
          ..write('co2e100gSnapshot: $co2e100gSnapshot, ')
          ..write('confidenceBandSnapshot: $confidenceBandSnapshot, ')
          ..write('lastQuantity: $lastQuantity, ')
          ..write('lastUnit: $lastUnit, ')
          ..write('favoritedAt: $favoritedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    hlcMillis,
    hlcCounter,
    hlcNodeId,
    dirty,
    deletedAt,
    foodRef,
    foodRefSource,
    productNameSnapshot,
    brandSnapshot,
    calories100gSnapshot,
    co2e100gSnapshot,
    confidenceBandSnapshot,
    lastQuantity,
    lastUnit,
    favoritedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteRow &&
          other.id == this.id &&
          other.hlcMillis == this.hlcMillis &&
          other.hlcCounter == this.hlcCounter &&
          other.hlcNodeId == this.hlcNodeId &&
          other.dirty == this.dirty &&
          other.deletedAt == this.deletedAt &&
          other.foodRef == this.foodRef &&
          other.foodRefSource == this.foodRefSource &&
          other.productNameSnapshot == this.productNameSnapshot &&
          other.brandSnapshot == this.brandSnapshot &&
          other.calories100gSnapshot == this.calories100gSnapshot &&
          other.co2e100gSnapshot == this.co2e100gSnapshot &&
          other.confidenceBandSnapshot == this.confidenceBandSnapshot &&
          other.lastQuantity == this.lastQuantity &&
          other.lastUnit == this.lastUnit &&
          other.favoritedAt == this.favoritedAt);
}

class FavoriteTableCompanion extends UpdateCompanion<FavoriteRow> {
  final Value<String> id;
  final Value<BigInt> hlcMillis;
  final Value<int> hlcCounter;
  final Value<String> hlcNodeId;
  final Value<bool> dirty;
  final Value<DateTime?> deletedAt;
  final Value<String> foodRef;
  final Value<String> foodRefSource;
  final Value<String> productNameSnapshot;
  final Value<String?> brandSnapshot;
  final Value<double?> calories100gSnapshot;
  final Value<double?> co2e100gSnapshot;
  final Value<String?> confidenceBandSnapshot;
  final Value<double?> lastQuantity;
  final Value<PortionUnit?> lastUnit;
  final Value<DateTime> favoritedAt;
  final Value<int> rowid;
  const FavoriteTableCompanion({
    this.id = const Value.absent(),
    this.hlcMillis = const Value.absent(),
    this.hlcCounter = const Value.absent(),
    this.hlcNodeId = const Value.absent(),
    this.dirty = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.foodRef = const Value.absent(),
    this.foodRefSource = const Value.absent(),
    this.productNameSnapshot = const Value.absent(),
    this.brandSnapshot = const Value.absent(),
    this.calories100gSnapshot = const Value.absent(),
    this.co2e100gSnapshot = const Value.absent(),
    this.confidenceBandSnapshot = const Value.absent(),
    this.lastQuantity = const Value.absent(),
    this.lastUnit = const Value.absent(),
    this.favoritedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoriteTableCompanion.insert({
    required String id,
    required BigInt hlcMillis,
    required int hlcCounter,
    required String hlcNodeId,
    this.dirty = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String foodRef,
    required String foodRefSource,
    required String productNameSnapshot,
    this.brandSnapshot = const Value.absent(),
    this.calories100gSnapshot = const Value.absent(),
    this.co2e100gSnapshot = const Value.absent(),
    this.confidenceBandSnapshot = const Value.absent(),
    this.lastQuantity = const Value.absent(),
    this.lastUnit = const Value.absent(),
    required DateTime favoritedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       hlcMillis = Value(hlcMillis),
       hlcCounter = Value(hlcCounter),
       hlcNodeId = Value(hlcNodeId),
       foodRef = Value(foodRef),
       foodRefSource = Value(foodRefSource),
       productNameSnapshot = Value(productNameSnapshot),
       favoritedAt = Value(favoritedAt);
  static Insertable<FavoriteRow> custom({
    Expression<String>? id,
    Expression<BigInt>? hlcMillis,
    Expression<int>? hlcCounter,
    Expression<String>? hlcNodeId,
    Expression<bool>? dirty,
    Expression<DateTime>? deletedAt,
    Expression<String>? foodRef,
    Expression<String>? foodRefSource,
    Expression<String>? productNameSnapshot,
    Expression<String>? brandSnapshot,
    Expression<double>? calories100gSnapshot,
    Expression<double>? co2e100gSnapshot,
    Expression<String>? confidenceBandSnapshot,
    Expression<double>? lastQuantity,
    Expression<String>? lastUnit,
    Expression<DateTime>? favoritedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hlcMillis != null) 'hlc_millis': hlcMillis,
      if (hlcCounter != null) 'hlc_counter': hlcCounter,
      if (hlcNodeId != null) 'hlc_node_id': hlcNodeId,
      if (dirty != null) 'dirty': dirty,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (foodRef != null) 'food_ref': foodRef,
      if (foodRefSource != null) 'food_ref_source': foodRefSource,
      if (productNameSnapshot != null)
        'product_name_snapshot': productNameSnapshot,
      if (brandSnapshot != null) 'brand_snapshot': brandSnapshot,
      if (calories100gSnapshot != null)
        'calories100g_snapshot': calories100gSnapshot,
      if (co2e100gSnapshot != null) 'co2e100g_snapshot': co2e100gSnapshot,
      if (confidenceBandSnapshot != null)
        'confidence_band_snapshot': confidenceBandSnapshot,
      if (lastQuantity != null) 'last_quantity': lastQuantity,
      if (lastUnit != null) 'last_unit': lastUnit,
      if (favoritedAt != null) 'favorited_at': favoritedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoriteTableCompanion copyWith({
    Value<String>? id,
    Value<BigInt>? hlcMillis,
    Value<int>? hlcCounter,
    Value<String>? hlcNodeId,
    Value<bool>? dirty,
    Value<DateTime?>? deletedAt,
    Value<String>? foodRef,
    Value<String>? foodRefSource,
    Value<String>? productNameSnapshot,
    Value<String?>? brandSnapshot,
    Value<double?>? calories100gSnapshot,
    Value<double?>? co2e100gSnapshot,
    Value<String?>? confidenceBandSnapshot,
    Value<double?>? lastQuantity,
    Value<PortionUnit?>? lastUnit,
    Value<DateTime>? favoritedAt,
    Value<int>? rowid,
  }) {
    return FavoriteTableCompanion(
      id: id ?? this.id,
      hlcMillis: hlcMillis ?? this.hlcMillis,
      hlcCounter: hlcCounter ?? this.hlcCounter,
      hlcNodeId: hlcNodeId ?? this.hlcNodeId,
      dirty: dirty ?? this.dirty,
      deletedAt: deletedAt ?? this.deletedAt,
      foodRef: foodRef ?? this.foodRef,
      foodRefSource: foodRefSource ?? this.foodRefSource,
      productNameSnapshot: productNameSnapshot ?? this.productNameSnapshot,
      brandSnapshot: brandSnapshot ?? this.brandSnapshot,
      calories100gSnapshot: calories100gSnapshot ?? this.calories100gSnapshot,
      co2e100gSnapshot: co2e100gSnapshot ?? this.co2e100gSnapshot,
      confidenceBandSnapshot:
          confidenceBandSnapshot ?? this.confidenceBandSnapshot,
      lastQuantity: lastQuantity ?? this.lastQuantity,
      lastUnit: lastUnit ?? this.lastUnit,
      favoritedAt: favoritedAt ?? this.favoritedAt,
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
    if (foodRef.present) {
      map['food_ref'] = Variable<String>(foodRef.value);
    }
    if (foodRefSource.present) {
      map['food_ref_source'] = Variable<String>(foodRefSource.value);
    }
    if (productNameSnapshot.present) {
      map['product_name_snapshot'] = Variable<String>(
        productNameSnapshot.value,
      );
    }
    if (brandSnapshot.present) {
      map['brand_snapshot'] = Variable<String>(brandSnapshot.value);
    }
    if (calories100gSnapshot.present) {
      map['calories100g_snapshot'] = Variable<double>(
        calories100gSnapshot.value,
      );
    }
    if (co2e100gSnapshot.present) {
      map['co2e100g_snapshot'] = Variable<double>(co2e100gSnapshot.value);
    }
    if (confidenceBandSnapshot.present) {
      map['confidence_band_snapshot'] = Variable<String>(
        confidenceBandSnapshot.value,
      );
    }
    if (lastQuantity.present) {
      map['last_quantity'] = Variable<double>(lastQuantity.value);
    }
    if (lastUnit.present) {
      map['last_unit'] = Variable<String>(
        $FavoriteTableTable.$converterlastUnitn.toSql(lastUnit.value),
      );
    }
    if (favoritedAt.present) {
      map['favorited_at'] = Variable<DateTime>(favoritedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteTableCompanion(')
          ..write('id: $id, ')
          ..write('hlcMillis: $hlcMillis, ')
          ..write('hlcCounter: $hlcCounter, ')
          ..write('hlcNodeId: $hlcNodeId, ')
          ..write('dirty: $dirty, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('foodRef: $foodRef, ')
          ..write('foodRefSource: $foodRefSource, ')
          ..write('productNameSnapshot: $productNameSnapshot, ')
          ..write('brandSnapshot: $brandSnapshot, ')
          ..write('calories100gSnapshot: $calories100gSnapshot, ')
          ..write('co2e100gSnapshot: $co2e100gSnapshot, ')
          ..write('confidenceBandSnapshot: $confidenceBandSnapshot, ')
          ..write('lastQuantity: $lastQuantity, ')
          ..write('lastUnit: $lastUnit, ')
          ..write('favoritedAt: $favoritedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserFoodTableTable extends UserFoodTable
    with TableInfo<$UserFoodTableTable, UserFoodRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserFoodTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceAmountGMeta = const VerificationMeta(
    'referenceAmountG',
  );
  @override
  late final GeneratedColumn<double> referenceAmountG = GeneratedColumn<double>(
    'reference_amount_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(100),
  );
  static const VerificationMeta _caloriesMeta = const VerificationMeta(
    'calories',
  );
  @override
  late final GeneratedColumn<double> calories = GeneratedColumn<double>(
    'calories',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinMeta = const VerificationMeta(
    'protein',
  );
  @override
  late final GeneratedColumn<double> protein = GeneratedColumn<double>(
    'protein',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _carbsMeta = const VerificationMeta('carbs');
  @override
  late final GeneratedColumn<double> carbs = GeneratedColumn<double>(
    'carbs',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sugarMeta = const VerificationMeta('sugar');
  @override
  late final GeneratedColumn<double> sugar = GeneratedColumn<double>(
    'sugar',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fatMeta = const VerificationMeta('fat');
  @override
  late final GeneratedColumn<double> fat = GeneratedColumn<double>(
    'fat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fiberMeta = const VerificationMeta('fiber');
  @override
  late final GeneratedColumn<double> fiber = GeneratedColumn<double>(
    'fiber',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _saltMeta = const VerificationMeta('salt');
  @override
  late final GeneratedColumn<double> salt = GeneratedColumn<double>(
    'salt',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _co2e100gMeta = const VerificationMeta(
    'co2e100g',
  );
  @override
  late final GeneratedColumn<double> co2e100g = GeneratedColumn<double>(
    'co2e100g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confidenceBandMeta = const VerificationMeta(
    'confidenceBand',
  );
  @override
  late final GeneratedColumn<String> confidenceBand = GeneratedColumn<String>(
    'confidence_band',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _co2SourceMeta = const VerificationMeta(
    'co2Source',
  );
  @override
  late final GeneratedColumn<String> co2Source = GeneratedColumn<String>(
    'co2_source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _co2MethodologyVersionMeta =
      const VerificationMeta('co2MethodologyVersion');
  @override
  late final GeneratedColumn<String> co2MethodologyVersion =
      GeneratedColumn<String>(
        'co2_methodology_version',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<ServingSize>, String>
  quickServingSizes =
      GeneratedColumn<String>(
        'quick_serving_sizes',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<ServingSize>>(
        $UserFoodTableTable.$converterquickServingSizes,
      );
  static const VerificationMeta _overrideOfRefMeta = const VerificationMeta(
    'overrideOfRef',
  );
  @override
  late final GeneratedColumn<String> overrideOfRef = GeneratedColumn<String>(
    'override_of_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _overrideOfSourceMeta = const VerificationMeta(
    'overrideOfSource',
  );
  @override
  late final GeneratedColumn<String> overrideOfSource = GeneratedColumn<String>(
    'override_of_source',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    name,
    brand,
    category,
    referenceAmountG,
    calories,
    protein,
    carbs,
    sugar,
    fat,
    fiber,
    salt,
    co2e100g,
    confidenceBand,
    co2Source,
    co2MethodologyVersion,
    barcode,
    quickServingSizes,
    overrideOfRef,
    overrideOfSource,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_food_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserFoodRow> instance, {
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
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('reference_amount_g')) {
      context.handle(
        _referenceAmountGMeta,
        referenceAmountG.isAcceptableOrUnknown(
          data['reference_amount_g']!,
          _referenceAmountGMeta,
        ),
      );
    }
    if (data.containsKey('calories')) {
      context.handle(
        _caloriesMeta,
        calories.isAcceptableOrUnknown(data['calories']!, _caloriesMeta),
      );
    } else if (isInserting) {
      context.missing(_caloriesMeta);
    }
    if (data.containsKey('protein')) {
      context.handle(
        _proteinMeta,
        protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta),
      );
    }
    if (data.containsKey('carbs')) {
      context.handle(
        _carbsMeta,
        carbs.isAcceptableOrUnknown(data['carbs']!, _carbsMeta),
      );
    }
    if (data.containsKey('sugar')) {
      context.handle(
        _sugarMeta,
        sugar.isAcceptableOrUnknown(data['sugar']!, _sugarMeta),
      );
    }
    if (data.containsKey('fat')) {
      context.handle(
        _fatMeta,
        fat.isAcceptableOrUnknown(data['fat']!, _fatMeta),
      );
    }
    if (data.containsKey('fiber')) {
      context.handle(
        _fiberMeta,
        fiber.isAcceptableOrUnknown(data['fiber']!, _fiberMeta),
      );
    }
    if (data.containsKey('salt')) {
      context.handle(
        _saltMeta,
        salt.isAcceptableOrUnknown(data['salt']!, _saltMeta),
      );
    }
    if (data.containsKey('co2e100g')) {
      context.handle(
        _co2e100gMeta,
        co2e100g.isAcceptableOrUnknown(data['co2e100g']!, _co2e100gMeta),
      );
    }
    if (data.containsKey('confidence_band')) {
      context.handle(
        _confidenceBandMeta,
        confidenceBand.isAcceptableOrUnknown(
          data['confidence_band']!,
          _confidenceBandMeta,
        ),
      );
    }
    if (data.containsKey('co2_source')) {
      context.handle(
        _co2SourceMeta,
        co2Source.isAcceptableOrUnknown(data['co2_source']!, _co2SourceMeta),
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
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('override_of_ref')) {
      context.handle(
        _overrideOfRefMeta,
        overrideOfRef.isAcceptableOrUnknown(
          data['override_of_ref']!,
          _overrideOfRefMeta,
        ),
      );
    }
    if (data.containsKey('override_of_source')) {
      context.handle(
        _overrideOfSourceMeta,
        overrideOfSource.isAcceptableOrUnknown(
          data['override_of_source']!,
          _overrideOfSourceMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserFoodRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserFoodRow(
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
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      referenceAmountG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}reference_amount_g'],
      )!,
      calories: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}calories'],
      )!,
      protein: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein'],
      ),
      carbs: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs'],
      ),
      sugar: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sugar'],
      ),
      fat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat'],
      ),
      fiber: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fiber'],
      ),
      salt: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}salt'],
      ),
      co2e100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}co2e100g'],
      ),
      confidenceBand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}confidence_band'],
      ),
      co2Source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}co2_source'],
      ),
      co2MethodologyVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}co2_methodology_version'],
      ),
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      quickServingSizes: $UserFoodTableTable.$converterquickServingSizes
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}quick_serving_sizes'],
            )!,
          ),
      overrideOfRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}override_of_ref'],
      ),
      overrideOfSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}override_of_source'],
      ),
    );
  }

  @override
  $UserFoodTableTable createAlias(String alias) {
    return $UserFoodTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<List<ServingSize>, String, Object?>
  $converterquickServingSizes = servingSizeListConverter;
}

class UserFoodRow extends DataClass implements Insertable<UserFoodRow> {
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

  /// Food name, required (LOG-10: "name + at least a calorie value are
  /// required to save").
  final String name;

  /// Brand, nullable.
  final String? brand;

  /// Fixed AGRIBALYSE category tag, not freeform (CONTEXT.md decision —
  /// guarantees the CO2 category-estimate always resolves).
  final String? category;

  /// The amount, in grams, that the nutrition fields below are measured
  /// against. Defaults to 100 (g).
  final double referenceAmountG;

  /// Energy in kcal per [referenceAmountG]. Required (LOG-10).
  final double calories;

  /// Protein in g per [referenceAmountG], nullable.
  final double? protein;

  /// Carbohydrates in g per [referenceAmountG], nullable.
  final double? carbs;

  /// Sugar in g per [referenceAmountG], nullable.
  final double? sugar;

  /// Fat in g per [referenceAmountG], nullable.
  final double? fat;

  /// Fiber in g per [referenceAmountG], nullable.
  final double? fiber;

  /// Salt in g per [referenceAmountG], nullable.
  final double? salt;

  /// kg CO2e per kg product — same unit convention as
  /// `FoodItem.co2e100g`, independent of [referenceAmountG] (which only
  /// scopes the nutrition fields above).
  final double? co2e100g;

  /// Confidence band: `'medium'` when [co2Source] is
  /// `'category_estimate'`; always `null` when [co2Source] is `'manual'`
  /// (a self-entered number has no methodology backing it — CONTEXT.md
  /// decision, no confidence chip for manual CO2).
  final String? confidenceBand;

  /// One of `'category_estimate'` or `'manual'`.
  final String? co2Source;

  /// Version of the CO₂ calculation methodology that produced
  /// [co2e100g] when [co2Source] is `'category_estimate'` (CO2-04 — per
  /// `01-CONTEXT.md`'s locked decision that every CO₂-bearing table
  /// created in later phases carries this column, matching
  /// `UserProfileTable.co2MethodologyVersion`'s precedent). Always `null`
  /// when [co2Source] is `'manual'`, mirroring [confidenceBand]'s same
  /// nullability rule — a self-entered number has no methodology to
  /// version.
  final String? co2MethodologyVersion;

  /// Optional barcode; pre-filled from the barcode no-match flow so a
  /// future scan of that barcode resolves to this custom food.
  final String? barcode;

  /// User-configurable quick serving sizes (e.g. `{label: 'Slice', grams:
  /// 30}`), stored as JSON via [servingSizeListConverter].
  final List<ServingSize> quickServingSizes;

  /// Non-null only when this row is an override of an existing
  /// catalog/cache food — paired with [overrideOfSource].
  final String? overrideOfRef;

  /// `'off_ref'` or `'user_food_cache'`, paired with [overrideOfRef].
  final String? overrideOfSource;
  const UserFoodRow({
    required this.id,
    required this.hlcMillis,
    required this.hlcCounter,
    required this.hlcNodeId,
    required this.dirty,
    this.deletedAt,
    required this.name,
    this.brand,
    this.category,
    required this.referenceAmountG,
    required this.calories,
    this.protein,
    this.carbs,
    this.sugar,
    this.fat,
    this.fiber,
    this.salt,
    this.co2e100g,
    this.confidenceBand,
    this.co2Source,
    this.co2MethodologyVersion,
    this.barcode,
    required this.quickServingSizes,
    this.overrideOfRef,
    this.overrideOfSource,
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
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['reference_amount_g'] = Variable<double>(referenceAmountG);
    map['calories'] = Variable<double>(calories);
    if (!nullToAbsent || protein != null) {
      map['protein'] = Variable<double>(protein);
    }
    if (!nullToAbsent || carbs != null) {
      map['carbs'] = Variable<double>(carbs);
    }
    if (!nullToAbsent || sugar != null) {
      map['sugar'] = Variable<double>(sugar);
    }
    if (!nullToAbsent || fat != null) {
      map['fat'] = Variable<double>(fat);
    }
    if (!nullToAbsent || fiber != null) {
      map['fiber'] = Variable<double>(fiber);
    }
    if (!nullToAbsent || salt != null) {
      map['salt'] = Variable<double>(salt);
    }
    if (!nullToAbsent || co2e100g != null) {
      map['co2e100g'] = Variable<double>(co2e100g);
    }
    if (!nullToAbsent || confidenceBand != null) {
      map['confidence_band'] = Variable<String>(confidenceBand);
    }
    if (!nullToAbsent || co2Source != null) {
      map['co2_source'] = Variable<String>(co2Source);
    }
    if (!nullToAbsent || co2MethodologyVersion != null) {
      map['co2_methodology_version'] = Variable<String>(co2MethodologyVersion);
    }
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    {
      map['quick_serving_sizes'] = Variable<String>(
        $UserFoodTableTable.$converterquickServingSizes.toSql(
          quickServingSizes,
        ),
      );
    }
    if (!nullToAbsent || overrideOfRef != null) {
      map['override_of_ref'] = Variable<String>(overrideOfRef);
    }
    if (!nullToAbsent || overrideOfSource != null) {
      map['override_of_source'] = Variable<String>(overrideOfSource);
    }
    return map;
  }

  UserFoodTableCompanion toCompanion(bool nullToAbsent) {
    return UserFoodTableCompanion(
      id: Value(id),
      hlcMillis: Value(hlcMillis),
      hlcCounter: Value(hlcCounter),
      hlcNodeId: Value(hlcNodeId),
      dirty: Value(dirty),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      name: Value(name),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      referenceAmountG: Value(referenceAmountG),
      calories: Value(calories),
      protein: protein == null && nullToAbsent
          ? const Value.absent()
          : Value(protein),
      carbs: carbs == null && nullToAbsent
          ? const Value.absent()
          : Value(carbs),
      sugar: sugar == null && nullToAbsent
          ? const Value.absent()
          : Value(sugar),
      fat: fat == null && nullToAbsent ? const Value.absent() : Value(fat),
      fiber: fiber == null && nullToAbsent
          ? const Value.absent()
          : Value(fiber),
      salt: salt == null && nullToAbsent ? const Value.absent() : Value(salt),
      co2e100g: co2e100g == null && nullToAbsent
          ? const Value.absent()
          : Value(co2e100g),
      confidenceBand: confidenceBand == null && nullToAbsent
          ? const Value.absent()
          : Value(confidenceBand),
      co2Source: co2Source == null && nullToAbsent
          ? const Value.absent()
          : Value(co2Source),
      co2MethodologyVersion: co2MethodologyVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(co2MethodologyVersion),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      quickServingSizes: Value(quickServingSizes),
      overrideOfRef: overrideOfRef == null && nullToAbsent
          ? const Value.absent()
          : Value(overrideOfRef),
      overrideOfSource: overrideOfSource == null && nullToAbsent
          ? const Value.absent()
          : Value(overrideOfSource),
    );
  }

  factory UserFoodRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserFoodRow(
      id: serializer.fromJson<String>(json['id']),
      hlcMillis: serializer.fromJson<BigInt>(json['hlcMillis']),
      hlcCounter: serializer.fromJson<int>(json['hlcCounter']),
      hlcNodeId: serializer.fromJson<String>(json['hlcNodeId']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      name: serializer.fromJson<String>(json['name']),
      brand: serializer.fromJson<String?>(json['brand']),
      category: serializer.fromJson<String?>(json['category']),
      referenceAmountG: serializer.fromJson<double>(json['referenceAmountG']),
      calories: serializer.fromJson<double>(json['calories']),
      protein: serializer.fromJson<double?>(json['protein']),
      carbs: serializer.fromJson<double?>(json['carbs']),
      sugar: serializer.fromJson<double?>(json['sugar']),
      fat: serializer.fromJson<double?>(json['fat']),
      fiber: serializer.fromJson<double?>(json['fiber']),
      salt: serializer.fromJson<double?>(json['salt']),
      co2e100g: serializer.fromJson<double?>(json['co2e100g']),
      confidenceBand: serializer.fromJson<String?>(json['confidenceBand']),
      co2Source: serializer.fromJson<String?>(json['co2Source']),
      co2MethodologyVersion: serializer.fromJson<String?>(
        json['co2MethodologyVersion'],
      ),
      barcode: serializer.fromJson<String?>(json['barcode']),
      quickServingSizes: $UserFoodTableTable.$converterquickServingSizes
          .fromJson(serializer.fromJson<Object?>(json['quickServingSizes'])),
      overrideOfRef: serializer.fromJson<String?>(json['overrideOfRef']),
      overrideOfSource: serializer.fromJson<String?>(json['overrideOfSource']),
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
      'name': serializer.toJson<String>(name),
      'brand': serializer.toJson<String?>(brand),
      'category': serializer.toJson<String?>(category),
      'referenceAmountG': serializer.toJson<double>(referenceAmountG),
      'calories': serializer.toJson<double>(calories),
      'protein': serializer.toJson<double?>(protein),
      'carbs': serializer.toJson<double?>(carbs),
      'sugar': serializer.toJson<double?>(sugar),
      'fat': serializer.toJson<double?>(fat),
      'fiber': serializer.toJson<double?>(fiber),
      'salt': serializer.toJson<double?>(salt),
      'co2e100g': serializer.toJson<double?>(co2e100g),
      'confidenceBand': serializer.toJson<String?>(confidenceBand),
      'co2Source': serializer.toJson<String?>(co2Source),
      'co2MethodologyVersion': serializer.toJson<String?>(
        co2MethodologyVersion,
      ),
      'barcode': serializer.toJson<String?>(barcode),
      'quickServingSizes': serializer.toJson<Object?>(
        $UserFoodTableTable.$converterquickServingSizes.toJson(
          quickServingSizes,
        ),
      ),
      'overrideOfRef': serializer.toJson<String?>(overrideOfRef),
      'overrideOfSource': serializer.toJson<String?>(overrideOfSource),
    };
  }

  UserFoodRow copyWith({
    String? id,
    BigInt? hlcMillis,
    int? hlcCounter,
    String? hlcNodeId,
    bool? dirty,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? name,
    Value<String?> brand = const Value.absent(),
    Value<String?> category = const Value.absent(),
    double? referenceAmountG,
    double? calories,
    Value<double?> protein = const Value.absent(),
    Value<double?> carbs = const Value.absent(),
    Value<double?> sugar = const Value.absent(),
    Value<double?> fat = const Value.absent(),
    Value<double?> fiber = const Value.absent(),
    Value<double?> salt = const Value.absent(),
    Value<double?> co2e100g = const Value.absent(),
    Value<String?> confidenceBand = const Value.absent(),
    Value<String?> co2Source = const Value.absent(),
    Value<String?> co2MethodologyVersion = const Value.absent(),
    Value<String?> barcode = const Value.absent(),
    List<ServingSize>? quickServingSizes,
    Value<String?> overrideOfRef = const Value.absent(),
    Value<String?> overrideOfSource = const Value.absent(),
  }) => UserFoodRow(
    id: id ?? this.id,
    hlcMillis: hlcMillis ?? this.hlcMillis,
    hlcCounter: hlcCounter ?? this.hlcCounter,
    hlcNodeId: hlcNodeId ?? this.hlcNodeId,
    dirty: dirty ?? this.dirty,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    name: name ?? this.name,
    brand: brand.present ? brand.value : this.brand,
    category: category.present ? category.value : this.category,
    referenceAmountG: referenceAmountG ?? this.referenceAmountG,
    calories: calories ?? this.calories,
    protein: protein.present ? protein.value : this.protein,
    carbs: carbs.present ? carbs.value : this.carbs,
    sugar: sugar.present ? sugar.value : this.sugar,
    fat: fat.present ? fat.value : this.fat,
    fiber: fiber.present ? fiber.value : this.fiber,
    salt: salt.present ? salt.value : this.salt,
    co2e100g: co2e100g.present ? co2e100g.value : this.co2e100g,
    confidenceBand: confidenceBand.present
        ? confidenceBand.value
        : this.confidenceBand,
    co2Source: co2Source.present ? co2Source.value : this.co2Source,
    co2MethodologyVersion: co2MethodologyVersion.present
        ? co2MethodologyVersion.value
        : this.co2MethodologyVersion,
    barcode: barcode.present ? barcode.value : this.barcode,
    quickServingSizes: quickServingSizes ?? this.quickServingSizes,
    overrideOfRef: overrideOfRef.present
        ? overrideOfRef.value
        : this.overrideOfRef,
    overrideOfSource: overrideOfSource.present
        ? overrideOfSource.value
        : this.overrideOfSource,
  );
  UserFoodRow copyWithCompanion(UserFoodTableCompanion data) {
    return UserFoodRow(
      id: data.id.present ? data.id.value : this.id,
      hlcMillis: data.hlcMillis.present ? data.hlcMillis.value : this.hlcMillis,
      hlcCounter: data.hlcCounter.present
          ? data.hlcCounter.value
          : this.hlcCounter,
      hlcNodeId: data.hlcNodeId.present ? data.hlcNodeId.value : this.hlcNodeId,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      name: data.name.present ? data.name.value : this.name,
      brand: data.brand.present ? data.brand.value : this.brand,
      category: data.category.present ? data.category.value : this.category,
      referenceAmountG: data.referenceAmountG.present
          ? data.referenceAmountG.value
          : this.referenceAmountG,
      calories: data.calories.present ? data.calories.value : this.calories,
      protein: data.protein.present ? data.protein.value : this.protein,
      carbs: data.carbs.present ? data.carbs.value : this.carbs,
      sugar: data.sugar.present ? data.sugar.value : this.sugar,
      fat: data.fat.present ? data.fat.value : this.fat,
      fiber: data.fiber.present ? data.fiber.value : this.fiber,
      salt: data.salt.present ? data.salt.value : this.salt,
      co2e100g: data.co2e100g.present ? data.co2e100g.value : this.co2e100g,
      confidenceBand: data.confidenceBand.present
          ? data.confidenceBand.value
          : this.confidenceBand,
      co2Source: data.co2Source.present ? data.co2Source.value : this.co2Source,
      co2MethodologyVersion: data.co2MethodologyVersion.present
          ? data.co2MethodologyVersion.value
          : this.co2MethodologyVersion,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      quickServingSizes: data.quickServingSizes.present
          ? data.quickServingSizes.value
          : this.quickServingSizes,
      overrideOfRef: data.overrideOfRef.present
          ? data.overrideOfRef.value
          : this.overrideOfRef,
      overrideOfSource: data.overrideOfSource.present
          ? data.overrideOfSource.value
          : this.overrideOfSource,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserFoodRow(')
          ..write('id: $id, ')
          ..write('hlcMillis: $hlcMillis, ')
          ..write('hlcCounter: $hlcCounter, ')
          ..write('hlcNodeId: $hlcNodeId, ')
          ..write('dirty: $dirty, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('category: $category, ')
          ..write('referenceAmountG: $referenceAmountG, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs, ')
          ..write('sugar: $sugar, ')
          ..write('fat: $fat, ')
          ..write('fiber: $fiber, ')
          ..write('salt: $salt, ')
          ..write('co2e100g: $co2e100g, ')
          ..write('confidenceBand: $confidenceBand, ')
          ..write('co2Source: $co2Source, ')
          ..write('co2MethodologyVersion: $co2MethodologyVersion, ')
          ..write('barcode: $barcode, ')
          ..write('quickServingSizes: $quickServingSizes, ')
          ..write('overrideOfRef: $overrideOfRef, ')
          ..write('overrideOfSource: $overrideOfSource')
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
    name,
    brand,
    category,
    referenceAmountG,
    calories,
    protein,
    carbs,
    sugar,
    fat,
    fiber,
    salt,
    co2e100g,
    confidenceBand,
    co2Source,
    co2MethodologyVersion,
    barcode,
    quickServingSizes,
    overrideOfRef,
    overrideOfSource,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserFoodRow &&
          other.id == this.id &&
          other.hlcMillis == this.hlcMillis &&
          other.hlcCounter == this.hlcCounter &&
          other.hlcNodeId == this.hlcNodeId &&
          other.dirty == this.dirty &&
          other.deletedAt == this.deletedAt &&
          other.name == this.name &&
          other.brand == this.brand &&
          other.category == this.category &&
          other.referenceAmountG == this.referenceAmountG &&
          other.calories == this.calories &&
          other.protein == this.protein &&
          other.carbs == this.carbs &&
          other.sugar == this.sugar &&
          other.fat == this.fat &&
          other.fiber == this.fiber &&
          other.salt == this.salt &&
          other.co2e100g == this.co2e100g &&
          other.confidenceBand == this.confidenceBand &&
          other.co2Source == this.co2Source &&
          other.co2MethodologyVersion == this.co2MethodologyVersion &&
          other.barcode == this.barcode &&
          other.quickServingSizes == this.quickServingSizes &&
          other.overrideOfRef == this.overrideOfRef &&
          other.overrideOfSource == this.overrideOfSource);
}

class UserFoodTableCompanion extends UpdateCompanion<UserFoodRow> {
  final Value<String> id;
  final Value<BigInt> hlcMillis;
  final Value<int> hlcCounter;
  final Value<String> hlcNodeId;
  final Value<bool> dirty;
  final Value<DateTime?> deletedAt;
  final Value<String> name;
  final Value<String?> brand;
  final Value<String?> category;
  final Value<double> referenceAmountG;
  final Value<double> calories;
  final Value<double?> protein;
  final Value<double?> carbs;
  final Value<double?> sugar;
  final Value<double?> fat;
  final Value<double?> fiber;
  final Value<double?> salt;
  final Value<double?> co2e100g;
  final Value<String?> confidenceBand;
  final Value<String?> co2Source;
  final Value<String?> co2MethodologyVersion;
  final Value<String?> barcode;
  final Value<List<ServingSize>> quickServingSizes;
  final Value<String?> overrideOfRef;
  final Value<String?> overrideOfSource;
  final Value<int> rowid;
  const UserFoodTableCompanion({
    this.id = const Value.absent(),
    this.hlcMillis = const Value.absent(),
    this.hlcCounter = const Value.absent(),
    this.hlcNodeId = const Value.absent(),
    this.dirty = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.brand = const Value.absent(),
    this.category = const Value.absent(),
    this.referenceAmountG = const Value.absent(),
    this.calories = const Value.absent(),
    this.protein = const Value.absent(),
    this.carbs = const Value.absent(),
    this.sugar = const Value.absent(),
    this.fat = const Value.absent(),
    this.fiber = const Value.absent(),
    this.salt = const Value.absent(),
    this.co2e100g = const Value.absent(),
    this.confidenceBand = const Value.absent(),
    this.co2Source = const Value.absent(),
    this.co2MethodologyVersion = const Value.absent(),
    this.barcode = const Value.absent(),
    this.quickServingSizes = const Value.absent(),
    this.overrideOfRef = const Value.absent(),
    this.overrideOfSource = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserFoodTableCompanion.insert({
    required String id,
    required BigInt hlcMillis,
    required int hlcCounter,
    required String hlcNodeId,
    this.dirty = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String name,
    this.brand = const Value.absent(),
    this.category = const Value.absent(),
    this.referenceAmountG = const Value.absent(),
    required double calories,
    this.protein = const Value.absent(),
    this.carbs = const Value.absent(),
    this.sugar = const Value.absent(),
    this.fat = const Value.absent(),
    this.fiber = const Value.absent(),
    this.salt = const Value.absent(),
    this.co2e100g = const Value.absent(),
    this.confidenceBand = const Value.absent(),
    this.co2Source = const Value.absent(),
    this.co2MethodologyVersion = const Value.absent(),
    this.barcode = const Value.absent(),
    required List<ServingSize> quickServingSizes,
    this.overrideOfRef = const Value.absent(),
    this.overrideOfSource = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       hlcMillis = Value(hlcMillis),
       hlcCounter = Value(hlcCounter),
       hlcNodeId = Value(hlcNodeId),
       name = Value(name),
       calories = Value(calories),
       quickServingSizes = Value(quickServingSizes);
  static Insertable<UserFoodRow> custom({
    Expression<String>? id,
    Expression<BigInt>? hlcMillis,
    Expression<int>? hlcCounter,
    Expression<String>? hlcNodeId,
    Expression<bool>? dirty,
    Expression<DateTime>? deletedAt,
    Expression<String>? name,
    Expression<String>? brand,
    Expression<String>? category,
    Expression<double>? referenceAmountG,
    Expression<double>? calories,
    Expression<double>? protein,
    Expression<double>? carbs,
    Expression<double>? sugar,
    Expression<double>? fat,
    Expression<double>? fiber,
    Expression<double>? salt,
    Expression<double>? co2e100g,
    Expression<String>? confidenceBand,
    Expression<String>? co2Source,
    Expression<String>? co2MethodologyVersion,
    Expression<String>? barcode,
    Expression<String>? quickServingSizes,
    Expression<String>? overrideOfRef,
    Expression<String>? overrideOfSource,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hlcMillis != null) 'hlc_millis': hlcMillis,
      if (hlcCounter != null) 'hlc_counter': hlcCounter,
      if (hlcNodeId != null) 'hlc_node_id': hlcNodeId,
      if (dirty != null) 'dirty': dirty,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (name != null) 'name': name,
      if (brand != null) 'brand': brand,
      if (category != null) 'category': category,
      if (referenceAmountG != null) 'reference_amount_g': referenceAmountG,
      if (calories != null) 'calories': calories,
      if (protein != null) 'protein': protein,
      if (carbs != null) 'carbs': carbs,
      if (sugar != null) 'sugar': sugar,
      if (fat != null) 'fat': fat,
      if (fiber != null) 'fiber': fiber,
      if (salt != null) 'salt': salt,
      if (co2e100g != null) 'co2e100g': co2e100g,
      if (confidenceBand != null) 'confidence_band': confidenceBand,
      if (co2Source != null) 'co2_source': co2Source,
      if (co2MethodologyVersion != null)
        'co2_methodology_version': co2MethodologyVersion,
      if (barcode != null) 'barcode': barcode,
      if (quickServingSizes != null) 'quick_serving_sizes': quickServingSizes,
      if (overrideOfRef != null) 'override_of_ref': overrideOfRef,
      if (overrideOfSource != null) 'override_of_source': overrideOfSource,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserFoodTableCompanion copyWith({
    Value<String>? id,
    Value<BigInt>? hlcMillis,
    Value<int>? hlcCounter,
    Value<String>? hlcNodeId,
    Value<bool>? dirty,
    Value<DateTime?>? deletedAt,
    Value<String>? name,
    Value<String?>? brand,
    Value<String?>? category,
    Value<double>? referenceAmountG,
    Value<double>? calories,
    Value<double?>? protein,
    Value<double?>? carbs,
    Value<double?>? sugar,
    Value<double?>? fat,
    Value<double?>? fiber,
    Value<double?>? salt,
    Value<double?>? co2e100g,
    Value<String?>? confidenceBand,
    Value<String?>? co2Source,
    Value<String?>? co2MethodologyVersion,
    Value<String?>? barcode,
    Value<List<ServingSize>>? quickServingSizes,
    Value<String?>? overrideOfRef,
    Value<String?>? overrideOfSource,
    Value<int>? rowid,
  }) {
    return UserFoodTableCompanion(
      id: id ?? this.id,
      hlcMillis: hlcMillis ?? this.hlcMillis,
      hlcCounter: hlcCounter ?? this.hlcCounter,
      hlcNodeId: hlcNodeId ?? this.hlcNodeId,
      dirty: dirty ?? this.dirty,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      referenceAmountG: referenceAmountG ?? this.referenceAmountG,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      sugar: sugar ?? this.sugar,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      salt: salt ?? this.salt,
      co2e100g: co2e100g ?? this.co2e100g,
      confidenceBand: confidenceBand ?? this.confidenceBand,
      co2Source: co2Source ?? this.co2Source,
      co2MethodologyVersion:
          co2MethodologyVersion ?? this.co2MethodologyVersion,
      barcode: barcode ?? this.barcode,
      quickServingSizes: quickServingSizes ?? this.quickServingSizes,
      overrideOfRef: overrideOfRef ?? this.overrideOfRef,
      overrideOfSource: overrideOfSource ?? this.overrideOfSource,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (referenceAmountG.present) {
      map['reference_amount_g'] = Variable<double>(referenceAmountG.value);
    }
    if (calories.present) {
      map['calories'] = Variable<double>(calories.value);
    }
    if (protein.present) {
      map['protein'] = Variable<double>(protein.value);
    }
    if (carbs.present) {
      map['carbs'] = Variable<double>(carbs.value);
    }
    if (sugar.present) {
      map['sugar'] = Variable<double>(sugar.value);
    }
    if (fat.present) {
      map['fat'] = Variable<double>(fat.value);
    }
    if (fiber.present) {
      map['fiber'] = Variable<double>(fiber.value);
    }
    if (salt.present) {
      map['salt'] = Variable<double>(salt.value);
    }
    if (co2e100g.present) {
      map['co2e100g'] = Variable<double>(co2e100g.value);
    }
    if (confidenceBand.present) {
      map['confidence_band'] = Variable<String>(confidenceBand.value);
    }
    if (co2Source.present) {
      map['co2_source'] = Variable<String>(co2Source.value);
    }
    if (co2MethodologyVersion.present) {
      map['co2_methodology_version'] = Variable<String>(
        co2MethodologyVersion.value,
      );
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (quickServingSizes.present) {
      map['quick_serving_sizes'] = Variable<String>(
        $UserFoodTableTable.$converterquickServingSizes.toSql(
          quickServingSizes.value,
        ),
      );
    }
    if (overrideOfRef.present) {
      map['override_of_ref'] = Variable<String>(overrideOfRef.value);
    }
    if (overrideOfSource.present) {
      map['override_of_source'] = Variable<String>(overrideOfSource.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserFoodTableCompanion(')
          ..write('id: $id, ')
          ..write('hlcMillis: $hlcMillis, ')
          ..write('hlcCounter: $hlcCounter, ')
          ..write('hlcNodeId: $hlcNodeId, ')
          ..write('dirty: $dirty, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('category: $category, ')
          ..write('referenceAmountG: $referenceAmountG, ')
          ..write('calories: $calories, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs, ')
          ..write('sugar: $sugar, ')
          ..write('fat: $fat, ')
          ..write('fiber: $fiber, ')
          ..write('salt: $salt, ')
          ..write('co2e100g: $co2e100g, ')
          ..write('confidenceBand: $confidenceBand, ')
          ..write('co2Source: $co2Source, ')
          ..write('co2MethodologyVersion: $co2MethodologyVersion, ')
          ..write('barcode: $barcode, ')
          ..write('quickServingSizes: $quickServingSizes, ')
          ..write('overrideOfRef: $overrideOfRef, ')
          ..write('overrideOfSource: $overrideOfSource, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $Co2SettingsTableTable extends Co2SettingsTable
    with TableInfo<$Co2SettingsTableTable, Co2SettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $Co2SettingsTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _locationCountryMeta = const VerificationMeta(
    'locationCountry',
  );
  @override
  late final GeneratedColumn<String> locationCountry = GeneratedColumn<String>(
    'location_country',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationRegionMeta = const VerificationMeta(
    'locationRegion',
  );
  @override
  late final GeneratedColumn<String> locationRegion = GeneratedColumn<String>(
    'location_region',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _purchasingSourceMeta = const VerificationMeta(
    'purchasingSource',
  );
  @override
  late final GeneratedColumn<String> purchasingSource = GeneratedColumn<String>(
    'purchasing_source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shoppingTransportMeta = const VerificationMeta(
    'shoppingTransport',
  );
  @override
  late final GeneratedColumn<String> shoppingTransport =
      GeneratedColumn<String>(
        'shopping_transport',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _cookingMethodMeta = const VerificationMeta(
    'cookingMethod',
  );
  @override
  late final GeneratedColumn<String> cookingMethod = GeneratedColumn<String>(
    'cooking_method',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _foodStorageMeta = const VerificationMeta(
    'foodStorage',
  );
  @override
  late final GeneratedColumn<String> foodStorage = GeneratedColumn<String>(
    'food_storage',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _householdSizeMeta = const VerificationMeta(
    'householdSize',
  );
  @override
  late final GeneratedColumn<int> householdSize = GeneratedColumn<int>(
    'household_size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _foodWasteLevelMeta = const VerificationMeta(
    'foodWasteLevel',
  );
  @override
  late final GeneratedColumn<String> foodWasteLevel = GeneratedColumn<String>(
    'food_waste_level',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    locationCountry,
    locationRegion,
    purchasingSource,
    shoppingTransport,
    cookingMethod,
    foodStorage,
    householdSize,
    foodWasteLevel,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'co2_settings_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<Co2SettingsRow> instance, {
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
    if (data.containsKey('location_country')) {
      context.handle(
        _locationCountryMeta,
        locationCountry.isAcceptableOrUnknown(
          data['location_country']!,
          _locationCountryMeta,
        ),
      );
    }
    if (data.containsKey('location_region')) {
      context.handle(
        _locationRegionMeta,
        locationRegion.isAcceptableOrUnknown(
          data['location_region']!,
          _locationRegionMeta,
        ),
      );
    }
    if (data.containsKey('purchasing_source')) {
      context.handle(
        _purchasingSourceMeta,
        purchasingSource.isAcceptableOrUnknown(
          data['purchasing_source']!,
          _purchasingSourceMeta,
        ),
      );
    }
    if (data.containsKey('shopping_transport')) {
      context.handle(
        _shoppingTransportMeta,
        shoppingTransport.isAcceptableOrUnknown(
          data['shopping_transport']!,
          _shoppingTransportMeta,
        ),
      );
    }
    if (data.containsKey('cooking_method')) {
      context.handle(
        _cookingMethodMeta,
        cookingMethod.isAcceptableOrUnknown(
          data['cooking_method']!,
          _cookingMethodMeta,
        ),
      );
    }
    if (data.containsKey('food_storage')) {
      context.handle(
        _foodStorageMeta,
        foodStorage.isAcceptableOrUnknown(
          data['food_storage']!,
          _foodStorageMeta,
        ),
      );
    }
    if (data.containsKey('household_size')) {
      context.handle(
        _householdSizeMeta,
        householdSize.isAcceptableOrUnknown(
          data['household_size']!,
          _householdSizeMeta,
        ),
      );
    }
    if (data.containsKey('food_waste_level')) {
      context.handle(
        _foodWasteLevelMeta,
        foodWasteLevel.isAcceptableOrUnknown(
          data['food_waste_level']!,
          _foodWasteLevelMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Co2SettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Co2SettingsRow(
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
      locationCountry: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_country'],
      ),
      locationRegion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_region'],
      ),
      purchasingSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purchasing_source'],
      ),
      shoppingTransport: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shopping_transport'],
      ),
      cookingMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cooking_method'],
      ),
      foodStorage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_storage'],
      ),
      householdSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}household_size'],
      ),
      foodWasteLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_waste_level'],
      ),
    );
  }

  @override
  $Co2SettingsTableTable createAlias(String alias) {
    return $Co2SettingsTableTable(attachedDatabase, alias);
  }
}

class Co2SettingsRow extends DataClass implements Insertable<Co2SettingsRow> {
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

  /// Country the user shops/lives in, used for regional CO2 averages.
  final String? locationCountry;

  /// Region/state within [locationCountry], used for finer regional
  /// CO2 averages when available.
  final String? locationRegion;

  /// Where the user primarily buys food.
  /// Values: 'supermarket', 'local_farm', 'mix'.
  final String? purchasingSource;

  /// How the user typically travels to buy food.
  /// Values: 'car', 'public', 'walk_bike'.
  final String? shoppingTransport;

  /// The user's primary cooking method.
  /// Values: 'electric', 'gas', 'induction'.
  final String? cookingMethod;

  /// The user's food storage setup.
  /// Values: 'small_fridge', 'large_fridge_freezer'.
  final String? foodStorage;

  /// Number of people in the user's household.
  final int? householdSize;

  /// The user's self-reported food waste level.
  /// Values: 'low', 'medium', 'high'.
  final String? foodWasteLevel;
  const Co2SettingsRow({
    required this.id,
    required this.hlcMillis,
    required this.hlcCounter,
    required this.hlcNodeId,
    required this.dirty,
    this.deletedAt,
    this.locationCountry,
    this.locationRegion,
    this.purchasingSource,
    this.shoppingTransport,
    this.cookingMethod,
    this.foodStorage,
    this.householdSize,
    this.foodWasteLevel,
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
    if (!nullToAbsent || locationCountry != null) {
      map['location_country'] = Variable<String>(locationCountry);
    }
    if (!nullToAbsent || locationRegion != null) {
      map['location_region'] = Variable<String>(locationRegion);
    }
    if (!nullToAbsent || purchasingSource != null) {
      map['purchasing_source'] = Variable<String>(purchasingSource);
    }
    if (!nullToAbsent || shoppingTransport != null) {
      map['shopping_transport'] = Variable<String>(shoppingTransport);
    }
    if (!nullToAbsent || cookingMethod != null) {
      map['cooking_method'] = Variable<String>(cookingMethod);
    }
    if (!nullToAbsent || foodStorage != null) {
      map['food_storage'] = Variable<String>(foodStorage);
    }
    if (!nullToAbsent || householdSize != null) {
      map['household_size'] = Variable<int>(householdSize);
    }
    if (!nullToAbsent || foodWasteLevel != null) {
      map['food_waste_level'] = Variable<String>(foodWasteLevel);
    }
    return map;
  }

  Co2SettingsTableCompanion toCompanion(bool nullToAbsent) {
    return Co2SettingsTableCompanion(
      id: Value(id),
      hlcMillis: Value(hlcMillis),
      hlcCounter: Value(hlcCounter),
      hlcNodeId: Value(hlcNodeId),
      dirty: Value(dirty),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      locationCountry: locationCountry == null && nullToAbsent
          ? const Value.absent()
          : Value(locationCountry),
      locationRegion: locationRegion == null && nullToAbsent
          ? const Value.absent()
          : Value(locationRegion),
      purchasingSource: purchasingSource == null && nullToAbsent
          ? const Value.absent()
          : Value(purchasingSource),
      shoppingTransport: shoppingTransport == null && nullToAbsent
          ? const Value.absent()
          : Value(shoppingTransport),
      cookingMethod: cookingMethod == null && nullToAbsent
          ? const Value.absent()
          : Value(cookingMethod),
      foodStorage: foodStorage == null && nullToAbsent
          ? const Value.absent()
          : Value(foodStorage),
      householdSize: householdSize == null && nullToAbsent
          ? const Value.absent()
          : Value(householdSize),
      foodWasteLevel: foodWasteLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(foodWasteLevel),
    );
  }

  factory Co2SettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Co2SettingsRow(
      id: serializer.fromJson<String>(json['id']),
      hlcMillis: serializer.fromJson<BigInt>(json['hlcMillis']),
      hlcCounter: serializer.fromJson<int>(json['hlcCounter']),
      hlcNodeId: serializer.fromJson<String>(json['hlcNodeId']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      locationCountry: serializer.fromJson<String?>(json['locationCountry']),
      locationRegion: serializer.fromJson<String?>(json['locationRegion']),
      purchasingSource: serializer.fromJson<String?>(json['purchasingSource']),
      shoppingTransport: serializer.fromJson<String?>(
        json['shoppingTransport'],
      ),
      cookingMethod: serializer.fromJson<String?>(json['cookingMethod']),
      foodStorage: serializer.fromJson<String?>(json['foodStorage']),
      householdSize: serializer.fromJson<int?>(json['householdSize']),
      foodWasteLevel: serializer.fromJson<String?>(json['foodWasteLevel']),
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
      'locationCountry': serializer.toJson<String?>(locationCountry),
      'locationRegion': serializer.toJson<String?>(locationRegion),
      'purchasingSource': serializer.toJson<String?>(purchasingSource),
      'shoppingTransport': serializer.toJson<String?>(shoppingTransport),
      'cookingMethod': serializer.toJson<String?>(cookingMethod),
      'foodStorage': serializer.toJson<String?>(foodStorage),
      'householdSize': serializer.toJson<int?>(householdSize),
      'foodWasteLevel': serializer.toJson<String?>(foodWasteLevel),
    };
  }

  Co2SettingsRow copyWith({
    String? id,
    BigInt? hlcMillis,
    int? hlcCounter,
    String? hlcNodeId,
    bool? dirty,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> locationCountry = const Value.absent(),
    Value<String?> locationRegion = const Value.absent(),
    Value<String?> purchasingSource = const Value.absent(),
    Value<String?> shoppingTransport = const Value.absent(),
    Value<String?> cookingMethod = const Value.absent(),
    Value<String?> foodStorage = const Value.absent(),
    Value<int?> householdSize = const Value.absent(),
    Value<String?> foodWasteLevel = const Value.absent(),
  }) => Co2SettingsRow(
    id: id ?? this.id,
    hlcMillis: hlcMillis ?? this.hlcMillis,
    hlcCounter: hlcCounter ?? this.hlcCounter,
    hlcNodeId: hlcNodeId ?? this.hlcNodeId,
    dirty: dirty ?? this.dirty,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    locationCountry: locationCountry.present
        ? locationCountry.value
        : this.locationCountry,
    locationRegion: locationRegion.present
        ? locationRegion.value
        : this.locationRegion,
    purchasingSource: purchasingSource.present
        ? purchasingSource.value
        : this.purchasingSource,
    shoppingTransport: shoppingTransport.present
        ? shoppingTransport.value
        : this.shoppingTransport,
    cookingMethod: cookingMethod.present
        ? cookingMethod.value
        : this.cookingMethod,
    foodStorage: foodStorage.present ? foodStorage.value : this.foodStorage,
    householdSize: householdSize.present
        ? householdSize.value
        : this.householdSize,
    foodWasteLevel: foodWasteLevel.present
        ? foodWasteLevel.value
        : this.foodWasteLevel,
  );
  Co2SettingsRow copyWithCompanion(Co2SettingsTableCompanion data) {
    return Co2SettingsRow(
      id: data.id.present ? data.id.value : this.id,
      hlcMillis: data.hlcMillis.present ? data.hlcMillis.value : this.hlcMillis,
      hlcCounter: data.hlcCounter.present
          ? data.hlcCounter.value
          : this.hlcCounter,
      hlcNodeId: data.hlcNodeId.present ? data.hlcNodeId.value : this.hlcNodeId,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      locationCountry: data.locationCountry.present
          ? data.locationCountry.value
          : this.locationCountry,
      locationRegion: data.locationRegion.present
          ? data.locationRegion.value
          : this.locationRegion,
      purchasingSource: data.purchasingSource.present
          ? data.purchasingSource.value
          : this.purchasingSource,
      shoppingTransport: data.shoppingTransport.present
          ? data.shoppingTransport.value
          : this.shoppingTransport,
      cookingMethod: data.cookingMethod.present
          ? data.cookingMethod.value
          : this.cookingMethod,
      foodStorage: data.foodStorage.present
          ? data.foodStorage.value
          : this.foodStorage,
      householdSize: data.householdSize.present
          ? data.householdSize.value
          : this.householdSize,
      foodWasteLevel: data.foodWasteLevel.present
          ? data.foodWasteLevel.value
          : this.foodWasteLevel,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Co2SettingsRow(')
          ..write('id: $id, ')
          ..write('hlcMillis: $hlcMillis, ')
          ..write('hlcCounter: $hlcCounter, ')
          ..write('hlcNodeId: $hlcNodeId, ')
          ..write('dirty: $dirty, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('locationCountry: $locationCountry, ')
          ..write('locationRegion: $locationRegion, ')
          ..write('purchasingSource: $purchasingSource, ')
          ..write('shoppingTransport: $shoppingTransport, ')
          ..write('cookingMethod: $cookingMethod, ')
          ..write('foodStorage: $foodStorage, ')
          ..write('householdSize: $householdSize, ')
          ..write('foodWasteLevel: $foodWasteLevel')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    hlcMillis,
    hlcCounter,
    hlcNodeId,
    dirty,
    deletedAt,
    locationCountry,
    locationRegion,
    purchasingSource,
    shoppingTransport,
    cookingMethod,
    foodStorage,
    householdSize,
    foodWasteLevel,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Co2SettingsRow &&
          other.id == this.id &&
          other.hlcMillis == this.hlcMillis &&
          other.hlcCounter == this.hlcCounter &&
          other.hlcNodeId == this.hlcNodeId &&
          other.dirty == this.dirty &&
          other.deletedAt == this.deletedAt &&
          other.locationCountry == this.locationCountry &&
          other.locationRegion == this.locationRegion &&
          other.purchasingSource == this.purchasingSource &&
          other.shoppingTransport == this.shoppingTransport &&
          other.cookingMethod == this.cookingMethod &&
          other.foodStorage == this.foodStorage &&
          other.householdSize == this.householdSize &&
          other.foodWasteLevel == this.foodWasteLevel);
}

class Co2SettingsTableCompanion extends UpdateCompanion<Co2SettingsRow> {
  final Value<String> id;
  final Value<BigInt> hlcMillis;
  final Value<int> hlcCounter;
  final Value<String> hlcNodeId;
  final Value<bool> dirty;
  final Value<DateTime?> deletedAt;
  final Value<String?> locationCountry;
  final Value<String?> locationRegion;
  final Value<String?> purchasingSource;
  final Value<String?> shoppingTransport;
  final Value<String?> cookingMethod;
  final Value<String?> foodStorage;
  final Value<int?> householdSize;
  final Value<String?> foodWasteLevel;
  final Value<int> rowid;
  const Co2SettingsTableCompanion({
    this.id = const Value.absent(),
    this.hlcMillis = const Value.absent(),
    this.hlcCounter = const Value.absent(),
    this.hlcNodeId = const Value.absent(),
    this.dirty = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.locationCountry = const Value.absent(),
    this.locationRegion = const Value.absent(),
    this.purchasingSource = const Value.absent(),
    this.shoppingTransport = const Value.absent(),
    this.cookingMethod = const Value.absent(),
    this.foodStorage = const Value.absent(),
    this.householdSize = const Value.absent(),
    this.foodWasteLevel = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  Co2SettingsTableCompanion.insert({
    required String id,
    required BigInt hlcMillis,
    required int hlcCounter,
    required String hlcNodeId,
    this.dirty = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.locationCountry = const Value.absent(),
    this.locationRegion = const Value.absent(),
    this.purchasingSource = const Value.absent(),
    this.shoppingTransport = const Value.absent(),
    this.cookingMethod = const Value.absent(),
    this.foodStorage = const Value.absent(),
    this.householdSize = const Value.absent(),
    this.foodWasteLevel = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       hlcMillis = Value(hlcMillis),
       hlcCounter = Value(hlcCounter),
       hlcNodeId = Value(hlcNodeId);
  static Insertable<Co2SettingsRow> custom({
    Expression<String>? id,
    Expression<BigInt>? hlcMillis,
    Expression<int>? hlcCounter,
    Expression<String>? hlcNodeId,
    Expression<bool>? dirty,
    Expression<DateTime>? deletedAt,
    Expression<String>? locationCountry,
    Expression<String>? locationRegion,
    Expression<String>? purchasingSource,
    Expression<String>? shoppingTransport,
    Expression<String>? cookingMethod,
    Expression<String>? foodStorage,
    Expression<int>? householdSize,
    Expression<String>? foodWasteLevel,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hlcMillis != null) 'hlc_millis': hlcMillis,
      if (hlcCounter != null) 'hlc_counter': hlcCounter,
      if (hlcNodeId != null) 'hlc_node_id': hlcNodeId,
      if (dirty != null) 'dirty': dirty,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (locationCountry != null) 'location_country': locationCountry,
      if (locationRegion != null) 'location_region': locationRegion,
      if (purchasingSource != null) 'purchasing_source': purchasingSource,
      if (shoppingTransport != null) 'shopping_transport': shoppingTransport,
      if (cookingMethod != null) 'cooking_method': cookingMethod,
      if (foodStorage != null) 'food_storage': foodStorage,
      if (householdSize != null) 'household_size': householdSize,
      if (foodWasteLevel != null) 'food_waste_level': foodWasteLevel,
      if (rowid != null) 'rowid': rowid,
    });
  }

  Co2SettingsTableCompanion copyWith({
    Value<String>? id,
    Value<BigInt>? hlcMillis,
    Value<int>? hlcCounter,
    Value<String>? hlcNodeId,
    Value<bool>? dirty,
    Value<DateTime?>? deletedAt,
    Value<String?>? locationCountry,
    Value<String?>? locationRegion,
    Value<String?>? purchasingSource,
    Value<String?>? shoppingTransport,
    Value<String?>? cookingMethod,
    Value<String?>? foodStorage,
    Value<int?>? householdSize,
    Value<String?>? foodWasteLevel,
    Value<int>? rowid,
  }) {
    return Co2SettingsTableCompanion(
      id: id ?? this.id,
      hlcMillis: hlcMillis ?? this.hlcMillis,
      hlcCounter: hlcCounter ?? this.hlcCounter,
      hlcNodeId: hlcNodeId ?? this.hlcNodeId,
      dirty: dirty ?? this.dirty,
      deletedAt: deletedAt ?? this.deletedAt,
      locationCountry: locationCountry ?? this.locationCountry,
      locationRegion: locationRegion ?? this.locationRegion,
      purchasingSource: purchasingSource ?? this.purchasingSource,
      shoppingTransport: shoppingTransport ?? this.shoppingTransport,
      cookingMethod: cookingMethod ?? this.cookingMethod,
      foodStorage: foodStorage ?? this.foodStorage,
      householdSize: householdSize ?? this.householdSize,
      foodWasteLevel: foodWasteLevel ?? this.foodWasteLevel,
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
    if (locationCountry.present) {
      map['location_country'] = Variable<String>(locationCountry.value);
    }
    if (locationRegion.present) {
      map['location_region'] = Variable<String>(locationRegion.value);
    }
    if (purchasingSource.present) {
      map['purchasing_source'] = Variable<String>(purchasingSource.value);
    }
    if (shoppingTransport.present) {
      map['shopping_transport'] = Variable<String>(shoppingTransport.value);
    }
    if (cookingMethod.present) {
      map['cooking_method'] = Variable<String>(cookingMethod.value);
    }
    if (foodStorage.present) {
      map['food_storage'] = Variable<String>(foodStorage.value);
    }
    if (householdSize.present) {
      map['household_size'] = Variable<int>(householdSize.value);
    }
    if (foodWasteLevel.present) {
      map['food_waste_level'] = Variable<String>(foodWasteLevel.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('Co2SettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('hlcMillis: $hlcMillis, ')
          ..write('hlcCounter: $hlcCounter, ')
          ..write('hlcNodeId: $hlcNodeId, ')
          ..write('dirty: $dirty, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('locationCountry: $locationCountry, ')
          ..write('locationRegion: $locationRegion, ')
          ..write('purchasingSource: $purchasingSource, ')
          ..write('shoppingTransport: $shoppingTransport, ')
          ..write('cookingMethod: $cookingMethod, ')
          ..write('foodStorage: $foodStorage, ')
          ..write('householdSize: $householdSize, ')
          ..write('foodWasteLevel: $foodWasteLevel, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WeightEntryTableTable extends WeightEntryTable
    with TableInfo<$WeightEntryTableTable, WeightEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeightEntryTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<WeightUnit, String> unit =
      GeneratedColumn<String>(
        'unit',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<WeightUnit>($WeightEntryTableTable.$converterunit);
  static const VerificationMeta _loggedAtMeta = const VerificationMeta(
    'loggedAt',
  );
  @override
  late final GeneratedColumn<DateTime> loggedAt = GeneratedColumn<DateTime>(
    'logged_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    value,
    unit,
    loggedAt,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weight_entry_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeightEntryRow> instance, {
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
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('logged_at')) {
      context.handle(
        _loggedAtMeta,
        loggedAt.isAcceptableOrUnknown(data['logged_at']!, _loggedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_loggedAtMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WeightEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeightEntryRow(
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
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      )!,
      unit: $WeightEntryTableTable.$converterunit.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}unit'],
        )!,
      ),
      loggedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}logged_at'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $WeightEntryTableTable createAlias(String alias) {
    return $WeightEntryTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<WeightUnit, String, String> $converterunit =
      const EnumNameConverter<WeightUnit>(WeightUnit.values);
}

class WeightEntryRow extends DataClass implements Insertable<WeightEntryRow> {
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

  /// The logged weight value, expressed in [unit].
  final double value;

  /// Unit [value] is expressed in. Stored via `textEnum` as
  /// `Enum.name` — append-only, see [WeightUnit].
  final WeightUnit unit;

  /// Wall-clock timestamp of when this weigh-in was logged.
  final DateTime loggedAt;

  /// Optional free-text note attached to this weigh-in.
  final String? note;
  const WeightEntryRow({
    required this.id,
    required this.hlcMillis,
    required this.hlcCounter,
    required this.hlcNodeId,
    required this.dirty,
    this.deletedAt,
    required this.value,
    required this.unit,
    required this.loggedAt,
    this.note,
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
    map['value'] = Variable<double>(value);
    {
      map['unit'] = Variable<String>(
        $WeightEntryTableTable.$converterunit.toSql(unit),
      );
    }
    map['logged_at'] = Variable<DateTime>(loggedAt);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  WeightEntryTableCompanion toCompanion(bool nullToAbsent) {
    return WeightEntryTableCompanion(
      id: Value(id),
      hlcMillis: Value(hlcMillis),
      hlcCounter: Value(hlcCounter),
      hlcNodeId: Value(hlcNodeId),
      dirty: Value(dirty),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      value: Value(value),
      unit: Value(unit),
      loggedAt: Value(loggedAt),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory WeightEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeightEntryRow(
      id: serializer.fromJson<String>(json['id']),
      hlcMillis: serializer.fromJson<BigInt>(json['hlcMillis']),
      hlcCounter: serializer.fromJson<int>(json['hlcCounter']),
      hlcNodeId: serializer.fromJson<String>(json['hlcNodeId']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      value: serializer.fromJson<double>(json['value']),
      unit: $WeightEntryTableTable.$converterunit.fromJson(
        serializer.fromJson<String>(json['unit']),
      ),
      loggedAt: serializer.fromJson<DateTime>(json['loggedAt']),
      note: serializer.fromJson<String?>(json['note']),
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
      'value': serializer.toJson<double>(value),
      'unit': serializer.toJson<String>(
        $WeightEntryTableTable.$converterunit.toJson(unit),
      ),
      'loggedAt': serializer.toJson<DateTime>(loggedAt),
      'note': serializer.toJson<String?>(note),
    };
  }

  WeightEntryRow copyWith({
    String? id,
    BigInt? hlcMillis,
    int? hlcCounter,
    String? hlcNodeId,
    bool? dirty,
    Value<DateTime?> deletedAt = const Value.absent(),
    double? value,
    WeightUnit? unit,
    DateTime? loggedAt,
    Value<String?> note = const Value.absent(),
  }) => WeightEntryRow(
    id: id ?? this.id,
    hlcMillis: hlcMillis ?? this.hlcMillis,
    hlcCounter: hlcCounter ?? this.hlcCounter,
    hlcNodeId: hlcNodeId ?? this.hlcNodeId,
    dirty: dirty ?? this.dirty,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    value: value ?? this.value,
    unit: unit ?? this.unit,
    loggedAt: loggedAt ?? this.loggedAt,
    note: note.present ? note.value : this.note,
  );
  WeightEntryRow copyWithCompanion(WeightEntryTableCompanion data) {
    return WeightEntryRow(
      id: data.id.present ? data.id.value : this.id,
      hlcMillis: data.hlcMillis.present ? data.hlcMillis.value : this.hlcMillis,
      hlcCounter: data.hlcCounter.present
          ? data.hlcCounter.value
          : this.hlcCounter,
      hlcNodeId: data.hlcNodeId.present ? data.hlcNodeId.value : this.hlcNodeId,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      value: data.value.present ? data.value.value : this.value,
      unit: data.unit.present ? data.unit.value : this.unit,
      loggedAt: data.loggedAt.present ? data.loggedAt.value : this.loggedAt,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeightEntryRow(')
          ..write('id: $id, ')
          ..write('hlcMillis: $hlcMillis, ')
          ..write('hlcCounter: $hlcCounter, ')
          ..write('hlcNodeId: $hlcNodeId, ')
          ..write('dirty: $dirty, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('value: $value, ')
          ..write('unit: $unit, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    hlcMillis,
    hlcCounter,
    hlcNodeId,
    dirty,
    deletedAt,
    value,
    unit,
    loggedAt,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeightEntryRow &&
          other.id == this.id &&
          other.hlcMillis == this.hlcMillis &&
          other.hlcCounter == this.hlcCounter &&
          other.hlcNodeId == this.hlcNodeId &&
          other.dirty == this.dirty &&
          other.deletedAt == this.deletedAt &&
          other.value == this.value &&
          other.unit == this.unit &&
          other.loggedAt == this.loggedAt &&
          other.note == this.note);
}

class WeightEntryTableCompanion extends UpdateCompanion<WeightEntryRow> {
  final Value<String> id;
  final Value<BigInt> hlcMillis;
  final Value<int> hlcCounter;
  final Value<String> hlcNodeId;
  final Value<bool> dirty;
  final Value<DateTime?> deletedAt;
  final Value<double> value;
  final Value<WeightUnit> unit;
  final Value<DateTime> loggedAt;
  final Value<String?> note;
  final Value<int> rowid;
  const WeightEntryTableCompanion({
    this.id = const Value.absent(),
    this.hlcMillis = const Value.absent(),
    this.hlcCounter = const Value.absent(),
    this.hlcNodeId = const Value.absent(),
    this.dirty = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.value = const Value.absent(),
    this.unit = const Value.absent(),
    this.loggedAt = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WeightEntryTableCompanion.insert({
    required String id,
    required BigInt hlcMillis,
    required int hlcCounter,
    required String hlcNodeId,
    this.dirty = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required double value,
    required WeightUnit unit,
    required DateTime loggedAt,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       hlcMillis = Value(hlcMillis),
       hlcCounter = Value(hlcCounter),
       hlcNodeId = Value(hlcNodeId),
       value = Value(value),
       unit = Value(unit),
       loggedAt = Value(loggedAt);
  static Insertable<WeightEntryRow> custom({
    Expression<String>? id,
    Expression<BigInt>? hlcMillis,
    Expression<int>? hlcCounter,
    Expression<String>? hlcNodeId,
    Expression<bool>? dirty,
    Expression<DateTime>? deletedAt,
    Expression<double>? value,
    Expression<String>? unit,
    Expression<DateTime>? loggedAt,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hlcMillis != null) 'hlc_millis': hlcMillis,
      if (hlcCounter != null) 'hlc_counter': hlcCounter,
      if (hlcNodeId != null) 'hlc_node_id': hlcNodeId,
      if (dirty != null) 'dirty': dirty,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (value != null) 'value': value,
      if (unit != null) 'unit': unit,
      if (loggedAt != null) 'logged_at': loggedAt,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WeightEntryTableCompanion copyWith({
    Value<String>? id,
    Value<BigInt>? hlcMillis,
    Value<int>? hlcCounter,
    Value<String>? hlcNodeId,
    Value<bool>? dirty,
    Value<DateTime?>? deletedAt,
    Value<double>? value,
    Value<WeightUnit>? unit,
    Value<DateTime>? loggedAt,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return WeightEntryTableCompanion(
      id: id ?? this.id,
      hlcMillis: hlcMillis ?? this.hlcMillis,
      hlcCounter: hlcCounter ?? this.hlcCounter,
      hlcNodeId: hlcNodeId ?? this.hlcNodeId,
      dirty: dirty ?? this.dirty,
      deletedAt: deletedAt ?? this.deletedAt,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      loggedAt: loggedAt ?? this.loggedAt,
      note: note ?? this.note,
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
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(
        $WeightEntryTableTable.$converterunit.toSql(unit.value),
      );
    }
    if (loggedAt.present) {
      map['logged_at'] = Variable<DateTime>(loggedAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeightEntryTableCompanion(')
          ..write('id: $id, ')
          ..write('hlcMillis: $hlcMillis, ')
          ..write('hlcCounter: $hlcCounter, ')
          ..write('hlcNodeId: $hlcNodeId, ')
          ..write('dirty: $dirty, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('value: $value, ')
          ..write('unit: $unit, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WeightSettingsTableTable extends WeightSettingsTable
    with TableInfo<$WeightSettingsTableTable, WeightSettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeightSettingsTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _targetWeightKgMeta = const VerificationMeta(
    'targetWeightKg',
  );
  @override
  late final GeneratedColumn<double> targetWeightKg = GeneratedColumn<double>(
    'target_weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetDateMeta = const VerificationMeta(
    'targetDate',
  );
  @override
  late final GeneratedColumn<DateTime> targetDate = GeneratedColumn<DateTime>(
    'target_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reminderFrequencyMeta = const VerificationMeta(
    'reminderFrequency',
  );
  @override
  late final GeneratedColumn<String> reminderFrequency =
      GeneratedColumn<String>(
        'reminder_frequency',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _reminderWeekdayMeta = const VerificationMeta(
    'reminderWeekday',
  );
  @override
  late final GeneratedColumn<int> reminderWeekday = GeneratedColumn<int>(
    'reminder_weekday',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reminderTimeMeta = const VerificationMeta(
    'reminderTime',
  );
  @override
  late final GeneratedColumn<String> reminderTime = GeneratedColumn<String>(
    'reminder_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reminderEnabledMeta = const VerificationMeta(
    'reminderEnabled',
  );
  @override
  late final GeneratedColumn<bool> reminderEnabled = GeneratedColumn<bool>(
    'reminder_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reminder_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    hlcMillis,
    hlcCounter,
    hlcNodeId,
    dirty,
    deletedAt,
    targetWeightKg,
    targetDate,
    reminderFrequency,
    reminderWeekday,
    reminderTime,
    reminderEnabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weight_settings_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeightSettingsRow> instance, {
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
    if (data.containsKey('target_weight_kg')) {
      context.handle(
        _targetWeightKgMeta,
        targetWeightKg.isAcceptableOrUnknown(
          data['target_weight_kg']!,
          _targetWeightKgMeta,
        ),
      );
    }
    if (data.containsKey('target_date')) {
      context.handle(
        _targetDateMeta,
        targetDate.isAcceptableOrUnknown(data['target_date']!, _targetDateMeta),
      );
    }
    if (data.containsKey('reminder_frequency')) {
      context.handle(
        _reminderFrequencyMeta,
        reminderFrequency.isAcceptableOrUnknown(
          data['reminder_frequency']!,
          _reminderFrequencyMeta,
        ),
      );
    }
    if (data.containsKey('reminder_weekday')) {
      context.handle(
        _reminderWeekdayMeta,
        reminderWeekday.isAcceptableOrUnknown(
          data['reminder_weekday']!,
          _reminderWeekdayMeta,
        ),
      );
    }
    if (data.containsKey('reminder_time')) {
      context.handle(
        _reminderTimeMeta,
        reminderTime.isAcceptableOrUnknown(
          data['reminder_time']!,
          _reminderTimeMeta,
        ),
      );
    }
    if (data.containsKey('reminder_enabled')) {
      context.handle(
        _reminderEnabledMeta,
        reminderEnabled.isAcceptableOrUnknown(
          data['reminder_enabled']!,
          _reminderEnabledMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WeightSettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeightSettingsRow(
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
      targetWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_weight_kg'],
      ),
      targetDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}target_date'],
      ),
      reminderFrequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_frequency'],
      ),
      reminderWeekday: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_weekday'],
      ),
      reminderTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_time'],
      ),
      reminderEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reminder_enabled'],
      )!,
    );
  }

  @override
  $WeightSettingsTableTable createAlias(String alias) {
    return $WeightSettingsTableTable(attachedDatabase, alias);
  }
}

class WeightSettingsRow extends DataClass
    implements Insertable<WeightSettingsRow> {
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

  /// Target weight in kilograms. Always stored in kg; imperial
  /// conversion is an app-layer concern (mirrors
  /// `UserProfileTable.weightKg`'s existing convention).
  final double? targetWeightKg;

  /// Target date for reaching [targetWeightKg].
  final DateTime? targetDate;

  /// How often the user wants a weigh-in reminder.
  /// Values: 'never', 'weekly', 'biweekly', 'monthly', 'custom'.
  final String? reminderFrequency;

  /// Day of week the reminder fires on, 1 (Monday) to 7 (Sunday),
  /// ISO-8601 weekday numbering. Only meaningful when
  /// [reminderFrequency] is `'custom'`.
  final int? reminderWeekday;

  /// Local time the reminder fires at, `'HH:mm'` 24-hour string.
  final String? reminderTime;

  /// Whether the weigh-in reminder is enabled.
  final bool reminderEnabled;
  const WeightSettingsRow({
    required this.id,
    required this.hlcMillis,
    required this.hlcCounter,
    required this.hlcNodeId,
    required this.dirty,
    this.deletedAt,
    this.targetWeightKg,
    this.targetDate,
    this.reminderFrequency,
    this.reminderWeekday,
    this.reminderTime,
    required this.reminderEnabled,
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
    if (!nullToAbsent || targetWeightKg != null) {
      map['target_weight_kg'] = Variable<double>(targetWeightKg);
    }
    if (!nullToAbsent || targetDate != null) {
      map['target_date'] = Variable<DateTime>(targetDate);
    }
    if (!nullToAbsent || reminderFrequency != null) {
      map['reminder_frequency'] = Variable<String>(reminderFrequency);
    }
    if (!nullToAbsent || reminderWeekday != null) {
      map['reminder_weekday'] = Variable<int>(reminderWeekday);
    }
    if (!nullToAbsent || reminderTime != null) {
      map['reminder_time'] = Variable<String>(reminderTime);
    }
    map['reminder_enabled'] = Variable<bool>(reminderEnabled);
    return map;
  }

  WeightSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return WeightSettingsTableCompanion(
      id: Value(id),
      hlcMillis: Value(hlcMillis),
      hlcCounter: Value(hlcCounter),
      hlcNodeId: Value(hlcNodeId),
      dirty: Value(dirty),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      targetWeightKg: targetWeightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(targetWeightKg),
      targetDate: targetDate == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDate),
      reminderFrequency: reminderFrequency == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderFrequency),
      reminderWeekday: reminderWeekday == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderWeekday),
      reminderTime: reminderTime == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderTime),
      reminderEnabled: Value(reminderEnabled),
    );
  }

  factory WeightSettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeightSettingsRow(
      id: serializer.fromJson<String>(json['id']),
      hlcMillis: serializer.fromJson<BigInt>(json['hlcMillis']),
      hlcCounter: serializer.fromJson<int>(json['hlcCounter']),
      hlcNodeId: serializer.fromJson<String>(json['hlcNodeId']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      targetWeightKg: serializer.fromJson<double?>(json['targetWeightKg']),
      targetDate: serializer.fromJson<DateTime?>(json['targetDate']),
      reminderFrequency: serializer.fromJson<String?>(
        json['reminderFrequency'],
      ),
      reminderWeekday: serializer.fromJson<int?>(json['reminderWeekday']),
      reminderTime: serializer.fromJson<String?>(json['reminderTime']),
      reminderEnabled: serializer.fromJson<bool>(json['reminderEnabled']),
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
      'targetWeightKg': serializer.toJson<double?>(targetWeightKg),
      'targetDate': serializer.toJson<DateTime?>(targetDate),
      'reminderFrequency': serializer.toJson<String?>(reminderFrequency),
      'reminderWeekday': serializer.toJson<int?>(reminderWeekday),
      'reminderTime': serializer.toJson<String?>(reminderTime),
      'reminderEnabled': serializer.toJson<bool>(reminderEnabled),
    };
  }

  WeightSettingsRow copyWith({
    String? id,
    BigInt? hlcMillis,
    int? hlcCounter,
    String? hlcNodeId,
    bool? dirty,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<double?> targetWeightKg = const Value.absent(),
    Value<DateTime?> targetDate = const Value.absent(),
    Value<String?> reminderFrequency = const Value.absent(),
    Value<int?> reminderWeekday = const Value.absent(),
    Value<String?> reminderTime = const Value.absent(),
    bool? reminderEnabled,
  }) => WeightSettingsRow(
    id: id ?? this.id,
    hlcMillis: hlcMillis ?? this.hlcMillis,
    hlcCounter: hlcCounter ?? this.hlcCounter,
    hlcNodeId: hlcNodeId ?? this.hlcNodeId,
    dirty: dirty ?? this.dirty,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    targetWeightKg: targetWeightKg.present
        ? targetWeightKg.value
        : this.targetWeightKg,
    targetDate: targetDate.present ? targetDate.value : this.targetDate,
    reminderFrequency: reminderFrequency.present
        ? reminderFrequency.value
        : this.reminderFrequency,
    reminderWeekday: reminderWeekday.present
        ? reminderWeekday.value
        : this.reminderWeekday,
    reminderTime: reminderTime.present ? reminderTime.value : this.reminderTime,
    reminderEnabled: reminderEnabled ?? this.reminderEnabled,
  );
  WeightSettingsRow copyWithCompanion(WeightSettingsTableCompanion data) {
    return WeightSettingsRow(
      id: data.id.present ? data.id.value : this.id,
      hlcMillis: data.hlcMillis.present ? data.hlcMillis.value : this.hlcMillis,
      hlcCounter: data.hlcCounter.present
          ? data.hlcCounter.value
          : this.hlcCounter,
      hlcNodeId: data.hlcNodeId.present ? data.hlcNodeId.value : this.hlcNodeId,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      targetWeightKg: data.targetWeightKg.present
          ? data.targetWeightKg.value
          : this.targetWeightKg,
      targetDate: data.targetDate.present
          ? data.targetDate.value
          : this.targetDate,
      reminderFrequency: data.reminderFrequency.present
          ? data.reminderFrequency.value
          : this.reminderFrequency,
      reminderWeekday: data.reminderWeekday.present
          ? data.reminderWeekday.value
          : this.reminderWeekday,
      reminderTime: data.reminderTime.present
          ? data.reminderTime.value
          : this.reminderTime,
      reminderEnabled: data.reminderEnabled.present
          ? data.reminderEnabled.value
          : this.reminderEnabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeightSettingsRow(')
          ..write('id: $id, ')
          ..write('hlcMillis: $hlcMillis, ')
          ..write('hlcCounter: $hlcCounter, ')
          ..write('hlcNodeId: $hlcNodeId, ')
          ..write('dirty: $dirty, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('targetWeightKg: $targetWeightKg, ')
          ..write('targetDate: $targetDate, ')
          ..write('reminderFrequency: $reminderFrequency, ')
          ..write('reminderWeekday: $reminderWeekday, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('reminderEnabled: $reminderEnabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    hlcMillis,
    hlcCounter,
    hlcNodeId,
    dirty,
    deletedAt,
    targetWeightKg,
    targetDate,
    reminderFrequency,
    reminderWeekday,
    reminderTime,
    reminderEnabled,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeightSettingsRow &&
          other.id == this.id &&
          other.hlcMillis == this.hlcMillis &&
          other.hlcCounter == this.hlcCounter &&
          other.hlcNodeId == this.hlcNodeId &&
          other.dirty == this.dirty &&
          other.deletedAt == this.deletedAt &&
          other.targetWeightKg == this.targetWeightKg &&
          other.targetDate == this.targetDate &&
          other.reminderFrequency == this.reminderFrequency &&
          other.reminderWeekday == this.reminderWeekday &&
          other.reminderTime == this.reminderTime &&
          other.reminderEnabled == this.reminderEnabled);
}

class WeightSettingsTableCompanion extends UpdateCompanion<WeightSettingsRow> {
  final Value<String> id;
  final Value<BigInt> hlcMillis;
  final Value<int> hlcCounter;
  final Value<String> hlcNodeId;
  final Value<bool> dirty;
  final Value<DateTime?> deletedAt;
  final Value<double?> targetWeightKg;
  final Value<DateTime?> targetDate;
  final Value<String?> reminderFrequency;
  final Value<int?> reminderWeekday;
  final Value<String?> reminderTime;
  final Value<bool> reminderEnabled;
  final Value<int> rowid;
  const WeightSettingsTableCompanion({
    this.id = const Value.absent(),
    this.hlcMillis = const Value.absent(),
    this.hlcCounter = const Value.absent(),
    this.hlcNodeId = const Value.absent(),
    this.dirty = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.targetWeightKg = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.reminderFrequency = const Value.absent(),
    this.reminderWeekday = const Value.absent(),
    this.reminderTime = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WeightSettingsTableCompanion.insert({
    required String id,
    required BigInt hlcMillis,
    required int hlcCounter,
    required String hlcNodeId,
    this.dirty = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.targetWeightKg = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.reminderFrequency = const Value.absent(),
    this.reminderWeekday = const Value.absent(),
    this.reminderTime = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       hlcMillis = Value(hlcMillis),
       hlcCounter = Value(hlcCounter),
       hlcNodeId = Value(hlcNodeId);
  static Insertable<WeightSettingsRow> custom({
    Expression<String>? id,
    Expression<BigInt>? hlcMillis,
    Expression<int>? hlcCounter,
    Expression<String>? hlcNodeId,
    Expression<bool>? dirty,
    Expression<DateTime>? deletedAt,
    Expression<double>? targetWeightKg,
    Expression<DateTime>? targetDate,
    Expression<String>? reminderFrequency,
    Expression<int>? reminderWeekday,
    Expression<String>? reminderTime,
    Expression<bool>? reminderEnabled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hlcMillis != null) 'hlc_millis': hlcMillis,
      if (hlcCounter != null) 'hlc_counter': hlcCounter,
      if (hlcNodeId != null) 'hlc_node_id': hlcNodeId,
      if (dirty != null) 'dirty': dirty,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (targetWeightKg != null) 'target_weight_kg': targetWeightKg,
      if (targetDate != null) 'target_date': targetDate,
      if (reminderFrequency != null) 'reminder_frequency': reminderFrequency,
      if (reminderWeekday != null) 'reminder_weekday': reminderWeekday,
      if (reminderTime != null) 'reminder_time': reminderTime,
      if (reminderEnabled != null) 'reminder_enabled': reminderEnabled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WeightSettingsTableCompanion copyWith({
    Value<String>? id,
    Value<BigInt>? hlcMillis,
    Value<int>? hlcCounter,
    Value<String>? hlcNodeId,
    Value<bool>? dirty,
    Value<DateTime?>? deletedAt,
    Value<double?>? targetWeightKg,
    Value<DateTime?>? targetDate,
    Value<String?>? reminderFrequency,
    Value<int?>? reminderWeekday,
    Value<String?>? reminderTime,
    Value<bool>? reminderEnabled,
    Value<int>? rowid,
  }) {
    return WeightSettingsTableCompanion(
      id: id ?? this.id,
      hlcMillis: hlcMillis ?? this.hlcMillis,
      hlcCounter: hlcCounter ?? this.hlcCounter,
      hlcNodeId: hlcNodeId ?? this.hlcNodeId,
      dirty: dirty ?? this.dirty,
      deletedAt: deletedAt ?? this.deletedAt,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      targetDate: targetDate ?? this.targetDate,
      reminderFrequency: reminderFrequency ?? this.reminderFrequency,
      reminderWeekday: reminderWeekday ?? this.reminderWeekday,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
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
    if (targetWeightKg.present) {
      map['target_weight_kg'] = Variable<double>(targetWeightKg.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<DateTime>(targetDate.value);
    }
    if (reminderFrequency.present) {
      map['reminder_frequency'] = Variable<String>(reminderFrequency.value);
    }
    if (reminderWeekday.present) {
      map['reminder_weekday'] = Variable<int>(reminderWeekday.value);
    }
    if (reminderTime.present) {
      map['reminder_time'] = Variable<String>(reminderTime.value);
    }
    if (reminderEnabled.present) {
      map['reminder_enabled'] = Variable<bool>(reminderEnabled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeightSettingsTableCompanion(')
          ..write('id: $id, ')
          ..write('hlcMillis: $hlcMillis, ')
          ..write('hlcCounter: $hlcCounter, ')
          ..write('hlcNodeId: $hlcNodeId, ')
          ..write('dirty: $dirty, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('targetWeightKg: $targetWeightKg, ')
          ..write('targetDate: $targetDate, ')
          ..write('reminderFrequency: $reminderFrequency, ')
          ..write('reminderWeekday: $reminderWeekday, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotificationPrefsTableTable extends NotificationPrefsTable
    with TableInfo<$NotificationPrefsTableTable, NotificationPrefsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationPrefsTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _breakfastEnabledMeta = const VerificationMeta(
    'breakfastEnabled',
  );
  @override
  late final GeneratedColumn<bool> breakfastEnabled = GeneratedColumn<bool>(
    'breakfast_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("breakfast_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _breakfastTimeMeta = const VerificationMeta(
    'breakfastTime',
  );
  @override
  late final GeneratedColumn<String> breakfastTime = GeneratedColumn<String>(
    'breakfast_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lunchEnabledMeta = const VerificationMeta(
    'lunchEnabled',
  );
  @override
  late final GeneratedColumn<bool> lunchEnabled = GeneratedColumn<bool>(
    'lunch_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("lunch_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lunchTimeMeta = const VerificationMeta(
    'lunchTime',
  );
  @override
  late final GeneratedColumn<String> lunchTime = GeneratedColumn<String>(
    'lunch_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dinnerEnabledMeta = const VerificationMeta(
    'dinnerEnabled',
  );
  @override
  late final GeneratedColumn<bool> dinnerEnabled = GeneratedColumn<bool>(
    'dinner_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dinner_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dinnerTimeMeta = const VerificationMeta(
    'dinnerTime',
  );
  @override
  late final GeneratedColumn<String> dinnerTime = GeneratedColumn<String>(
    'dinner_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _snackEnabledMeta = const VerificationMeta(
    'snackEnabled',
  );
  @override
  late final GeneratedColumn<bool> snackEnabled = GeneratedColumn<bool>(
    'snack_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("snack_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _snackTimeMeta = const VerificationMeta(
    'snackTime',
  );
  @override
  late final GeneratedColumn<String> snackTime = GeneratedColumn<String>(
    'snack_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    breakfastEnabled,
    breakfastTime,
    lunchEnabled,
    lunchTime,
    dinnerEnabled,
    dinnerTime,
    snackEnabled,
    snackTime,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notification_prefs_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotificationPrefsRow> instance, {
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
    if (data.containsKey('breakfast_enabled')) {
      context.handle(
        _breakfastEnabledMeta,
        breakfastEnabled.isAcceptableOrUnknown(
          data['breakfast_enabled']!,
          _breakfastEnabledMeta,
        ),
      );
    }
    if (data.containsKey('breakfast_time')) {
      context.handle(
        _breakfastTimeMeta,
        breakfastTime.isAcceptableOrUnknown(
          data['breakfast_time']!,
          _breakfastTimeMeta,
        ),
      );
    }
    if (data.containsKey('lunch_enabled')) {
      context.handle(
        _lunchEnabledMeta,
        lunchEnabled.isAcceptableOrUnknown(
          data['lunch_enabled']!,
          _lunchEnabledMeta,
        ),
      );
    }
    if (data.containsKey('lunch_time')) {
      context.handle(
        _lunchTimeMeta,
        lunchTime.isAcceptableOrUnknown(data['lunch_time']!, _lunchTimeMeta),
      );
    }
    if (data.containsKey('dinner_enabled')) {
      context.handle(
        _dinnerEnabledMeta,
        dinnerEnabled.isAcceptableOrUnknown(
          data['dinner_enabled']!,
          _dinnerEnabledMeta,
        ),
      );
    }
    if (data.containsKey('dinner_time')) {
      context.handle(
        _dinnerTimeMeta,
        dinnerTime.isAcceptableOrUnknown(data['dinner_time']!, _dinnerTimeMeta),
      );
    }
    if (data.containsKey('snack_enabled')) {
      context.handle(
        _snackEnabledMeta,
        snackEnabled.isAcceptableOrUnknown(
          data['snack_enabled']!,
          _snackEnabledMeta,
        ),
      );
    }
    if (data.containsKey('snack_time')) {
      context.handle(
        _snackTimeMeta,
        snackTime.isAcceptableOrUnknown(data['snack_time']!, _snackTimeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotificationPrefsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationPrefsRow(
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
      breakfastEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}breakfast_enabled'],
      )!,
      breakfastTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}breakfast_time'],
      ),
      lunchEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}lunch_enabled'],
      )!,
      lunchTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lunch_time'],
      ),
      dinnerEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dinner_enabled'],
      )!,
      dinnerTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dinner_time'],
      ),
      snackEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}snack_enabled'],
      )!,
      snackTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snack_time'],
      ),
    );
  }

  @override
  $NotificationPrefsTableTable createAlias(String alias) {
    return $NotificationPrefsTableTable(attachedDatabase, alias);
  }
}

class NotificationPrefsRow extends DataClass
    implements Insertable<NotificationPrefsRow> {
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

  /// Whether the breakfast reminder is enabled.
  final bool breakfastEnabled;

  /// Local time the breakfast reminder fires at, `'HH:mm'`.
  final String? breakfastTime;

  /// Whether the lunch reminder is enabled.
  final bool lunchEnabled;

  /// Local time the lunch reminder fires at, `'HH:mm'`.
  final String? lunchTime;

  /// Whether the dinner reminder is enabled.
  final bool dinnerEnabled;

  /// Local time the dinner reminder fires at, `'HH:mm'`.
  final String? dinnerTime;

  /// Whether the snack reminder is enabled.
  final bool snackEnabled;

  /// Local time the snack reminder fires at, `'HH:mm'`.
  final String? snackTime;
  const NotificationPrefsRow({
    required this.id,
    required this.hlcMillis,
    required this.hlcCounter,
    required this.hlcNodeId,
    required this.dirty,
    this.deletedAt,
    required this.breakfastEnabled,
    this.breakfastTime,
    required this.lunchEnabled,
    this.lunchTime,
    required this.dinnerEnabled,
    this.dinnerTime,
    required this.snackEnabled,
    this.snackTime,
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
    map['breakfast_enabled'] = Variable<bool>(breakfastEnabled);
    if (!nullToAbsent || breakfastTime != null) {
      map['breakfast_time'] = Variable<String>(breakfastTime);
    }
    map['lunch_enabled'] = Variable<bool>(lunchEnabled);
    if (!nullToAbsent || lunchTime != null) {
      map['lunch_time'] = Variable<String>(lunchTime);
    }
    map['dinner_enabled'] = Variable<bool>(dinnerEnabled);
    if (!nullToAbsent || dinnerTime != null) {
      map['dinner_time'] = Variable<String>(dinnerTime);
    }
    map['snack_enabled'] = Variable<bool>(snackEnabled);
    if (!nullToAbsent || snackTime != null) {
      map['snack_time'] = Variable<String>(snackTime);
    }
    return map;
  }

  NotificationPrefsTableCompanion toCompanion(bool nullToAbsent) {
    return NotificationPrefsTableCompanion(
      id: Value(id),
      hlcMillis: Value(hlcMillis),
      hlcCounter: Value(hlcCounter),
      hlcNodeId: Value(hlcNodeId),
      dirty: Value(dirty),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      breakfastEnabled: Value(breakfastEnabled),
      breakfastTime: breakfastTime == null && nullToAbsent
          ? const Value.absent()
          : Value(breakfastTime),
      lunchEnabled: Value(lunchEnabled),
      lunchTime: lunchTime == null && nullToAbsent
          ? const Value.absent()
          : Value(lunchTime),
      dinnerEnabled: Value(dinnerEnabled),
      dinnerTime: dinnerTime == null && nullToAbsent
          ? const Value.absent()
          : Value(dinnerTime),
      snackEnabled: Value(snackEnabled),
      snackTime: snackTime == null && nullToAbsent
          ? const Value.absent()
          : Value(snackTime),
    );
  }

  factory NotificationPrefsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationPrefsRow(
      id: serializer.fromJson<String>(json['id']),
      hlcMillis: serializer.fromJson<BigInt>(json['hlcMillis']),
      hlcCounter: serializer.fromJson<int>(json['hlcCounter']),
      hlcNodeId: serializer.fromJson<String>(json['hlcNodeId']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      breakfastEnabled: serializer.fromJson<bool>(json['breakfastEnabled']),
      breakfastTime: serializer.fromJson<String?>(json['breakfastTime']),
      lunchEnabled: serializer.fromJson<bool>(json['lunchEnabled']),
      lunchTime: serializer.fromJson<String?>(json['lunchTime']),
      dinnerEnabled: serializer.fromJson<bool>(json['dinnerEnabled']),
      dinnerTime: serializer.fromJson<String?>(json['dinnerTime']),
      snackEnabled: serializer.fromJson<bool>(json['snackEnabled']),
      snackTime: serializer.fromJson<String?>(json['snackTime']),
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
      'breakfastEnabled': serializer.toJson<bool>(breakfastEnabled),
      'breakfastTime': serializer.toJson<String?>(breakfastTime),
      'lunchEnabled': serializer.toJson<bool>(lunchEnabled),
      'lunchTime': serializer.toJson<String?>(lunchTime),
      'dinnerEnabled': serializer.toJson<bool>(dinnerEnabled),
      'dinnerTime': serializer.toJson<String?>(dinnerTime),
      'snackEnabled': serializer.toJson<bool>(snackEnabled),
      'snackTime': serializer.toJson<String?>(snackTime),
    };
  }

  NotificationPrefsRow copyWith({
    String? id,
    BigInt? hlcMillis,
    int? hlcCounter,
    String? hlcNodeId,
    bool? dirty,
    Value<DateTime?> deletedAt = const Value.absent(),
    bool? breakfastEnabled,
    Value<String?> breakfastTime = const Value.absent(),
    bool? lunchEnabled,
    Value<String?> lunchTime = const Value.absent(),
    bool? dinnerEnabled,
    Value<String?> dinnerTime = const Value.absent(),
    bool? snackEnabled,
    Value<String?> snackTime = const Value.absent(),
  }) => NotificationPrefsRow(
    id: id ?? this.id,
    hlcMillis: hlcMillis ?? this.hlcMillis,
    hlcCounter: hlcCounter ?? this.hlcCounter,
    hlcNodeId: hlcNodeId ?? this.hlcNodeId,
    dirty: dirty ?? this.dirty,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    breakfastEnabled: breakfastEnabled ?? this.breakfastEnabled,
    breakfastTime: breakfastTime.present
        ? breakfastTime.value
        : this.breakfastTime,
    lunchEnabled: lunchEnabled ?? this.lunchEnabled,
    lunchTime: lunchTime.present ? lunchTime.value : this.lunchTime,
    dinnerEnabled: dinnerEnabled ?? this.dinnerEnabled,
    dinnerTime: dinnerTime.present ? dinnerTime.value : this.dinnerTime,
    snackEnabled: snackEnabled ?? this.snackEnabled,
    snackTime: snackTime.present ? snackTime.value : this.snackTime,
  );
  NotificationPrefsRow copyWithCompanion(NotificationPrefsTableCompanion data) {
    return NotificationPrefsRow(
      id: data.id.present ? data.id.value : this.id,
      hlcMillis: data.hlcMillis.present ? data.hlcMillis.value : this.hlcMillis,
      hlcCounter: data.hlcCounter.present
          ? data.hlcCounter.value
          : this.hlcCounter,
      hlcNodeId: data.hlcNodeId.present ? data.hlcNodeId.value : this.hlcNodeId,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      breakfastEnabled: data.breakfastEnabled.present
          ? data.breakfastEnabled.value
          : this.breakfastEnabled,
      breakfastTime: data.breakfastTime.present
          ? data.breakfastTime.value
          : this.breakfastTime,
      lunchEnabled: data.lunchEnabled.present
          ? data.lunchEnabled.value
          : this.lunchEnabled,
      lunchTime: data.lunchTime.present ? data.lunchTime.value : this.lunchTime,
      dinnerEnabled: data.dinnerEnabled.present
          ? data.dinnerEnabled.value
          : this.dinnerEnabled,
      dinnerTime: data.dinnerTime.present
          ? data.dinnerTime.value
          : this.dinnerTime,
      snackEnabled: data.snackEnabled.present
          ? data.snackEnabled.value
          : this.snackEnabled,
      snackTime: data.snackTime.present ? data.snackTime.value : this.snackTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationPrefsRow(')
          ..write('id: $id, ')
          ..write('hlcMillis: $hlcMillis, ')
          ..write('hlcCounter: $hlcCounter, ')
          ..write('hlcNodeId: $hlcNodeId, ')
          ..write('dirty: $dirty, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('breakfastEnabled: $breakfastEnabled, ')
          ..write('breakfastTime: $breakfastTime, ')
          ..write('lunchEnabled: $lunchEnabled, ')
          ..write('lunchTime: $lunchTime, ')
          ..write('dinnerEnabled: $dinnerEnabled, ')
          ..write('dinnerTime: $dinnerTime, ')
          ..write('snackEnabled: $snackEnabled, ')
          ..write('snackTime: $snackTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    hlcMillis,
    hlcCounter,
    hlcNodeId,
    dirty,
    deletedAt,
    breakfastEnabled,
    breakfastTime,
    lunchEnabled,
    lunchTime,
    dinnerEnabled,
    dinnerTime,
    snackEnabled,
    snackTime,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationPrefsRow &&
          other.id == this.id &&
          other.hlcMillis == this.hlcMillis &&
          other.hlcCounter == this.hlcCounter &&
          other.hlcNodeId == this.hlcNodeId &&
          other.dirty == this.dirty &&
          other.deletedAt == this.deletedAt &&
          other.breakfastEnabled == this.breakfastEnabled &&
          other.breakfastTime == this.breakfastTime &&
          other.lunchEnabled == this.lunchEnabled &&
          other.lunchTime == this.lunchTime &&
          other.dinnerEnabled == this.dinnerEnabled &&
          other.dinnerTime == this.dinnerTime &&
          other.snackEnabled == this.snackEnabled &&
          other.snackTime == this.snackTime);
}

class NotificationPrefsTableCompanion
    extends UpdateCompanion<NotificationPrefsRow> {
  final Value<String> id;
  final Value<BigInt> hlcMillis;
  final Value<int> hlcCounter;
  final Value<String> hlcNodeId;
  final Value<bool> dirty;
  final Value<DateTime?> deletedAt;
  final Value<bool> breakfastEnabled;
  final Value<String?> breakfastTime;
  final Value<bool> lunchEnabled;
  final Value<String?> lunchTime;
  final Value<bool> dinnerEnabled;
  final Value<String?> dinnerTime;
  final Value<bool> snackEnabled;
  final Value<String?> snackTime;
  final Value<int> rowid;
  const NotificationPrefsTableCompanion({
    this.id = const Value.absent(),
    this.hlcMillis = const Value.absent(),
    this.hlcCounter = const Value.absent(),
    this.hlcNodeId = const Value.absent(),
    this.dirty = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.breakfastEnabled = const Value.absent(),
    this.breakfastTime = const Value.absent(),
    this.lunchEnabled = const Value.absent(),
    this.lunchTime = const Value.absent(),
    this.dinnerEnabled = const Value.absent(),
    this.dinnerTime = const Value.absent(),
    this.snackEnabled = const Value.absent(),
    this.snackTime = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotificationPrefsTableCompanion.insert({
    required String id,
    required BigInt hlcMillis,
    required int hlcCounter,
    required String hlcNodeId,
    this.dirty = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.breakfastEnabled = const Value.absent(),
    this.breakfastTime = const Value.absent(),
    this.lunchEnabled = const Value.absent(),
    this.lunchTime = const Value.absent(),
    this.dinnerEnabled = const Value.absent(),
    this.dinnerTime = const Value.absent(),
    this.snackEnabled = const Value.absent(),
    this.snackTime = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       hlcMillis = Value(hlcMillis),
       hlcCounter = Value(hlcCounter),
       hlcNodeId = Value(hlcNodeId);
  static Insertable<NotificationPrefsRow> custom({
    Expression<String>? id,
    Expression<BigInt>? hlcMillis,
    Expression<int>? hlcCounter,
    Expression<String>? hlcNodeId,
    Expression<bool>? dirty,
    Expression<DateTime>? deletedAt,
    Expression<bool>? breakfastEnabled,
    Expression<String>? breakfastTime,
    Expression<bool>? lunchEnabled,
    Expression<String>? lunchTime,
    Expression<bool>? dinnerEnabled,
    Expression<String>? dinnerTime,
    Expression<bool>? snackEnabled,
    Expression<String>? snackTime,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hlcMillis != null) 'hlc_millis': hlcMillis,
      if (hlcCounter != null) 'hlc_counter': hlcCounter,
      if (hlcNodeId != null) 'hlc_node_id': hlcNodeId,
      if (dirty != null) 'dirty': dirty,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (breakfastEnabled != null) 'breakfast_enabled': breakfastEnabled,
      if (breakfastTime != null) 'breakfast_time': breakfastTime,
      if (lunchEnabled != null) 'lunch_enabled': lunchEnabled,
      if (lunchTime != null) 'lunch_time': lunchTime,
      if (dinnerEnabled != null) 'dinner_enabled': dinnerEnabled,
      if (dinnerTime != null) 'dinner_time': dinnerTime,
      if (snackEnabled != null) 'snack_enabled': snackEnabled,
      if (snackTime != null) 'snack_time': snackTime,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotificationPrefsTableCompanion copyWith({
    Value<String>? id,
    Value<BigInt>? hlcMillis,
    Value<int>? hlcCounter,
    Value<String>? hlcNodeId,
    Value<bool>? dirty,
    Value<DateTime?>? deletedAt,
    Value<bool>? breakfastEnabled,
    Value<String?>? breakfastTime,
    Value<bool>? lunchEnabled,
    Value<String?>? lunchTime,
    Value<bool>? dinnerEnabled,
    Value<String?>? dinnerTime,
    Value<bool>? snackEnabled,
    Value<String?>? snackTime,
    Value<int>? rowid,
  }) {
    return NotificationPrefsTableCompanion(
      id: id ?? this.id,
      hlcMillis: hlcMillis ?? this.hlcMillis,
      hlcCounter: hlcCounter ?? this.hlcCounter,
      hlcNodeId: hlcNodeId ?? this.hlcNodeId,
      dirty: dirty ?? this.dirty,
      deletedAt: deletedAt ?? this.deletedAt,
      breakfastEnabled: breakfastEnabled ?? this.breakfastEnabled,
      breakfastTime: breakfastTime ?? this.breakfastTime,
      lunchEnabled: lunchEnabled ?? this.lunchEnabled,
      lunchTime: lunchTime ?? this.lunchTime,
      dinnerEnabled: dinnerEnabled ?? this.dinnerEnabled,
      dinnerTime: dinnerTime ?? this.dinnerTime,
      snackEnabled: snackEnabled ?? this.snackEnabled,
      snackTime: snackTime ?? this.snackTime,
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
    if (breakfastEnabled.present) {
      map['breakfast_enabled'] = Variable<bool>(breakfastEnabled.value);
    }
    if (breakfastTime.present) {
      map['breakfast_time'] = Variable<String>(breakfastTime.value);
    }
    if (lunchEnabled.present) {
      map['lunch_enabled'] = Variable<bool>(lunchEnabled.value);
    }
    if (lunchTime.present) {
      map['lunch_time'] = Variable<String>(lunchTime.value);
    }
    if (dinnerEnabled.present) {
      map['dinner_enabled'] = Variable<bool>(dinnerEnabled.value);
    }
    if (dinnerTime.present) {
      map['dinner_time'] = Variable<String>(dinnerTime.value);
    }
    if (snackEnabled.present) {
      map['snack_enabled'] = Variable<bool>(snackEnabled.value);
    }
    if (snackTime.present) {
      map['snack_time'] = Variable<String>(snackTime.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationPrefsTableCompanion(')
          ..write('id: $id, ')
          ..write('hlcMillis: $hlcMillis, ')
          ..write('hlcCounter: $hlcCounter, ')
          ..write('hlcNodeId: $hlcNodeId, ')
          ..write('dirty: $dirty, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('breakfastEnabled: $breakfastEnabled, ')
          ..write('breakfastTime: $breakfastTime, ')
          ..write('lunchEnabled: $lunchEnabled, ')
          ..write('lunchTime: $lunchTime, ')
          ..write('dinnerEnabled: $dinnerEnabled, ')
          ..write('dinnerTime: $dinnerTime, ')
          ..write('snackEnabled: $snackEnabled, ')
          ..write('snackTime: $snackTime, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BackupMetadataTableTable extends BackupMetadataTable
    with TableInfo<$BackupMetadataTableTable, BackupMetadataRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BackupMetadataTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _autoBackupFrequencyMeta =
      const VerificationMeta('autoBackupFrequency');
  @override
  late final GeneratedColumn<String> autoBackupFrequency =
      GeneratedColumn<String>(
        'auto_backup_frequency',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('off'),
      );
  static const VerificationMeta _lastBackupAtMeta = const VerificationMeta(
    'lastBackupAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastBackupAt = GeneratedColumn<DateTime>(
    'last_backup_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastBackupPathMeta = const VerificationMeta(
    'lastBackupPath',
  );
  @override
  late final GeneratedColumn<String> lastBackupPath = GeneratedColumn<String>(
    'last_backup_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    autoBackupFrequency,
    lastBackupAt,
    lastBackupPath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'backup_metadata_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<BackupMetadataRow> instance, {
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
    if (data.containsKey('auto_backup_frequency')) {
      context.handle(
        _autoBackupFrequencyMeta,
        autoBackupFrequency.isAcceptableOrUnknown(
          data['auto_backup_frequency']!,
          _autoBackupFrequencyMeta,
        ),
      );
    }
    if (data.containsKey('last_backup_at')) {
      context.handle(
        _lastBackupAtMeta,
        lastBackupAt.isAcceptableOrUnknown(
          data['last_backup_at']!,
          _lastBackupAtMeta,
        ),
      );
    }
    if (data.containsKey('last_backup_path')) {
      context.handle(
        _lastBackupPathMeta,
        lastBackupPath.isAcceptableOrUnknown(
          data['last_backup_path']!,
          _lastBackupPathMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BackupMetadataRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BackupMetadataRow(
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
      autoBackupFrequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}auto_backup_frequency'],
      )!,
      lastBackupAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_backup_at'],
      ),
      lastBackupPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_backup_path'],
      ),
    );
  }

  @override
  $BackupMetadataTableTable createAlias(String alias) {
    return $BackupMetadataTableTable(attachedDatabase, alias);
  }
}

class BackupMetadataRow extends DataClass
    implements Insertable<BackupMetadataRow> {
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

  /// How often automatic backups run.
  /// Values: 'off', 'daily', 'weekly'.
  final String autoBackupFrequency;

  /// Wall-clock timestamp of the most recent successful backup.
  final DateTime? lastBackupAt;

  /// Path to the most recent backup file, within the app's own
  /// documents directory — never a user-chosen external path.
  final String? lastBackupPath;
  const BackupMetadataRow({
    required this.id,
    required this.hlcMillis,
    required this.hlcCounter,
    required this.hlcNodeId,
    required this.dirty,
    this.deletedAt,
    required this.autoBackupFrequency,
    this.lastBackupAt,
    this.lastBackupPath,
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
    map['auto_backup_frequency'] = Variable<String>(autoBackupFrequency);
    if (!nullToAbsent || lastBackupAt != null) {
      map['last_backup_at'] = Variable<DateTime>(lastBackupAt);
    }
    if (!nullToAbsent || lastBackupPath != null) {
      map['last_backup_path'] = Variable<String>(lastBackupPath);
    }
    return map;
  }

  BackupMetadataTableCompanion toCompanion(bool nullToAbsent) {
    return BackupMetadataTableCompanion(
      id: Value(id),
      hlcMillis: Value(hlcMillis),
      hlcCounter: Value(hlcCounter),
      hlcNodeId: Value(hlcNodeId),
      dirty: Value(dirty),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      autoBackupFrequency: Value(autoBackupFrequency),
      lastBackupAt: lastBackupAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastBackupAt),
      lastBackupPath: lastBackupPath == null && nullToAbsent
          ? const Value.absent()
          : Value(lastBackupPath),
    );
  }

  factory BackupMetadataRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BackupMetadataRow(
      id: serializer.fromJson<String>(json['id']),
      hlcMillis: serializer.fromJson<BigInt>(json['hlcMillis']),
      hlcCounter: serializer.fromJson<int>(json['hlcCounter']),
      hlcNodeId: serializer.fromJson<String>(json['hlcNodeId']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      autoBackupFrequency: serializer.fromJson<String>(
        json['autoBackupFrequency'],
      ),
      lastBackupAt: serializer.fromJson<DateTime?>(json['lastBackupAt']),
      lastBackupPath: serializer.fromJson<String?>(json['lastBackupPath']),
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
      'autoBackupFrequency': serializer.toJson<String>(autoBackupFrequency),
      'lastBackupAt': serializer.toJson<DateTime?>(lastBackupAt),
      'lastBackupPath': serializer.toJson<String?>(lastBackupPath),
    };
  }

  BackupMetadataRow copyWith({
    String? id,
    BigInt? hlcMillis,
    int? hlcCounter,
    String? hlcNodeId,
    bool? dirty,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? autoBackupFrequency,
    Value<DateTime?> lastBackupAt = const Value.absent(),
    Value<String?> lastBackupPath = const Value.absent(),
  }) => BackupMetadataRow(
    id: id ?? this.id,
    hlcMillis: hlcMillis ?? this.hlcMillis,
    hlcCounter: hlcCounter ?? this.hlcCounter,
    hlcNodeId: hlcNodeId ?? this.hlcNodeId,
    dirty: dirty ?? this.dirty,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    autoBackupFrequency: autoBackupFrequency ?? this.autoBackupFrequency,
    lastBackupAt: lastBackupAt.present ? lastBackupAt.value : this.lastBackupAt,
    lastBackupPath: lastBackupPath.present
        ? lastBackupPath.value
        : this.lastBackupPath,
  );
  BackupMetadataRow copyWithCompanion(BackupMetadataTableCompanion data) {
    return BackupMetadataRow(
      id: data.id.present ? data.id.value : this.id,
      hlcMillis: data.hlcMillis.present ? data.hlcMillis.value : this.hlcMillis,
      hlcCounter: data.hlcCounter.present
          ? data.hlcCounter.value
          : this.hlcCounter,
      hlcNodeId: data.hlcNodeId.present ? data.hlcNodeId.value : this.hlcNodeId,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      autoBackupFrequency: data.autoBackupFrequency.present
          ? data.autoBackupFrequency.value
          : this.autoBackupFrequency,
      lastBackupAt: data.lastBackupAt.present
          ? data.lastBackupAt.value
          : this.lastBackupAt,
      lastBackupPath: data.lastBackupPath.present
          ? data.lastBackupPath.value
          : this.lastBackupPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BackupMetadataRow(')
          ..write('id: $id, ')
          ..write('hlcMillis: $hlcMillis, ')
          ..write('hlcCounter: $hlcCounter, ')
          ..write('hlcNodeId: $hlcNodeId, ')
          ..write('dirty: $dirty, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('autoBackupFrequency: $autoBackupFrequency, ')
          ..write('lastBackupAt: $lastBackupAt, ')
          ..write('lastBackupPath: $lastBackupPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    hlcMillis,
    hlcCounter,
    hlcNodeId,
    dirty,
    deletedAt,
    autoBackupFrequency,
    lastBackupAt,
    lastBackupPath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BackupMetadataRow &&
          other.id == this.id &&
          other.hlcMillis == this.hlcMillis &&
          other.hlcCounter == this.hlcCounter &&
          other.hlcNodeId == this.hlcNodeId &&
          other.dirty == this.dirty &&
          other.deletedAt == this.deletedAt &&
          other.autoBackupFrequency == this.autoBackupFrequency &&
          other.lastBackupAt == this.lastBackupAt &&
          other.lastBackupPath == this.lastBackupPath);
}

class BackupMetadataTableCompanion extends UpdateCompanion<BackupMetadataRow> {
  final Value<String> id;
  final Value<BigInt> hlcMillis;
  final Value<int> hlcCounter;
  final Value<String> hlcNodeId;
  final Value<bool> dirty;
  final Value<DateTime?> deletedAt;
  final Value<String> autoBackupFrequency;
  final Value<DateTime?> lastBackupAt;
  final Value<String?> lastBackupPath;
  final Value<int> rowid;
  const BackupMetadataTableCompanion({
    this.id = const Value.absent(),
    this.hlcMillis = const Value.absent(),
    this.hlcCounter = const Value.absent(),
    this.hlcNodeId = const Value.absent(),
    this.dirty = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.autoBackupFrequency = const Value.absent(),
    this.lastBackupAt = const Value.absent(),
    this.lastBackupPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BackupMetadataTableCompanion.insert({
    required String id,
    required BigInt hlcMillis,
    required int hlcCounter,
    required String hlcNodeId,
    this.dirty = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.autoBackupFrequency = const Value.absent(),
    this.lastBackupAt = const Value.absent(),
    this.lastBackupPath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       hlcMillis = Value(hlcMillis),
       hlcCounter = Value(hlcCounter),
       hlcNodeId = Value(hlcNodeId);
  static Insertable<BackupMetadataRow> custom({
    Expression<String>? id,
    Expression<BigInt>? hlcMillis,
    Expression<int>? hlcCounter,
    Expression<String>? hlcNodeId,
    Expression<bool>? dirty,
    Expression<DateTime>? deletedAt,
    Expression<String>? autoBackupFrequency,
    Expression<DateTime>? lastBackupAt,
    Expression<String>? lastBackupPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (hlcMillis != null) 'hlc_millis': hlcMillis,
      if (hlcCounter != null) 'hlc_counter': hlcCounter,
      if (hlcNodeId != null) 'hlc_node_id': hlcNodeId,
      if (dirty != null) 'dirty': dirty,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (autoBackupFrequency != null)
        'auto_backup_frequency': autoBackupFrequency,
      if (lastBackupAt != null) 'last_backup_at': lastBackupAt,
      if (lastBackupPath != null) 'last_backup_path': lastBackupPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BackupMetadataTableCompanion copyWith({
    Value<String>? id,
    Value<BigInt>? hlcMillis,
    Value<int>? hlcCounter,
    Value<String>? hlcNodeId,
    Value<bool>? dirty,
    Value<DateTime?>? deletedAt,
    Value<String>? autoBackupFrequency,
    Value<DateTime?>? lastBackupAt,
    Value<String?>? lastBackupPath,
    Value<int>? rowid,
  }) {
    return BackupMetadataTableCompanion(
      id: id ?? this.id,
      hlcMillis: hlcMillis ?? this.hlcMillis,
      hlcCounter: hlcCounter ?? this.hlcCounter,
      hlcNodeId: hlcNodeId ?? this.hlcNodeId,
      dirty: dirty ?? this.dirty,
      deletedAt: deletedAt ?? this.deletedAt,
      autoBackupFrequency: autoBackupFrequency ?? this.autoBackupFrequency,
      lastBackupAt: lastBackupAt ?? this.lastBackupAt,
      lastBackupPath: lastBackupPath ?? this.lastBackupPath,
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
    if (autoBackupFrequency.present) {
      map['auto_backup_frequency'] = Variable<String>(
        autoBackupFrequency.value,
      );
    }
    if (lastBackupAt.present) {
      map['last_backup_at'] = Variable<DateTime>(lastBackupAt.value);
    }
    if (lastBackupPath.present) {
      map['last_backup_path'] = Variable<String>(lastBackupPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BackupMetadataTableCompanion(')
          ..write('id: $id, ')
          ..write('hlcMillis: $hlcMillis, ')
          ..write('hlcCounter: $hlcCounter, ')
          ..write('hlcNodeId: $hlcNodeId, ')
          ..write('dirty: $dirty, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('autoBackupFrequency: $autoBackupFrequency, ')
          ..write('lastBackupAt: $lastBackupAt, ')
          ..write('lastBackupPath: $lastBackupPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final UserFoodCacheFts userFoodCacheFts = UserFoodCacheFts(this);
  late final $UserProfileTableTable userProfileTable = $UserProfileTableTable(
    this,
  );
  late final $ConsentRecordsTableTable consentRecordsTable =
      $ConsentRecordsTableTable(this);
  late final $UserFoodCacheTableTable userFoodCacheTable =
      $UserFoodCacheTableTable(this);
  late final $MealEntryTableTable mealEntryTable = $MealEntryTableTable(this);
  late final $FavoriteTableTable favoriteTable = $FavoriteTableTable(this);
  late final $UserFoodTableTable userFoodTable = $UserFoodTableTable(this);
  late final $Co2SettingsTableTable co2SettingsTable = $Co2SettingsTableTable(
    this,
  );
  late final $WeightEntryTableTable weightEntryTable = $WeightEntryTableTable(
    this,
  );
  late final $WeightSettingsTableTable weightSettingsTable =
      $WeightSettingsTableTable(this);
  late final $NotificationPrefsTableTable notificationPrefsTable =
      $NotificationPrefsTableTable(this);
  late final $BackupMetadataTableTable backupMetadataTable =
      $BackupMetadataTableTable(this);
  late final UserProfileDao userProfileDao = UserProfileDao(
    this as AppDatabase,
  );
  late final ConsentRecordsDao consentRecordsDao = ConsentRecordsDao(
    this as AppDatabase,
  );
  late final FoodCatalogDao foodCatalogDao = FoodCatalogDao(
    this as AppDatabase,
  );
  late final MealEntryDao mealEntryDao = MealEntryDao(this as AppDatabase);
  late final UserFoodDao userFoodDao = UserFoodDao(this as AppDatabase);
  late final Co2SettingsDao co2SettingsDao = Co2SettingsDao(
    this as AppDatabase,
  );
  late final WeightDao weightDao = WeightDao(this as AppDatabase);
  late final NotificationPrefsDao notificationPrefsDao = NotificationPrefsDao(
    this as AppDatabase,
  );
  late final BackupMetadataDao backupMetadataDao = BackupMetadataDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userFoodCacheFts,
    userProfileTable,
    consentRecordsTable,
    userFoodCacheTable,
    mealEntryTable,
    favoriteTable,
    userFoodTable,
    co2SettingsTable,
    weightEntryTable,
    weightSettingsTable,
    notificationPrefsTable,
    backupMetadataTable,
  ];
}

typedef $UserFoodCacheFtsCreateCompanionBuilder =
    UserFoodCacheFtsCompanion Function({
      required String productName,
      required String productNameEn,
      required String brand,
      Value<int> rowid,
    });
typedef $UserFoodCacheFtsUpdateCompanionBuilder =
    UserFoodCacheFtsCompanion Function({
      Value<String> productName,
      Value<String> productNameEn,
      Value<String> brand,
      Value<int> rowid,
    });

class $UserFoodCacheFtsFilterComposer
    extends Composer<_$AppDatabase, UserFoodCacheFts> {
  $UserFoodCacheFtsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productNameEn => $composableBuilder(
    column: $table.productNameEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );
}

class $UserFoodCacheFtsOrderingComposer
    extends Composer<_$AppDatabase, UserFoodCacheFts> {
  $UserFoodCacheFtsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productNameEn => $composableBuilder(
    column: $table.productNameEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );
}

class $UserFoodCacheFtsAnnotationComposer
    extends Composer<_$AppDatabase, UserFoodCacheFts> {
  $UserFoodCacheFtsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productNameEn => $composableBuilder(
    column: $table.productNameEn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);
}

class $UserFoodCacheFtsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          UserFoodCacheFts,
          UserFoodCacheFt,
          $UserFoodCacheFtsFilterComposer,
          $UserFoodCacheFtsOrderingComposer,
          $UserFoodCacheFtsAnnotationComposer,
          $UserFoodCacheFtsCreateCompanionBuilder,
          $UserFoodCacheFtsUpdateCompanionBuilder,
          (
            UserFoodCacheFt,
            BaseReferences<_$AppDatabase, UserFoodCacheFts, UserFoodCacheFt>,
          ),
          UserFoodCacheFt,
          PrefetchHooks Function()
        > {
  $UserFoodCacheFtsTableManager(_$AppDatabase db, UserFoodCacheFts table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $UserFoodCacheFtsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $UserFoodCacheFtsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $UserFoodCacheFtsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> productName = const Value.absent(),
                Value<String> productNameEn = const Value.absent(),
                Value<String> brand = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserFoodCacheFtsCompanion(
                productName: productName,
                productNameEn: productNameEn,
                brand: brand,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String productName,
                required String productNameEn,
                required String brand,
                Value<int> rowid = const Value.absent(),
              }) => UserFoodCacheFtsCompanion.insert(
                productName: productName,
                productNameEn: productNameEn,
                brand: brand,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $UserFoodCacheFtsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      UserFoodCacheFts,
      UserFoodCacheFt,
      $UserFoodCacheFtsFilterComposer,
      $UserFoodCacheFtsOrderingComposer,
      $UserFoodCacheFtsAnnotationComposer,
      $UserFoodCacheFtsCreateCompanionBuilder,
      $UserFoodCacheFtsUpdateCompanionBuilder,
      (
        UserFoodCacheFt,
        BaseReferences<_$AppDatabase, UserFoodCacheFts, UserFoodCacheFt>,
      ),
      UserFoodCacheFt,
      PrefetchHooks Function()
    >;
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
typedef $$UserFoodCacheTableTableCreateCompanionBuilder =
    UserFoodCacheTableCompanion Function({
      required String id,
      required BigInt hlcMillis,
      required int hlcCounter,
      required String hlcNodeId,
      Value<bool> dirty,
      Value<DateTime?> deletedAt,
      Value<String?> barcode,
      required String productName,
      Value<String?> productNameEn,
      Value<String?> brand,
      Value<double?> calories100g,
      Value<double?> protein100g,
      Value<double?> carbs100g,
      Value<double?> fat100g,
      Value<String?> categoriesTags,
      Value<int> rowid,
    });
typedef $$UserFoodCacheTableTableUpdateCompanionBuilder =
    UserFoodCacheTableCompanion Function({
      Value<String> id,
      Value<BigInt> hlcMillis,
      Value<int> hlcCounter,
      Value<String> hlcNodeId,
      Value<bool> dirty,
      Value<DateTime?> deletedAt,
      Value<String?> barcode,
      Value<String> productName,
      Value<String?> productNameEn,
      Value<String?> brand,
      Value<double?> calories100g,
      Value<double?> protein100g,
      Value<double?> carbs100g,
      Value<double?> fat100g,
      Value<String?> categoriesTags,
      Value<int> rowid,
    });

class $$UserFoodCacheTableTableFilterComposer
    extends Composer<_$AppDatabase, $UserFoodCacheTableTable> {
  $$UserFoodCacheTableTableFilterComposer({
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

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productNameEn => $composableBuilder(
    column: $table.productNameEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calories100g => $composableBuilder(
    column: $table.calories100g,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get protein100g => $composableBuilder(
    column: $table.protein100g,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbs100g => $composableBuilder(
    column: $table.carbs100g,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fat100g => $composableBuilder(
    column: $table.fat100g,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoriesTags => $composableBuilder(
    column: $table.categoriesTags,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserFoodCacheTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UserFoodCacheTableTable> {
  $$UserFoodCacheTableTableOrderingComposer({
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

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productNameEn => $composableBuilder(
    column: $table.productNameEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calories100g => $composableBuilder(
    column: $table.calories100g,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get protein100g => $composableBuilder(
    column: $table.protein100g,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbs100g => $composableBuilder(
    column: $table.carbs100g,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fat100g => $composableBuilder(
    column: $table.fat100g,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoriesTags => $composableBuilder(
    column: $table.categoriesTags,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserFoodCacheTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserFoodCacheTableTable> {
  $$UserFoodCacheTableTableAnnotationComposer({
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

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productNameEn => $composableBuilder(
    column: $table.productNameEn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<double> get calories100g => $composableBuilder(
    column: $table.calories100g,
    builder: (column) => column,
  );

  GeneratedColumn<double> get protein100g => $composableBuilder(
    column: $table.protein100g,
    builder: (column) => column,
  );

  GeneratedColumn<double> get carbs100g =>
      $composableBuilder(column: $table.carbs100g, builder: (column) => column);

  GeneratedColumn<double> get fat100g =>
      $composableBuilder(column: $table.fat100g, builder: (column) => column);

  GeneratedColumn<String> get categoriesTags => $composableBuilder(
    column: $table.categoriesTags,
    builder: (column) => column,
  );
}

class $$UserFoodCacheTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserFoodCacheTableTable,
          UserFoodCacheRow,
          $$UserFoodCacheTableTableFilterComposer,
          $$UserFoodCacheTableTableOrderingComposer,
          $$UserFoodCacheTableTableAnnotationComposer,
          $$UserFoodCacheTableTableCreateCompanionBuilder,
          $$UserFoodCacheTableTableUpdateCompanionBuilder,
          (
            UserFoodCacheRow,
            BaseReferences<
              _$AppDatabase,
              $UserFoodCacheTableTable,
              UserFoodCacheRow
            >,
          ),
          UserFoodCacheRow,
          PrefetchHooks Function()
        > {
  $$UserFoodCacheTableTableTableManager(
    _$AppDatabase db,
    $UserFoodCacheTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserFoodCacheTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserFoodCacheTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserFoodCacheTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<BigInt> hlcMillis = const Value.absent(),
                Value<int> hlcCounter = const Value.absent(),
                Value<String> hlcNodeId = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String> productName = const Value.absent(),
                Value<String?> productNameEn = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<double?> calories100g = const Value.absent(),
                Value<double?> protein100g = const Value.absent(),
                Value<double?> carbs100g = const Value.absent(),
                Value<double?> fat100g = const Value.absent(),
                Value<String?> categoriesTags = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserFoodCacheTableCompanion(
                id: id,
                hlcMillis: hlcMillis,
                hlcCounter: hlcCounter,
                hlcNodeId: hlcNodeId,
                dirty: dirty,
                deletedAt: deletedAt,
                barcode: barcode,
                productName: productName,
                productNameEn: productNameEn,
                brand: brand,
                calories100g: calories100g,
                protein100g: protein100g,
                carbs100g: carbs100g,
                fat100g: fat100g,
                categoriesTags: categoriesTags,
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
                Value<String?> barcode = const Value.absent(),
                required String productName,
                Value<String?> productNameEn = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<double?> calories100g = const Value.absent(),
                Value<double?> protein100g = const Value.absent(),
                Value<double?> carbs100g = const Value.absent(),
                Value<double?> fat100g = const Value.absent(),
                Value<String?> categoriesTags = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserFoodCacheTableCompanion.insert(
                id: id,
                hlcMillis: hlcMillis,
                hlcCounter: hlcCounter,
                hlcNodeId: hlcNodeId,
                dirty: dirty,
                deletedAt: deletedAt,
                barcode: barcode,
                productName: productName,
                productNameEn: productNameEn,
                brand: brand,
                calories100g: calories100g,
                protein100g: protein100g,
                carbs100g: carbs100g,
                fat100g: fat100g,
                categoriesTags: categoriesTags,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserFoodCacheTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserFoodCacheTableTable,
      UserFoodCacheRow,
      $$UserFoodCacheTableTableFilterComposer,
      $$UserFoodCacheTableTableOrderingComposer,
      $$UserFoodCacheTableTableAnnotationComposer,
      $$UserFoodCacheTableTableCreateCompanionBuilder,
      $$UserFoodCacheTableTableUpdateCompanionBuilder,
      (
        UserFoodCacheRow,
        BaseReferences<
          _$AppDatabase,
          $UserFoodCacheTableTable,
          UserFoodCacheRow
        >,
      ),
      UserFoodCacheRow,
      PrefetchHooks Function()
    >;
typedef $$MealEntryTableTableCreateCompanionBuilder =
    MealEntryTableCompanion Function({
      required String id,
      required BigInt hlcMillis,
      required int hlcCounter,
      required String hlcNodeId,
      Value<bool> dirty,
      Value<DateTime?> deletedAt,
      required MealSlot mealSlot,
      required String foodRef,
      required String foodRefSource,
      required double quantity,
      required PortionUnit unit,
      required String productNameSnapshot,
      Value<String?> brandSnapshot,
      Value<double?> calories100gSnapshot,
      Value<double?> protein100gSnapshot,
      Value<double?> carbs100gSnapshot,
      Value<double?> fat100gSnapshot,
      Value<double?> sugar100gSnapshot,
      Value<double?> fiber100gSnapshot,
      Value<double?> saltSnapshot,
      Value<double?> co2e100gSnapshot,
      Value<String?> confidenceBandSnapshot,
      Value<String?> co2MethodologyVersionSnapshot,
      required DateTime loggedAt,
      required String logDate,
      Value<int> rowid,
    });
typedef $$MealEntryTableTableUpdateCompanionBuilder =
    MealEntryTableCompanion Function({
      Value<String> id,
      Value<BigInt> hlcMillis,
      Value<int> hlcCounter,
      Value<String> hlcNodeId,
      Value<bool> dirty,
      Value<DateTime?> deletedAt,
      Value<MealSlot> mealSlot,
      Value<String> foodRef,
      Value<String> foodRefSource,
      Value<double> quantity,
      Value<PortionUnit> unit,
      Value<String> productNameSnapshot,
      Value<String?> brandSnapshot,
      Value<double?> calories100gSnapshot,
      Value<double?> protein100gSnapshot,
      Value<double?> carbs100gSnapshot,
      Value<double?> fat100gSnapshot,
      Value<double?> sugar100gSnapshot,
      Value<double?> fiber100gSnapshot,
      Value<double?> saltSnapshot,
      Value<double?> co2e100gSnapshot,
      Value<String?> confidenceBandSnapshot,
      Value<String?> co2MethodologyVersionSnapshot,
      Value<DateTime> loggedAt,
      Value<String> logDate,
      Value<int> rowid,
    });

class $$MealEntryTableTableFilterComposer
    extends Composer<_$AppDatabase, $MealEntryTableTable> {
  $$MealEntryTableTableFilterComposer({
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

  ColumnWithTypeConverterFilters<MealSlot, MealSlot, String> get mealSlot =>
      $composableBuilder(
        column: $table.mealSlot,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get foodRef => $composableBuilder(
    column: $table.foodRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodRefSource => $composableBuilder(
    column: $table.foodRefSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PortionUnit, PortionUnit, String> get unit =>
      $composableBuilder(
        column: $table.unit,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get productNameSnapshot => $composableBuilder(
    column: $table.productNameSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brandSnapshot => $composableBuilder(
    column: $table.brandSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calories100gSnapshot => $composableBuilder(
    column: $table.calories100gSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get protein100gSnapshot => $composableBuilder(
    column: $table.protein100gSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbs100gSnapshot => $composableBuilder(
    column: $table.carbs100gSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fat100gSnapshot => $composableBuilder(
    column: $table.fat100gSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sugar100gSnapshot => $composableBuilder(
    column: $table.sugar100gSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fiber100gSnapshot => $composableBuilder(
    column: $table.fiber100gSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get saltSnapshot => $composableBuilder(
    column: $table.saltSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get co2e100gSnapshot => $composableBuilder(
    column: $table.co2e100gSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get confidenceBandSnapshot => $composableBuilder(
    column: $table.confidenceBandSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get co2MethodologyVersionSnapshot => $composableBuilder(
    column: $table.co2MethodologyVersionSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logDate => $composableBuilder(
    column: $table.logDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MealEntryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MealEntryTableTable> {
  $$MealEntryTableTableOrderingComposer({
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

  ColumnOrderings<String> get mealSlot => $composableBuilder(
    column: $table.mealSlot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodRef => $composableBuilder(
    column: $table.foodRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodRefSource => $composableBuilder(
    column: $table.foodRefSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productNameSnapshot => $composableBuilder(
    column: $table.productNameSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brandSnapshot => $composableBuilder(
    column: $table.brandSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calories100gSnapshot => $composableBuilder(
    column: $table.calories100gSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get protein100gSnapshot => $composableBuilder(
    column: $table.protein100gSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbs100gSnapshot => $composableBuilder(
    column: $table.carbs100gSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fat100gSnapshot => $composableBuilder(
    column: $table.fat100gSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sugar100gSnapshot => $composableBuilder(
    column: $table.sugar100gSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fiber100gSnapshot => $composableBuilder(
    column: $table.fiber100gSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get saltSnapshot => $composableBuilder(
    column: $table.saltSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get co2e100gSnapshot => $composableBuilder(
    column: $table.co2e100gSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confidenceBandSnapshot => $composableBuilder(
    column: $table.confidenceBandSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get co2MethodologyVersionSnapshot =>
      $composableBuilder(
        column: $table.co2MethodologyVersionSnapshot,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logDate => $composableBuilder(
    column: $table.logDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MealEntryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MealEntryTableTable> {
  $$MealEntryTableTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<MealSlot, String> get mealSlot =>
      $composableBuilder(column: $table.mealSlot, builder: (column) => column);

  GeneratedColumn<String> get foodRef =>
      $composableBuilder(column: $table.foodRef, builder: (column) => column);

  GeneratedColumn<String> get foodRefSource => $composableBuilder(
    column: $table.foodRefSource,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PortionUnit, String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get productNameSnapshot => $composableBuilder(
    column: $table.productNameSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get brandSnapshot => $composableBuilder(
    column: $table.brandSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<double> get calories100gSnapshot => $composableBuilder(
    column: $table.calories100gSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<double> get protein100gSnapshot => $composableBuilder(
    column: $table.protein100gSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<double> get carbs100gSnapshot => $composableBuilder(
    column: $table.carbs100gSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fat100gSnapshot => $composableBuilder(
    column: $table.fat100gSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sugar100gSnapshot => $composableBuilder(
    column: $table.sugar100gSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fiber100gSnapshot => $composableBuilder(
    column: $table.fiber100gSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<double> get saltSnapshot => $composableBuilder(
    column: $table.saltSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<double> get co2e100gSnapshot => $composableBuilder(
    column: $table.co2e100gSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get confidenceBandSnapshot => $composableBuilder(
    column: $table.confidenceBandSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get co2MethodologyVersionSnapshot =>
      $composableBuilder(
        column: $table.co2MethodologyVersionSnapshot,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get loggedAt =>
      $composableBuilder(column: $table.loggedAt, builder: (column) => column);

  GeneratedColumn<String> get logDate =>
      $composableBuilder(column: $table.logDate, builder: (column) => column);
}

class $$MealEntryTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MealEntryTableTable,
          MealEntryRow,
          $$MealEntryTableTableFilterComposer,
          $$MealEntryTableTableOrderingComposer,
          $$MealEntryTableTableAnnotationComposer,
          $$MealEntryTableTableCreateCompanionBuilder,
          $$MealEntryTableTableUpdateCompanionBuilder,
          (
            MealEntryRow,
            BaseReferences<_$AppDatabase, $MealEntryTableTable, MealEntryRow>,
          ),
          MealEntryRow,
          PrefetchHooks Function()
        > {
  $$MealEntryTableTableTableManager(
    _$AppDatabase db,
    $MealEntryTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MealEntryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MealEntryTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MealEntryTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<BigInt> hlcMillis = const Value.absent(),
                Value<int> hlcCounter = const Value.absent(),
                Value<String> hlcNodeId = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<MealSlot> mealSlot = const Value.absent(),
                Value<String> foodRef = const Value.absent(),
                Value<String> foodRefSource = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<PortionUnit> unit = const Value.absent(),
                Value<String> productNameSnapshot = const Value.absent(),
                Value<String?> brandSnapshot = const Value.absent(),
                Value<double?> calories100gSnapshot = const Value.absent(),
                Value<double?> protein100gSnapshot = const Value.absent(),
                Value<double?> carbs100gSnapshot = const Value.absent(),
                Value<double?> fat100gSnapshot = const Value.absent(),
                Value<double?> sugar100gSnapshot = const Value.absent(),
                Value<double?> fiber100gSnapshot = const Value.absent(),
                Value<double?> saltSnapshot = const Value.absent(),
                Value<double?> co2e100gSnapshot = const Value.absent(),
                Value<String?> confidenceBandSnapshot = const Value.absent(),
                Value<String?> co2MethodologyVersionSnapshot =
                    const Value.absent(),
                Value<DateTime> loggedAt = const Value.absent(),
                Value<String> logDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MealEntryTableCompanion(
                id: id,
                hlcMillis: hlcMillis,
                hlcCounter: hlcCounter,
                hlcNodeId: hlcNodeId,
                dirty: dirty,
                deletedAt: deletedAt,
                mealSlot: mealSlot,
                foodRef: foodRef,
                foodRefSource: foodRefSource,
                quantity: quantity,
                unit: unit,
                productNameSnapshot: productNameSnapshot,
                brandSnapshot: brandSnapshot,
                calories100gSnapshot: calories100gSnapshot,
                protein100gSnapshot: protein100gSnapshot,
                carbs100gSnapshot: carbs100gSnapshot,
                fat100gSnapshot: fat100gSnapshot,
                sugar100gSnapshot: sugar100gSnapshot,
                fiber100gSnapshot: fiber100gSnapshot,
                saltSnapshot: saltSnapshot,
                co2e100gSnapshot: co2e100gSnapshot,
                confidenceBandSnapshot: confidenceBandSnapshot,
                co2MethodologyVersionSnapshot: co2MethodologyVersionSnapshot,
                loggedAt: loggedAt,
                logDate: logDate,
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
                required MealSlot mealSlot,
                required String foodRef,
                required String foodRefSource,
                required double quantity,
                required PortionUnit unit,
                required String productNameSnapshot,
                Value<String?> brandSnapshot = const Value.absent(),
                Value<double?> calories100gSnapshot = const Value.absent(),
                Value<double?> protein100gSnapshot = const Value.absent(),
                Value<double?> carbs100gSnapshot = const Value.absent(),
                Value<double?> fat100gSnapshot = const Value.absent(),
                Value<double?> sugar100gSnapshot = const Value.absent(),
                Value<double?> fiber100gSnapshot = const Value.absent(),
                Value<double?> saltSnapshot = const Value.absent(),
                Value<double?> co2e100gSnapshot = const Value.absent(),
                Value<String?> confidenceBandSnapshot = const Value.absent(),
                Value<String?> co2MethodologyVersionSnapshot =
                    const Value.absent(),
                required DateTime loggedAt,
                required String logDate,
                Value<int> rowid = const Value.absent(),
              }) => MealEntryTableCompanion.insert(
                id: id,
                hlcMillis: hlcMillis,
                hlcCounter: hlcCounter,
                hlcNodeId: hlcNodeId,
                dirty: dirty,
                deletedAt: deletedAt,
                mealSlot: mealSlot,
                foodRef: foodRef,
                foodRefSource: foodRefSource,
                quantity: quantity,
                unit: unit,
                productNameSnapshot: productNameSnapshot,
                brandSnapshot: brandSnapshot,
                calories100gSnapshot: calories100gSnapshot,
                protein100gSnapshot: protein100gSnapshot,
                carbs100gSnapshot: carbs100gSnapshot,
                fat100gSnapshot: fat100gSnapshot,
                sugar100gSnapshot: sugar100gSnapshot,
                fiber100gSnapshot: fiber100gSnapshot,
                saltSnapshot: saltSnapshot,
                co2e100gSnapshot: co2e100gSnapshot,
                confidenceBandSnapshot: confidenceBandSnapshot,
                co2MethodologyVersionSnapshot: co2MethodologyVersionSnapshot,
                loggedAt: loggedAt,
                logDate: logDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MealEntryTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MealEntryTableTable,
      MealEntryRow,
      $$MealEntryTableTableFilterComposer,
      $$MealEntryTableTableOrderingComposer,
      $$MealEntryTableTableAnnotationComposer,
      $$MealEntryTableTableCreateCompanionBuilder,
      $$MealEntryTableTableUpdateCompanionBuilder,
      (
        MealEntryRow,
        BaseReferences<_$AppDatabase, $MealEntryTableTable, MealEntryRow>,
      ),
      MealEntryRow,
      PrefetchHooks Function()
    >;
typedef $$FavoriteTableTableCreateCompanionBuilder =
    FavoriteTableCompanion Function({
      required String id,
      required BigInt hlcMillis,
      required int hlcCounter,
      required String hlcNodeId,
      Value<bool> dirty,
      Value<DateTime?> deletedAt,
      required String foodRef,
      required String foodRefSource,
      required String productNameSnapshot,
      Value<String?> brandSnapshot,
      Value<double?> calories100gSnapshot,
      Value<double?> co2e100gSnapshot,
      Value<String?> confidenceBandSnapshot,
      Value<double?> lastQuantity,
      Value<PortionUnit?> lastUnit,
      required DateTime favoritedAt,
      Value<int> rowid,
    });
typedef $$FavoriteTableTableUpdateCompanionBuilder =
    FavoriteTableCompanion Function({
      Value<String> id,
      Value<BigInt> hlcMillis,
      Value<int> hlcCounter,
      Value<String> hlcNodeId,
      Value<bool> dirty,
      Value<DateTime?> deletedAt,
      Value<String> foodRef,
      Value<String> foodRefSource,
      Value<String> productNameSnapshot,
      Value<String?> brandSnapshot,
      Value<double?> calories100gSnapshot,
      Value<double?> co2e100gSnapshot,
      Value<String?> confidenceBandSnapshot,
      Value<double?> lastQuantity,
      Value<PortionUnit?> lastUnit,
      Value<DateTime> favoritedAt,
      Value<int> rowid,
    });

class $$FavoriteTableTableFilterComposer
    extends Composer<_$AppDatabase, $FavoriteTableTable> {
  $$FavoriteTableTableFilterComposer({
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

  ColumnFilters<String> get foodRef => $composableBuilder(
    column: $table.foodRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodRefSource => $composableBuilder(
    column: $table.foodRefSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productNameSnapshot => $composableBuilder(
    column: $table.productNameSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brandSnapshot => $composableBuilder(
    column: $table.brandSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calories100gSnapshot => $composableBuilder(
    column: $table.calories100gSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get co2e100gSnapshot => $composableBuilder(
    column: $table.co2e100gSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get confidenceBandSnapshot => $composableBuilder(
    column: $table.confidenceBandSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lastQuantity => $composableBuilder(
    column: $table.lastQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PortionUnit?, PortionUnit, String>
  get lastUnit => $composableBuilder(
    column: $table.lastUnit,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get favoritedAt => $composableBuilder(
    column: $table.favoritedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoriteTableTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoriteTableTable> {
  $$FavoriteTableTableOrderingComposer({
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

  ColumnOrderings<String> get foodRef => $composableBuilder(
    column: $table.foodRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodRefSource => $composableBuilder(
    column: $table.foodRefSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productNameSnapshot => $composableBuilder(
    column: $table.productNameSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brandSnapshot => $composableBuilder(
    column: $table.brandSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calories100gSnapshot => $composableBuilder(
    column: $table.calories100gSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get co2e100gSnapshot => $composableBuilder(
    column: $table.co2e100gSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confidenceBandSnapshot => $composableBuilder(
    column: $table.confidenceBandSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lastQuantity => $composableBuilder(
    column: $table.lastQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastUnit => $composableBuilder(
    column: $table.lastUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get favoritedAt => $composableBuilder(
    column: $table.favoritedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoriteTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoriteTableTable> {
  $$FavoriteTableTableAnnotationComposer({
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

  GeneratedColumn<String> get foodRef =>
      $composableBuilder(column: $table.foodRef, builder: (column) => column);

  GeneratedColumn<String> get foodRefSource => $composableBuilder(
    column: $table.foodRefSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productNameSnapshot => $composableBuilder(
    column: $table.productNameSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get brandSnapshot => $composableBuilder(
    column: $table.brandSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<double> get calories100gSnapshot => $composableBuilder(
    column: $table.calories100gSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<double> get co2e100gSnapshot => $composableBuilder(
    column: $table.co2e100gSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get confidenceBandSnapshot => $composableBuilder(
    column: $table.confidenceBandSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lastQuantity => $composableBuilder(
    column: $table.lastQuantity,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<PortionUnit?, String> get lastUnit =>
      $composableBuilder(column: $table.lastUnit, builder: (column) => column);

  GeneratedColumn<DateTime> get favoritedAt => $composableBuilder(
    column: $table.favoritedAt,
    builder: (column) => column,
  );
}

class $$FavoriteTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoriteTableTable,
          FavoriteRow,
          $$FavoriteTableTableFilterComposer,
          $$FavoriteTableTableOrderingComposer,
          $$FavoriteTableTableAnnotationComposer,
          $$FavoriteTableTableCreateCompanionBuilder,
          $$FavoriteTableTableUpdateCompanionBuilder,
          (
            FavoriteRow,
            BaseReferences<_$AppDatabase, $FavoriteTableTable, FavoriteRow>,
          ),
          FavoriteRow,
          PrefetchHooks Function()
        > {
  $$FavoriteTableTableTableManager(_$AppDatabase db, $FavoriteTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoriteTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoriteTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoriteTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<BigInt> hlcMillis = const Value.absent(),
                Value<int> hlcCounter = const Value.absent(),
                Value<String> hlcNodeId = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> foodRef = const Value.absent(),
                Value<String> foodRefSource = const Value.absent(),
                Value<String> productNameSnapshot = const Value.absent(),
                Value<String?> brandSnapshot = const Value.absent(),
                Value<double?> calories100gSnapshot = const Value.absent(),
                Value<double?> co2e100gSnapshot = const Value.absent(),
                Value<String?> confidenceBandSnapshot = const Value.absent(),
                Value<double?> lastQuantity = const Value.absent(),
                Value<PortionUnit?> lastUnit = const Value.absent(),
                Value<DateTime> favoritedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FavoriteTableCompanion(
                id: id,
                hlcMillis: hlcMillis,
                hlcCounter: hlcCounter,
                hlcNodeId: hlcNodeId,
                dirty: dirty,
                deletedAt: deletedAt,
                foodRef: foodRef,
                foodRefSource: foodRefSource,
                productNameSnapshot: productNameSnapshot,
                brandSnapshot: brandSnapshot,
                calories100gSnapshot: calories100gSnapshot,
                co2e100gSnapshot: co2e100gSnapshot,
                confidenceBandSnapshot: confidenceBandSnapshot,
                lastQuantity: lastQuantity,
                lastUnit: lastUnit,
                favoritedAt: favoritedAt,
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
                required String foodRef,
                required String foodRefSource,
                required String productNameSnapshot,
                Value<String?> brandSnapshot = const Value.absent(),
                Value<double?> calories100gSnapshot = const Value.absent(),
                Value<double?> co2e100gSnapshot = const Value.absent(),
                Value<String?> confidenceBandSnapshot = const Value.absent(),
                Value<double?> lastQuantity = const Value.absent(),
                Value<PortionUnit?> lastUnit = const Value.absent(),
                required DateTime favoritedAt,
                Value<int> rowid = const Value.absent(),
              }) => FavoriteTableCompanion.insert(
                id: id,
                hlcMillis: hlcMillis,
                hlcCounter: hlcCounter,
                hlcNodeId: hlcNodeId,
                dirty: dirty,
                deletedAt: deletedAt,
                foodRef: foodRef,
                foodRefSource: foodRefSource,
                productNameSnapshot: productNameSnapshot,
                brandSnapshot: brandSnapshot,
                calories100gSnapshot: calories100gSnapshot,
                co2e100gSnapshot: co2e100gSnapshot,
                confidenceBandSnapshot: confidenceBandSnapshot,
                lastQuantity: lastQuantity,
                lastUnit: lastUnit,
                favoritedAt: favoritedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoriteTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoriteTableTable,
      FavoriteRow,
      $$FavoriteTableTableFilterComposer,
      $$FavoriteTableTableOrderingComposer,
      $$FavoriteTableTableAnnotationComposer,
      $$FavoriteTableTableCreateCompanionBuilder,
      $$FavoriteTableTableUpdateCompanionBuilder,
      (
        FavoriteRow,
        BaseReferences<_$AppDatabase, $FavoriteTableTable, FavoriteRow>,
      ),
      FavoriteRow,
      PrefetchHooks Function()
    >;
typedef $$UserFoodTableTableCreateCompanionBuilder =
    UserFoodTableCompanion Function({
      required String id,
      required BigInt hlcMillis,
      required int hlcCounter,
      required String hlcNodeId,
      Value<bool> dirty,
      Value<DateTime?> deletedAt,
      required String name,
      Value<String?> brand,
      Value<String?> category,
      Value<double> referenceAmountG,
      required double calories,
      Value<double?> protein,
      Value<double?> carbs,
      Value<double?> sugar,
      Value<double?> fat,
      Value<double?> fiber,
      Value<double?> salt,
      Value<double?> co2e100g,
      Value<String?> confidenceBand,
      Value<String?> co2Source,
      Value<String?> co2MethodologyVersion,
      Value<String?> barcode,
      required List<ServingSize> quickServingSizes,
      Value<String?> overrideOfRef,
      Value<String?> overrideOfSource,
      Value<int> rowid,
    });
typedef $$UserFoodTableTableUpdateCompanionBuilder =
    UserFoodTableCompanion Function({
      Value<String> id,
      Value<BigInt> hlcMillis,
      Value<int> hlcCounter,
      Value<String> hlcNodeId,
      Value<bool> dirty,
      Value<DateTime?> deletedAt,
      Value<String> name,
      Value<String?> brand,
      Value<String?> category,
      Value<double> referenceAmountG,
      Value<double> calories,
      Value<double?> protein,
      Value<double?> carbs,
      Value<double?> sugar,
      Value<double?> fat,
      Value<double?> fiber,
      Value<double?> salt,
      Value<double?> co2e100g,
      Value<String?> confidenceBand,
      Value<String?> co2Source,
      Value<String?> co2MethodologyVersion,
      Value<String?> barcode,
      Value<List<ServingSize>> quickServingSizes,
      Value<String?> overrideOfRef,
      Value<String?> overrideOfSource,
      Value<int> rowid,
    });

class $$UserFoodTableTableFilterComposer
    extends Composer<_$AppDatabase, $UserFoodTableTable> {
  $$UserFoodTableTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get referenceAmountG => $composableBuilder(
    column: $table.referenceAmountG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sugar => $composableBuilder(
    column: $table.sugar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fiber => $composableBuilder(
    column: $table.fiber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get salt => $composableBuilder(
    column: $table.salt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get co2e100g => $composableBuilder(
    column: $table.co2e100g,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get confidenceBand => $composableBuilder(
    column: $table.confidenceBand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get co2Source => $composableBuilder(
    column: $table.co2Source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get co2MethodologyVersion => $composableBuilder(
    column: $table.co2MethodologyVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<ServingSize>, List<ServingSize>, String>
  get quickServingSizes => $composableBuilder(
    column: $table.quickServingSizes,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get overrideOfRef => $composableBuilder(
    column: $table.overrideOfRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get overrideOfSource => $composableBuilder(
    column: $table.overrideOfSource,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserFoodTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UserFoodTableTable> {
  $$UserFoodTableTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get referenceAmountG => $composableBuilder(
    column: $table.referenceAmountG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get calories => $composableBuilder(
    column: $table.calories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sugar => $composableBuilder(
    column: $table.sugar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fiber => $composableBuilder(
    column: $table.fiber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get salt => $composableBuilder(
    column: $table.salt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get co2e100g => $composableBuilder(
    column: $table.co2e100g,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confidenceBand => $composableBuilder(
    column: $table.confidenceBand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get co2Source => $composableBuilder(
    column: $table.co2Source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get co2MethodologyVersion => $composableBuilder(
    column: $table.co2MethodologyVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quickServingSizes => $composableBuilder(
    column: $table.quickServingSizes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get overrideOfRef => $composableBuilder(
    column: $table.overrideOfRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get overrideOfSource => $composableBuilder(
    column: $table.overrideOfSource,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserFoodTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserFoodTableTable> {
  $$UserFoodTableTableAnnotationComposer({
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

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get referenceAmountG => $composableBuilder(
    column: $table.referenceAmountG,
    builder: (column) => column,
  );

  GeneratedColumn<double> get calories =>
      $composableBuilder(column: $table.calories, builder: (column) => column);

  GeneratedColumn<double> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => column);

  GeneratedColumn<double> get carbs =>
      $composableBuilder(column: $table.carbs, builder: (column) => column);

  GeneratedColumn<double> get sugar =>
      $composableBuilder(column: $table.sugar, builder: (column) => column);

  GeneratedColumn<double> get fat =>
      $composableBuilder(column: $table.fat, builder: (column) => column);

  GeneratedColumn<double> get fiber =>
      $composableBuilder(column: $table.fiber, builder: (column) => column);

  GeneratedColumn<double> get salt =>
      $composableBuilder(column: $table.salt, builder: (column) => column);

  GeneratedColumn<double> get co2e100g =>
      $composableBuilder(column: $table.co2e100g, builder: (column) => column);

  GeneratedColumn<String> get confidenceBand => $composableBuilder(
    column: $table.confidenceBand,
    builder: (column) => column,
  );

  GeneratedColumn<String> get co2Source =>
      $composableBuilder(column: $table.co2Source, builder: (column) => column);

  GeneratedColumn<String> get co2MethodologyVersion => $composableBuilder(
    column: $table.co2MethodologyVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<ServingSize>, String>
  get quickServingSizes => $composableBuilder(
    column: $table.quickServingSizes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get overrideOfRef => $composableBuilder(
    column: $table.overrideOfRef,
    builder: (column) => column,
  );

  GeneratedColumn<String> get overrideOfSource => $composableBuilder(
    column: $table.overrideOfSource,
    builder: (column) => column,
  );
}

class $$UserFoodTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserFoodTableTable,
          UserFoodRow,
          $$UserFoodTableTableFilterComposer,
          $$UserFoodTableTableOrderingComposer,
          $$UserFoodTableTableAnnotationComposer,
          $$UserFoodTableTableCreateCompanionBuilder,
          $$UserFoodTableTableUpdateCompanionBuilder,
          (
            UserFoodRow,
            BaseReferences<_$AppDatabase, $UserFoodTableTable, UserFoodRow>,
          ),
          UserFoodRow,
          PrefetchHooks Function()
        > {
  $$UserFoodTableTableTableManager(_$AppDatabase db, $UserFoodTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserFoodTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserFoodTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserFoodTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<BigInt> hlcMillis = const Value.absent(),
                Value<int> hlcCounter = const Value.absent(),
                Value<String> hlcNodeId = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<double> referenceAmountG = const Value.absent(),
                Value<double> calories = const Value.absent(),
                Value<double?> protein = const Value.absent(),
                Value<double?> carbs = const Value.absent(),
                Value<double?> sugar = const Value.absent(),
                Value<double?> fat = const Value.absent(),
                Value<double?> fiber = const Value.absent(),
                Value<double?> salt = const Value.absent(),
                Value<double?> co2e100g = const Value.absent(),
                Value<String?> confidenceBand = const Value.absent(),
                Value<String?> co2Source = const Value.absent(),
                Value<String?> co2MethodologyVersion = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<List<ServingSize>> quickServingSizes =
                    const Value.absent(),
                Value<String?> overrideOfRef = const Value.absent(),
                Value<String?> overrideOfSource = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserFoodTableCompanion(
                id: id,
                hlcMillis: hlcMillis,
                hlcCounter: hlcCounter,
                hlcNodeId: hlcNodeId,
                dirty: dirty,
                deletedAt: deletedAt,
                name: name,
                brand: brand,
                category: category,
                referenceAmountG: referenceAmountG,
                calories: calories,
                protein: protein,
                carbs: carbs,
                sugar: sugar,
                fat: fat,
                fiber: fiber,
                salt: salt,
                co2e100g: co2e100g,
                confidenceBand: confidenceBand,
                co2Source: co2Source,
                co2MethodologyVersion: co2MethodologyVersion,
                barcode: barcode,
                quickServingSizes: quickServingSizes,
                overrideOfRef: overrideOfRef,
                overrideOfSource: overrideOfSource,
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
                required String name,
                Value<String?> brand = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<double> referenceAmountG = const Value.absent(),
                required double calories,
                Value<double?> protein = const Value.absent(),
                Value<double?> carbs = const Value.absent(),
                Value<double?> sugar = const Value.absent(),
                Value<double?> fat = const Value.absent(),
                Value<double?> fiber = const Value.absent(),
                Value<double?> salt = const Value.absent(),
                Value<double?> co2e100g = const Value.absent(),
                Value<String?> confidenceBand = const Value.absent(),
                Value<String?> co2Source = const Value.absent(),
                Value<String?> co2MethodologyVersion = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                required List<ServingSize> quickServingSizes,
                Value<String?> overrideOfRef = const Value.absent(),
                Value<String?> overrideOfSource = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserFoodTableCompanion.insert(
                id: id,
                hlcMillis: hlcMillis,
                hlcCounter: hlcCounter,
                hlcNodeId: hlcNodeId,
                dirty: dirty,
                deletedAt: deletedAt,
                name: name,
                brand: brand,
                category: category,
                referenceAmountG: referenceAmountG,
                calories: calories,
                protein: protein,
                carbs: carbs,
                sugar: sugar,
                fat: fat,
                fiber: fiber,
                salt: salt,
                co2e100g: co2e100g,
                confidenceBand: confidenceBand,
                co2Source: co2Source,
                co2MethodologyVersion: co2MethodologyVersion,
                barcode: barcode,
                quickServingSizes: quickServingSizes,
                overrideOfRef: overrideOfRef,
                overrideOfSource: overrideOfSource,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserFoodTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserFoodTableTable,
      UserFoodRow,
      $$UserFoodTableTableFilterComposer,
      $$UserFoodTableTableOrderingComposer,
      $$UserFoodTableTableAnnotationComposer,
      $$UserFoodTableTableCreateCompanionBuilder,
      $$UserFoodTableTableUpdateCompanionBuilder,
      (
        UserFoodRow,
        BaseReferences<_$AppDatabase, $UserFoodTableTable, UserFoodRow>,
      ),
      UserFoodRow,
      PrefetchHooks Function()
    >;
typedef $$Co2SettingsTableTableCreateCompanionBuilder =
    Co2SettingsTableCompanion Function({
      required String id,
      required BigInt hlcMillis,
      required int hlcCounter,
      required String hlcNodeId,
      Value<bool> dirty,
      Value<DateTime?> deletedAt,
      Value<String?> locationCountry,
      Value<String?> locationRegion,
      Value<String?> purchasingSource,
      Value<String?> shoppingTransport,
      Value<String?> cookingMethod,
      Value<String?> foodStorage,
      Value<int?> householdSize,
      Value<String?> foodWasteLevel,
      Value<int> rowid,
    });
typedef $$Co2SettingsTableTableUpdateCompanionBuilder =
    Co2SettingsTableCompanion Function({
      Value<String> id,
      Value<BigInt> hlcMillis,
      Value<int> hlcCounter,
      Value<String> hlcNodeId,
      Value<bool> dirty,
      Value<DateTime?> deletedAt,
      Value<String?> locationCountry,
      Value<String?> locationRegion,
      Value<String?> purchasingSource,
      Value<String?> shoppingTransport,
      Value<String?> cookingMethod,
      Value<String?> foodStorage,
      Value<int?> householdSize,
      Value<String?> foodWasteLevel,
      Value<int> rowid,
    });

class $$Co2SettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $Co2SettingsTableTable> {
  $$Co2SettingsTableTableFilterComposer({
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

  ColumnFilters<String> get locationCountry => $composableBuilder(
    column: $table.locationCountry,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationRegion => $composableBuilder(
    column: $table.locationRegion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get purchasingSource => $composableBuilder(
    column: $table.purchasingSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shoppingTransport => $composableBuilder(
    column: $table.shoppingTransport,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cookingMethod => $composableBuilder(
    column: $table.cookingMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodStorage => $composableBuilder(
    column: $table.foodStorage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get householdSize => $composableBuilder(
    column: $table.householdSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodWasteLevel => $composableBuilder(
    column: $table.foodWasteLevel,
    builder: (column) => ColumnFilters(column),
  );
}

class $$Co2SettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $Co2SettingsTableTable> {
  $$Co2SettingsTableTableOrderingComposer({
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

  ColumnOrderings<String> get locationCountry => $composableBuilder(
    column: $table.locationCountry,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationRegion => $composableBuilder(
    column: $table.locationRegion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purchasingSource => $composableBuilder(
    column: $table.purchasingSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shoppingTransport => $composableBuilder(
    column: $table.shoppingTransport,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cookingMethod => $composableBuilder(
    column: $table.cookingMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodStorage => $composableBuilder(
    column: $table.foodStorage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get householdSize => $composableBuilder(
    column: $table.householdSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodWasteLevel => $composableBuilder(
    column: $table.foodWasteLevel,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$Co2SettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $Co2SettingsTableTable> {
  $$Co2SettingsTableTableAnnotationComposer({
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

  GeneratedColumn<String> get locationCountry => $composableBuilder(
    column: $table.locationCountry,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locationRegion => $composableBuilder(
    column: $table.locationRegion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get purchasingSource => $composableBuilder(
    column: $table.purchasingSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shoppingTransport => $composableBuilder(
    column: $table.shoppingTransport,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cookingMethod => $composableBuilder(
    column: $table.cookingMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get foodStorage => $composableBuilder(
    column: $table.foodStorage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get householdSize => $composableBuilder(
    column: $table.householdSize,
    builder: (column) => column,
  );

  GeneratedColumn<String> get foodWasteLevel => $composableBuilder(
    column: $table.foodWasteLevel,
    builder: (column) => column,
  );
}

class $$Co2SettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $Co2SettingsTableTable,
          Co2SettingsRow,
          $$Co2SettingsTableTableFilterComposer,
          $$Co2SettingsTableTableOrderingComposer,
          $$Co2SettingsTableTableAnnotationComposer,
          $$Co2SettingsTableTableCreateCompanionBuilder,
          $$Co2SettingsTableTableUpdateCompanionBuilder,
          (
            Co2SettingsRow,
            BaseReferences<
              _$AppDatabase,
              $Co2SettingsTableTable,
              Co2SettingsRow
            >,
          ),
          Co2SettingsRow,
          PrefetchHooks Function()
        > {
  $$Co2SettingsTableTableTableManager(
    _$AppDatabase db,
    $Co2SettingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$Co2SettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$Co2SettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$Co2SettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<BigInt> hlcMillis = const Value.absent(),
                Value<int> hlcCounter = const Value.absent(),
                Value<String> hlcNodeId = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> locationCountry = const Value.absent(),
                Value<String?> locationRegion = const Value.absent(),
                Value<String?> purchasingSource = const Value.absent(),
                Value<String?> shoppingTransport = const Value.absent(),
                Value<String?> cookingMethod = const Value.absent(),
                Value<String?> foodStorage = const Value.absent(),
                Value<int?> householdSize = const Value.absent(),
                Value<String?> foodWasteLevel = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => Co2SettingsTableCompanion(
                id: id,
                hlcMillis: hlcMillis,
                hlcCounter: hlcCounter,
                hlcNodeId: hlcNodeId,
                dirty: dirty,
                deletedAt: deletedAt,
                locationCountry: locationCountry,
                locationRegion: locationRegion,
                purchasingSource: purchasingSource,
                shoppingTransport: shoppingTransport,
                cookingMethod: cookingMethod,
                foodStorage: foodStorage,
                householdSize: householdSize,
                foodWasteLevel: foodWasteLevel,
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
                Value<String?> locationCountry = const Value.absent(),
                Value<String?> locationRegion = const Value.absent(),
                Value<String?> purchasingSource = const Value.absent(),
                Value<String?> shoppingTransport = const Value.absent(),
                Value<String?> cookingMethod = const Value.absent(),
                Value<String?> foodStorage = const Value.absent(),
                Value<int?> householdSize = const Value.absent(),
                Value<String?> foodWasteLevel = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => Co2SettingsTableCompanion.insert(
                id: id,
                hlcMillis: hlcMillis,
                hlcCounter: hlcCounter,
                hlcNodeId: hlcNodeId,
                dirty: dirty,
                deletedAt: deletedAt,
                locationCountry: locationCountry,
                locationRegion: locationRegion,
                purchasingSource: purchasingSource,
                shoppingTransport: shoppingTransport,
                cookingMethod: cookingMethod,
                foodStorage: foodStorage,
                householdSize: householdSize,
                foodWasteLevel: foodWasteLevel,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$Co2SettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $Co2SettingsTableTable,
      Co2SettingsRow,
      $$Co2SettingsTableTableFilterComposer,
      $$Co2SettingsTableTableOrderingComposer,
      $$Co2SettingsTableTableAnnotationComposer,
      $$Co2SettingsTableTableCreateCompanionBuilder,
      $$Co2SettingsTableTableUpdateCompanionBuilder,
      (
        Co2SettingsRow,
        BaseReferences<_$AppDatabase, $Co2SettingsTableTable, Co2SettingsRow>,
      ),
      Co2SettingsRow,
      PrefetchHooks Function()
    >;
typedef $$WeightEntryTableTableCreateCompanionBuilder =
    WeightEntryTableCompanion Function({
      required String id,
      required BigInt hlcMillis,
      required int hlcCounter,
      required String hlcNodeId,
      Value<bool> dirty,
      Value<DateTime?> deletedAt,
      required double value,
      required WeightUnit unit,
      required DateTime loggedAt,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$WeightEntryTableTableUpdateCompanionBuilder =
    WeightEntryTableCompanion Function({
      Value<String> id,
      Value<BigInt> hlcMillis,
      Value<int> hlcCounter,
      Value<String> hlcNodeId,
      Value<bool> dirty,
      Value<DateTime?> deletedAt,
      Value<double> value,
      Value<WeightUnit> unit,
      Value<DateTime> loggedAt,
      Value<String?> note,
      Value<int> rowid,
    });

class $$WeightEntryTableTableFilterComposer
    extends Composer<_$AppDatabase, $WeightEntryTableTable> {
  $$WeightEntryTableTableFilterComposer({
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

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<WeightUnit, WeightUnit, String> get unit =>
      $composableBuilder(
        column: $table.unit,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WeightEntryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $WeightEntryTableTable> {
  $$WeightEntryTableTableOrderingComposer({
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

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WeightEntryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeightEntryTableTable> {
  $$WeightEntryTableTableAnnotationComposer({
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

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumnWithTypeConverter<WeightUnit, String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<DateTime> get loggedAt =>
      $composableBuilder(column: $table.loggedAt, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$WeightEntryTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WeightEntryTableTable,
          WeightEntryRow,
          $$WeightEntryTableTableFilterComposer,
          $$WeightEntryTableTableOrderingComposer,
          $$WeightEntryTableTableAnnotationComposer,
          $$WeightEntryTableTableCreateCompanionBuilder,
          $$WeightEntryTableTableUpdateCompanionBuilder,
          (
            WeightEntryRow,
            BaseReferences<
              _$AppDatabase,
              $WeightEntryTableTable,
              WeightEntryRow
            >,
          ),
          WeightEntryRow,
          PrefetchHooks Function()
        > {
  $$WeightEntryTableTableTableManager(
    _$AppDatabase db,
    $WeightEntryTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeightEntryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeightEntryTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeightEntryTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<BigInt> hlcMillis = const Value.absent(),
                Value<int> hlcCounter = const Value.absent(),
                Value<String> hlcNodeId = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<double> value = const Value.absent(),
                Value<WeightUnit> unit = const Value.absent(),
                Value<DateTime> loggedAt = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WeightEntryTableCompanion(
                id: id,
                hlcMillis: hlcMillis,
                hlcCounter: hlcCounter,
                hlcNodeId: hlcNodeId,
                dirty: dirty,
                deletedAt: deletedAt,
                value: value,
                unit: unit,
                loggedAt: loggedAt,
                note: note,
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
                required double value,
                required WeightUnit unit,
                required DateTime loggedAt,
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WeightEntryTableCompanion.insert(
                id: id,
                hlcMillis: hlcMillis,
                hlcCounter: hlcCounter,
                hlcNodeId: hlcNodeId,
                dirty: dirty,
                deletedAt: deletedAt,
                value: value,
                unit: unit,
                loggedAt: loggedAt,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeightEntryTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WeightEntryTableTable,
      WeightEntryRow,
      $$WeightEntryTableTableFilterComposer,
      $$WeightEntryTableTableOrderingComposer,
      $$WeightEntryTableTableAnnotationComposer,
      $$WeightEntryTableTableCreateCompanionBuilder,
      $$WeightEntryTableTableUpdateCompanionBuilder,
      (
        WeightEntryRow,
        BaseReferences<_$AppDatabase, $WeightEntryTableTable, WeightEntryRow>,
      ),
      WeightEntryRow,
      PrefetchHooks Function()
    >;
typedef $$WeightSettingsTableTableCreateCompanionBuilder =
    WeightSettingsTableCompanion Function({
      required String id,
      required BigInt hlcMillis,
      required int hlcCounter,
      required String hlcNodeId,
      Value<bool> dirty,
      Value<DateTime?> deletedAt,
      Value<double?> targetWeightKg,
      Value<DateTime?> targetDate,
      Value<String?> reminderFrequency,
      Value<int?> reminderWeekday,
      Value<String?> reminderTime,
      Value<bool> reminderEnabled,
      Value<int> rowid,
    });
typedef $$WeightSettingsTableTableUpdateCompanionBuilder =
    WeightSettingsTableCompanion Function({
      Value<String> id,
      Value<BigInt> hlcMillis,
      Value<int> hlcCounter,
      Value<String> hlcNodeId,
      Value<bool> dirty,
      Value<DateTime?> deletedAt,
      Value<double?> targetWeightKg,
      Value<DateTime?> targetDate,
      Value<String?> reminderFrequency,
      Value<int?> reminderWeekday,
      Value<String?> reminderTime,
      Value<bool> reminderEnabled,
      Value<int> rowid,
    });

class $$WeightSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $WeightSettingsTableTable> {
  $$WeightSettingsTableTableFilterComposer({
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

  ColumnFilters<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminderFrequency => $composableBuilder(
    column: $table.reminderFrequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderWeekday => $composableBuilder(
    column: $table.reminderWeekday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WeightSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $WeightSettingsTableTable> {
  $$WeightSettingsTableTableOrderingComposer({
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

  ColumnOrderings<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderFrequency => $composableBuilder(
    column: $table.reminderFrequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderWeekday => $composableBuilder(
    column: $table.reminderWeekday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WeightSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeightSettingsTableTable> {
  $$WeightSettingsTableTableAnnotationComposer({
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

  GeneratedColumn<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reminderFrequency => $composableBuilder(
    column: $table.reminderFrequency,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderWeekday => $composableBuilder(
    column: $table.reminderWeekday,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => column,
  );
}

class $$WeightSettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WeightSettingsTableTable,
          WeightSettingsRow,
          $$WeightSettingsTableTableFilterComposer,
          $$WeightSettingsTableTableOrderingComposer,
          $$WeightSettingsTableTableAnnotationComposer,
          $$WeightSettingsTableTableCreateCompanionBuilder,
          $$WeightSettingsTableTableUpdateCompanionBuilder,
          (
            WeightSettingsRow,
            BaseReferences<
              _$AppDatabase,
              $WeightSettingsTableTable,
              WeightSettingsRow
            >,
          ),
          WeightSettingsRow,
          PrefetchHooks Function()
        > {
  $$WeightSettingsTableTableTableManager(
    _$AppDatabase db,
    $WeightSettingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeightSettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeightSettingsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WeightSettingsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<BigInt> hlcMillis = const Value.absent(),
                Value<int> hlcCounter = const Value.absent(),
                Value<String> hlcNodeId = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<double?> targetWeightKg = const Value.absent(),
                Value<DateTime?> targetDate = const Value.absent(),
                Value<String?> reminderFrequency = const Value.absent(),
                Value<int?> reminderWeekday = const Value.absent(),
                Value<String?> reminderTime = const Value.absent(),
                Value<bool> reminderEnabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WeightSettingsTableCompanion(
                id: id,
                hlcMillis: hlcMillis,
                hlcCounter: hlcCounter,
                hlcNodeId: hlcNodeId,
                dirty: dirty,
                deletedAt: deletedAt,
                targetWeightKg: targetWeightKg,
                targetDate: targetDate,
                reminderFrequency: reminderFrequency,
                reminderWeekday: reminderWeekday,
                reminderTime: reminderTime,
                reminderEnabled: reminderEnabled,
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
                Value<double?> targetWeightKg = const Value.absent(),
                Value<DateTime?> targetDate = const Value.absent(),
                Value<String?> reminderFrequency = const Value.absent(),
                Value<int?> reminderWeekday = const Value.absent(),
                Value<String?> reminderTime = const Value.absent(),
                Value<bool> reminderEnabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WeightSettingsTableCompanion.insert(
                id: id,
                hlcMillis: hlcMillis,
                hlcCounter: hlcCounter,
                hlcNodeId: hlcNodeId,
                dirty: dirty,
                deletedAt: deletedAt,
                targetWeightKg: targetWeightKg,
                targetDate: targetDate,
                reminderFrequency: reminderFrequency,
                reminderWeekday: reminderWeekday,
                reminderTime: reminderTime,
                reminderEnabled: reminderEnabled,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeightSettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WeightSettingsTableTable,
      WeightSettingsRow,
      $$WeightSettingsTableTableFilterComposer,
      $$WeightSettingsTableTableOrderingComposer,
      $$WeightSettingsTableTableAnnotationComposer,
      $$WeightSettingsTableTableCreateCompanionBuilder,
      $$WeightSettingsTableTableUpdateCompanionBuilder,
      (
        WeightSettingsRow,
        BaseReferences<
          _$AppDatabase,
          $WeightSettingsTableTable,
          WeightSettingsRow
        >,
      ),
      WeightSettingsRow,
      PrefetchHooks Function()
    >;
typedef $$NotificationPrefsTableTableCreateCompanionBuilder =
    NotificationPrefsTableCompanion Function({
      required String id,
      required BigInt hlcMillis,
      required int hlcCounter,
      required String hlcNodeId,
      Value<bool> dirty,
      Value<DateTime?> deletedAt,
      Value<bool> breakfastEnabled,
      Value<String?> breakfastTime,
      Value<bool> lunchEnabled,
      Value<String?> lunchTime,
      Value<bool> dinnerEnabled,
      Value<String?> dinnerTime,
      Value<bool> snackEnabled,
      Value<String?> snackTime,
      Value<int> rowid,
    });
typedef $$NotificationPrefsTableTableUpdateCompanionBuilder =
    NotificationPrefsTableCompanion Function({
      Value<String> id,
      Value<BigInt> hlcMillis,
      Value<int> hlcCounter,
      Value<String> hlcNodeId,
      Value<bool> dirty,
      Value<DateTime?> deletedAt,
      Value<bool> breakfastEnabled,
      Value<String?> breakfastTime,
      Value<bool> lunchEnabled,
      Value<String?> lunchTime,
      Value<bool> dinnerEnabled,
      Value<String?> dinnerTime,
      Value<bool> snackEnabled,
      Value<String?> snackTime,
      Value<int> rowid,
    });

class $$NotificationPrefsTableTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationPrefsTableTable> {
  $$NotificationPrefsTableTableFilterComposer({
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

  ColumnFilters<bool> get breakfastEnabled => $composableBuilder(
    column: $table.breakfastEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get breakfastTime => $composableBuilder(
    column: $table.breakfastTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get lunchEnabled => $composableBuilder(
    column: $table.lunchEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lunchTime => $composableBuilder(
    column: $table.lunchTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dinnerEnabled => $composableBuilder(
    column: $table.dinnerEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dinnerTime => $composableBuilder(
    column: $table.dinnerTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get snackEnabled => $composableBuilder(
    column: $table.snackEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get snackTime => $composableBuilder(
    column: $table.snackTime,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotificationPrefsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationPrefsTableTable> {
  $$NotificationPrefsTableTableOrderingComposer({
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

  ColumnOrderings<bool> get breakfastEnabled => $composableBuilder(
    column: $table.breakfastEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get breakfastTime => $composableBuilder(
    column: $table.breakfastTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get lunchEnabled => $composableBuilder(
    column: $table.lunchEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lunchTime => $composableBuilder(
    column: $table.lunchTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dinnerEnabled => $composableBuilder(
    column: $table.dinnerEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dinnerTime => $composableBuilder(
    column: $table.dinnerTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get snackEnabled => $composableBuilder(
    column: $table.snackEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snackTime => $composableBuilder(
    column: $table.snackTime,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotificationPrefsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationPrefsTableTable> {
  $$NotificationPrefsTableTableAnnotationComposer({
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

  GeneratedColumn<bool> get breakfastEnabled => $composableBuilder(
    column: $table.breakfastEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get breakfastTime => $composableBuilder(
    column: $table.breakfastTime,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get lunchEnabled => $composableBuilder(
    column: $table.lunchEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lunchTime =>
      $composableBuilder(column: $table.lunchTime, builder: (column) => column);

  GeneratedColumn<bool> get dinnerEnabled => $composableBuilder(
    column: $table.dinnerEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dinnerTime => $composableBuilder(
    column: $table.dinnerTime,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get snackEnabled => $composableBuilder(
    column: $table.snackEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get snackTime =>
      $composableBuilder(column: $table.snackTime, builder: (column) => column);
}

class $$NotificationPrefsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationPrefsTableTable,
          NotificationPrefsRow,
          $$NotificationPrefsTableTableFilterComposer,
          $$NotificationPrefsTableTableOrderingComposer,
          $$NotificationPrefsTableTableAnnotationComposer,
          $$NotificationPrefsTableTableCreateCompanionBuilder,
          $$NotificationPrefsTableTableUpdateCompanionBuilder,
          (
            NotificationPrefsRow,
            BaseReferences<
              _$AppDatabase,
              $NotificationPrefsTableTable,
              NotificationPrefsRow
            >,
          ),
          NotificationPrefsRow,
          PrefetchHooks Function()
        > {
  $$NotificationPrefsTableTableTableManager(
    _$AppDatabase db,
    $NotificationPrefsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationPrefsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$NotificationPrefsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NotificationPrefsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<BigInt> hlcMillis = const Value.absent(),
                Value<int> hlcCounter = const Value.absent(),
                Value<String> hlcNodeId = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<bool> breakfastEnabled = const Value.absent(),
                Value<String?> breakfastTime = const Value.absent(),
                Value<bool> lunchEnabled = const Value.absent(),
                Value<String?> lunchTime = const Value.absent(),
                Value<bool> dinnerEnabled = const Value.absent(),
                Value<String?> dinnerTime = const Value.absent(),
                Value<bool> snackEnabled = const Value.absent(),
                Value<String?> snackTime = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotificationPrefsTableCompanion(
                id: id,
                hlcMillis: hlcMillis,
                hlcCounter: hlcCounter,
                hlcNodeId: hlcNodeId,
                dirty: dirty,
                deletedAt: deletedAt,
                breakfastEnabled: breakfastEnabled,
                breakfastTime: breakfastTime,
                lunchEnabled: lunchEnabled,
                lunchTime: lunchTime,
                dinnerEnabled: dinnerEnabled,
                dinnerTime: dinnerTime,
                snackEnabled: snackEnabled,
                snackTime: snackTime,
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
                Value<bool> breakfastEnabled = const Value.absent(),
                Value<String?> breakfastTime = const Value.absent(),
                Value<bool> lunchEnabled = const Value.absent(),
                Value<String?> lunchTime = const Value.absent(),
                Value<bool> dinnerEnabled = const Value.absent(),
                Value<String?> dinnerTime = const Value.absent(),
                Value<bool> snackEnabled = const Value.absent(),
                Value<String?> snackTime = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotificationPrefsTableCompanion.insert(
                id: id,
                hlcMillis: hlcMillis,
                hlcCounter: hlcCounter,
                hlcNodeId: hlcNodeId,
                dirty: dirty,
                deletedAt: deletedAt,
                breakfastEnabled: breakfastEnabled,
                breakfastTime: breakfastTime,
                lunchEnabled: lunchEnabled,
                lunchTime: lunchTime,
                dinnerEnabled: dinnerEnabled,
                dinnerTime: dinnerTime,
                snackEnabled: snackEnabled,
                snackTime: snackTime,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotificationPrefsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationPrefsTableTable,
      NotificationPrefsRow,
      $$NotificationPrefsTableTableFilterComposer,
      $$NotificationPrefsTableTableOrderingComposer,
      $$NotificationPrefsTableTableAnnotationComposer,
      $$NotificationPrefsTableTableCreateCompanionBuilder,
      $$NotificationPrefsTableTableUpdateCompanionBuilder,
      (
        NotificationPrefsRow,
        BaseReferences<
          _$AppDatabase,
          $NotificationPrefsTableTable,
          NotificationPrefsRow
        >,
      ),
      NotificationPrefsRow,
      PrefetchHooks Function()
    >;
typedef $$BackupMetadataTableTableCreateCompanionBuilder =
    BackupMetadataTableCompanion Function({
      required String id,
      required BigInt hlcMillis,
      required int hlcCounter,
      required String hlcNodeId,
      Value<bool> dirty,
      Value<DateTime?> deletedAt,
      Value<String> autoBackupFrequency,
      Value<DateTime?> lastBackupAt,
      Value<String?> lastBackupPath,
      Value<int> rowid,
    });
typedef $$BackupMetadataTableTableUpdateCompanionBuilder =
    BackupMetadataTableCompanion Function({
      Value<String> id,
      Value<BigInt> hlcMillis,
      Value<int> hlcCounter,
      Value<String> hlcNodeId,
      Value<bool> dirty,
      Value<DateTime?> deletedAt,
      Value<String> autoBackupFrequency,
      Value<DateTime?> lastBackupAt,
      Value<String?> lastBackupPath,
      Value<int> rowid,
    });

class $$BackupMetadataTableTableFilterComposer
    extends Composer<_$AppDatabase, $BackupMetadataTableTable> {
  $$BackupMetadataTableTableFilterComposer({
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

  ColumnFilters<String> get autoBackupFrequency => $composableBuilder(
    column: $table.autoBackupFrequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastBackupAt => $composableBuilder(
    column: $table.lastBackupAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastBackupPath => $composableBuilder(
    column: $table.lastBackupPath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BackupMetadataTableTableOrderingComposer
    extends Composer<_$AppDatabase, $BackupMetadataTableTable> {
  $$BackupMetadataTableTableOrderingComposer({
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

  ColumnOrderings<String> get autoBackupFrequency => $composableBuilder(
    column: $table.autoBackupFrequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastBackupAt => $composableBuilder(
    column: $table.lastBackupAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastBackupPath => $composableBuilder(
    column: $table.lastBackupPath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BackupMetadataTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $BackupMetadataTableTable> {
  $$BackupMetadataTableTableAnnotationComposer({
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

  GeneratedColumn<String> get autoBackupFrequency => $composableBuilder(
    column: $table.autoBackupFrequency,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastBackupAt => $composableBuilder(
    column: $table.lastBackupAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastBackupPath => $composableBuilder(
    column: $table.lastBackupPath,
    builder: (column) => column,
  );
}

class $$BackupMetadataTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BackupMetadataTableTable,
          BackupMetadataRow,
          $$BackupMetadataTableTableFilterComposer,
          $$BackupMetadataTableTableOrderingComposer,
          $$BackupMetadataTableTableAnnotationComposer,
          $$BackupMetadataTableTableCreateCompanionBuilder,
          $$BackupMetadataTableTableUpdateCompanionBuilder,
          (
            BackupMetadataRow,
            BaseReferences<
              _$AppDatabase,
              $BackupMetadataTableTable,
              BackupMetadataRow
            >,
          ),
          BackupMetadataRow,
          PrefetchHooks Function()
        > {
  $$BackupMetadataTableTableTableManager(
    _$AppDatabase db,
    $BackupMetadataTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BackupMetadataTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BackupMetadataTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$BackupMetadataTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<BigInt> hlcMillis = const Value.absent(),
                Value<int> hlcCounter = const Value.absent(),
                Value<String> hlcNodeId = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> autoBackupFrequency = const Value.absent(),
                Value<DateTime?> lastBackupAt = const Value.absent(),
                Value<String?> lastBackupPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BackupMetadataTableCompanion(
                id: id,
                hlcMillis: hlcMillis,
                hlcCounter: hlcCounter,
                hlcNodeId: hlcNodeId,
                dirty: dirty,
                deletedAt: deletedAt,
                autoBackupFrequency: autoBackupFrequency,
                lastBackupAt: lastBackupAt,
                lastBackupPath: lastBackupPath,
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
                Value<String> autoBackupFrequency = const Value.absent(),
                Value<DateTime?> lastBackupAt = const Value.absent(),
                Value<String?> lastBackupPath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BackupMetadataTableCompanion.insert(
                id: id,
                hlcMillis: hlcMillis,
                hlcCounter: hlcCounter,
                hlcNodeId: hlcNodeId,
                dirty: dirty,
                deletedAt: deletedAt,
                autoBackupFrequency: autoBackupFrequency,
                lastBackupAt: lastBackupAt,
                lastBackupPath: lastBackupPath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BackupMetadataTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BackupMetadataTableTable,
      BackupMetadataRow,
      $$BackupMetadataTableTableFilterComposer,
      $$BackupMetadataTableTableOrderingComposer,
      $$BackupMetadataTableTableAnnotationComposer,
      $$BackupMetadataTableTableCreateCompanionBuilder,
      $$BackupMetadataTableTableUpdateCompanionBuilder,
      (
        BackupMetadataRow,
        BaseReferences<
          _$AppDatabase,
          $BackupMetadataTableTable,
          BackupMetadataRow
        >,
      ),
      BackupMetadataRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $UserFoodCacheFtsTableManager get userFoodCacheFts =>
      $UserFoodCacheFtsTableManager(_db, _db.userFoodCacheFts);
  $$UserProfileTableTableTableManager get userProfileTable =>
      $$UserProfileTableTableTableManager(_db, _db.userProfileTable);
  $$ConsentRecordsTableTableTableManager get consentRecordsTable =>
      $$ConsentRecordsTableTableTableManager(_db, _db.consentRecordsTable);
  $$UserFoodCacheTableTableTableManager get userFoodCacheTable =>
      $$UserFoodCacheTableTableTableManager(_db, _db.userFoodCacheTable);
  $$MealEntryTableTableTableManager get mealEntryTable =>
      $$MealEntryTableTableTableManager(_db, _db.mealEntryTable);
  $$FavoriteTableTableTableManager get favoriteTable =>
      $$FavoriteTableTableTableManager(_db, _db.favoriteTable);
  $$UserFoodTableTableTableManager get userFoodTable =>
      $$UserFoodTableTableTableManager(_db, _db.userFoodTable);
  $$Co2SettingsTableTableTableManager get co2SettingsTable =>
      $$Co2SettingsTableTableTableManager(_db, _db.co2SettingsTable);
  $$WeightEntryTableTableTableManager get weightEntryTable =>
      $$WeightEntryTableTableTableManager(_db, _db.weightEntryTable);
  $$WeightSettingsTableTableTableManager get weightSettingsTable =>
      $$WeightSettingsTableTableTableManager(_db, _db.weightSettingsTable);
  $$NotificationPrefsTableTableTableManager get notificationPrefsTable =>
      $$NotificationPrefsTableTableTableManager(
        _db,
        _db.notificationPrefsTable,
      );
  $$BackupMetadataTableTableTableManager get backupMetadataTable =>
      $$BackupMetadataTableTableTableManager(_db, _db.backupMetadataTable);
}
