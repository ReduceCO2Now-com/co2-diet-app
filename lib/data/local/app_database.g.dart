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
    co2e100gSnapshot,
    confidenceBandSnapshot,
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
      co2e100gSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}co2e100g_snapshot'],
      ),
      confidenceBandSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}confidence_band_snapshot'],
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

  /// kg CO2e per kg product, captured at log time.
  final double? co2e100gSnapshot;

  /// Confidence band ('high'/'medium'/'low'), captured at log time.
  final String? confidenceBandSnapshot;

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
    this.co2e100gSnapshot,
    this.confidenceBandSnapshot,
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
    if (!nullToAbsent || co2e100gSnapshot != null) {
      map['co2e100g_snapshot'] = Variable<double>(co2e100gSnapshot);
    }
    if (!nullToAbsent || confidenceBandSnapshot != null) {
      map['confidence_band_snapshot'] = Variable<String>(
        confidenceBandSnapshot,
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
      co2e100gSnapshot: co2e100gSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(co2e100gSnapshot),
      confidenceBandSnapshot: confidenceBandSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(confidenceBandSnapshot),
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
      co2e100gSnapshot: serializer.fromJson<double?>(json['co2e100gSnapshot']),
      confidenceBandSnapshot: serializer.fromJson<String?>(
        json['confidenceBandSnapshot'],
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
      'co2e100gSnapshot': serializer.toJson<double?>(co2e100gSnapshot),
      'confidenceBandSnapshot': serializer.toJson<String?>(
        confidenceBandSnapshot,
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
    Value<double?> co2e100gSnapshot = const Value.absent(),
    Value<String?> confidenceBandSnapshot = const Value.absent(),
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
    co2e100gSnapshot: co2e100gSnapshot.present
        ? co2e100gSnapshot.value
        : this.co2e100gSnapshot,
    confidenceBandSnapshot: confidenceBandSnapshot.present
        ? confidenceBandSnapshot.value
        : this.confidenceBandSnapshot,
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
      co2e100gSnapshot: data.co2e100gSnapshot.present
          ? data.co2e100gSnapshot.value
          : this.co2e100gSnapshot,
      confidenceBandSnapshot: data.confidenceBandSnapshot.present
          ? data.confidenceBandSnapshot.value
          : this.confidenceBandSnapshot,
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
          ..write('co2e100gSnapshot: $co2e100gSnapshot, ')
          ..write('confidenceBandSnapshot: $confidenceBandSnapshot, ')
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
    co2e100gSnapshot,
    confidenceBandSnapshot,
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
          other.co2e100gSnapshot == this.co2e100gSnapshot &&
          other.confidenceBandSnapshot == this.confidenceBandSnapshot &&
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
  final Value<double?> co2e100gSnapshot;
  final Value<String?> confidenceBandSnapshot;
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
    this.co2e100gSnapshot = const Value.absent(),
    this.confidenceBandSnapshot = const Value.absent(),
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
    this.co2e100gSnapshot = const Value.absent(),
    this.confidenceBandSnapshot = const Value.absent(),
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
    Expression<double>? co2e100gSnapshot,
    Expression<String>? confidenceBandSnapshot,
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
      if (co2e100gSnapshot != null) 'co2e100g_snapshot': co2e100gSnapshot,
      if (confidenceBandSnapshot != null)
        'confidence_band_snapshot': confidenceBandSnapshot,
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
    Value<double?>? co2e100gSnapshot,
    Value<String?>? confidenceBandSnapshot,
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
      co2e100gSnapshot: co2e100gSnapshot ?? this.co2e100gSnapshot,
      confidenceBandSnapshot:
          confidenceBandSnapshot ?? this.confidenceBandSnapshot,
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
    if (co2e100gSnapshot.present) {
      map['co2e100g_snapshot'] = Variable<double>(co2e100gSnapshot.value);
    }
    if (confidenceBandSnapshot.present) {
      map['confidence_band_snapshot'] = Variable<String>(
        confidenceBandSnapshot.value,
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
          ..write('co2e100gSnapshot: $co2e100gSnapshot, ')
          ..write('confidenceBandSnapshot: $confidenceBandSnapshot, ')
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
          ..write('barcode: $barcode, ')
          ..write('quickServingSizes: $quickServingSizes, ')
          ..write('overrideOfRef: $overrideOfRef, ')
          ..write('overrideOfSource: $overrideOfSource, ')
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
  late final UserProfileDao userProfileDao = UserProfileDao(
    this as AppDatabase,
  );
  late final ConsentRecordsDao consentRecordsDao = ConsentRecordsDao(
    this as AppDatabase,
  );
  late final FoodCatalogDao foodCatalogDao = FoodCatalogDao(
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
      Value<double?> co2e100gSnapshot,
      Value<String?> confidenceBandSnapshot,
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
      Value<double?> co2e100gSnapshot,
      Value<String?> confidenceBandSnapshot,
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

  ColumnFilters<double> get co2e100gSnapshot => $composableBuilder(
    column: $table.co2e100gSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get confidenceBandSnapshot => $composableBuilder(
    column: $table.confidenceBandSnapshot,
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

  ColumnOrderings<double> get co2e100gSnapshot => $composableBuilder(
    column: $table.co2e100gSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confidenceBandSnapshot => $composableBuilder(
    column: $table.confidenceBandSnapshot,
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

  GeneratedColumn<double> get co2e100gSnapshot => $composableBuilder(
    column: $table.co2e100gSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get confidenceBandSnapshot => $composableBuilder(
    column: $table.confidenceBandSnapshot,
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
                Value<double?> co2e100gSnapshot = const Value.absent(),
                Value<String?> confidenceBandSnapshot = const Value.absent(),
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
                co2e100gSnapshot: co2e100gSnapshot,
                confidenceBandSnapshot: confidenceBandSnapshot,
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
                Value<double?> co2e100gSnapshot = const Value.absent(),
                Value<String?> confidenceBandSnapshot = const Value.absent(),
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
                co2e100gSnapshot: co2e100gSnapshot,
                confidenceBandSnapshot: confidenceBandSnapshot,
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
}
