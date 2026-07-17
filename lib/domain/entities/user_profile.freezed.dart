// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UserProfile {

/// UUID v7 primary key (time-ordered).
 String get id;/// User's age in years. `null` until the user provides it.
 int? get age;/// Biological sex string: `'male'`, `'female'`, or `'other'`.
 String? get gender;/// Height in centimetres. `null` until provided.
 double? get heightCm;/// Weight in kilograms. `null` until provided.
 double? get weightKg;/// Physical activity level: `'low'`, `'medium'`, or `'high'`.
 String? get activityLevel;/// User's dietary preference (free-form string, e.g. `'vegan'`).
 String? get dietaryPreference;/// User's primary goal, e.g. `'reduce_co2'`, `'lose_weight'`.
 String? get goal;/// Measurement system in use. Defaults to `'metric'`.
 String get units;/// Version tag for the CO₂ methodology data used to compute CO₂ targets.
 String get co2MethodologyVersion;/// BCP-47 locale tag for locale-sensitive formatting, e.g. `'de-DE'`.
 String? get localeTag;/// Computed macro/calorie targets. `null` until first save.
 CalcTargets? get targets;/// UTC timestamp when this profile record was first created.
 DateTime? get createdAt;/// UTC timestamp when this profile record was last modified.
 DateTime? get updatedAt;
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileCopyWith<UserProfile> get copyWith => _$UserProfileCopyWithImpl<UserProfile>(this as UserProfile, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.age, age) || other.age == age)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.activityLevel, activityLevel) || other.activityLevel == activityLevel)&&(identical(other.dietaryPreference, dietaryPreference) || other.dietaryPreference == dietaryPreference)&&(identical(other.goal, goal) || other.goal == goal)&&(identical(other.units, units) || other.units == units)&&(identical(other.co2MethodologyVersion, co2MethodologyVersion) || other.co2MethodologyVersion == co2MethodologyVersion)&&(identical(other.localeTag, localeTag) || other.localeTag == localeTag)&&(identical(other.targets, targets) || other.targets == targets)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,age,gender,heightCm,weightKg,activityLevel,dietaryPreference,goal,units,co2MethodologyVersion,localeTag,targets,createdAt,updatedAt);

@override
String toString() {
  return 'UserProfile(id: $id, age: $age, gender: $gender, heightCm: $heightCm, weightKg: $weightKg, activityLevel: $activityLevel, dietaryPreference: $dietaryPreference, goal: $goal, units: $units, co2MethodologyVersion: $co2MethodologyVersion, localeTag: $localeTag, targets: $targets, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $UserProfileCopyWith<$Res>  {
  factory $UserProfileCopyWith(UserProfile value, $Res Function(UserProfile) _then) = _$UserProfileCopyWithImpl;
@useResult
$Res call({
 String id, int? age, String? gender, double? heightCm, double? weightKg, String? activityLevel, String? dietaryPreference, String? goal, String units, String co2MethodologyVersion, String? localeTag, CalcTargets? targets, DateTime? createdAt, DateTime? updatedAt
});


$CalcTargetsCopyWith<$Res>? get targets;

}
/// @nodoc
class _$UserProfileCopyWithImpl<$Res>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._self, this._then);

  final UserProfile _self;
  final $Res Function(UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? age = freezed,Object? gender = freezed,Object? heightCm = freezed,Object? weightKg = freezed,Object? activityLevel = freezed,Object? dietaryPreference = freezed,Object? goal = freezed,Object? units = null,Object? co2MethodologyVersion = null,Object? localeTag = freezed,Object? targets = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,heightCm: freezed == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as double?,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,activityLevel: freezed == activityLevel ? _self.activityLevel : activityLevel // ignore: cast_nullable_to_non_nullable
as String?,dietaryPreference: freezed == dietaryPreference ? _self.dietaryPreference : dietaryPreference // ignore: cast_nullable_to_non_nullable
as String?,goal: freezed == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as String?,units: null == units ? _self.units : units // ignore: cast_nullable_to_non_nullable
as String,co2MethodologyVersion: null == co2MethodologyVersion ? _self.co2MethodologyVersion : co2MethodologyVersion // ignore: cast_nullable_to_non_nullable
as String,localeTag: freezed == localeTag ? _self.localeTag : localeTag // ignore: cast_nullable_to_non_nullable
as String?,targets: freezed == targets ? _self.targets : targets // ignore: cast_nullable_to_non_nullable
as CalcTargets?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CalcTargetsCopyWith<$Res>? get targets {
    if (_self.targets == null) {
    return null;
  }

  return $CalcTargetsCopyWith<$Res>(_self.targets!, (value) {
    return _then(_self.copyWith(targets: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserProfile].
extension UserProfilePatterns on UserProfile {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfile value)  $default,){
final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfile value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  int? age,  String? gender,  double? heightCm,  double? weightKg,  String? activityLevel,  String? dietaryPreference,  String? goal,  String units,  String co2MethodologyVersion,  String? localeTag,  CalcTargets? targets,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.id,_that.age,_that.gender,_that.heightCm,_that.weightKg,_that.activityLevel,_that.dietaryPreference,_that.goal,_that.units,_that.co2MethodologyVersion,_that.localeTag,_that.targets,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  int? age,  String? gender,  double? heightCm,  double? weightKg,  String? activityLevel,  String? dietaryPreference,  String? goal,  String units,  String co2MethodologyVersion,  String? localeTag,  CalcTargets? targets,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that.id,_that.age,_that.gender,_that.heightCm,_that.weightKg,_that.activityLevel,_that.dietaryPreference,_that.goal,_that.units,_that.co2MethodologyVersion,_that.localeTag,_that.targets,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  int? age,  String? gender,  double? heightCm,  double? weightKg,  String? activityLevel,  String? dietaryPreference,  String? goal,  String units,  String co2MethodologyVersion,  String? localeTag,  CalcTargets? targets,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.id,_that.age,_that.gender,_that.heightCm,_that.weightKg,_that.activityLevel,_that.dietaryPreference,_that.goal,_that.units,_that.co2MethodologyVersion,_that.localeTag,_that.targets,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _UserProfile implements UserProfile {
  const _UserProfile({required this.id, this.age, this.gender, this.heightCm, this.weightKg, this.activityLevel, this.dietaryPreference, this.goal, this.units = 'metric', this.co2MethodologyVersion = '1.0', this.localeTag, this.targets, this.createdAt, this.updatedAt});
  

/// UUID v7 primary key (time-ordered).
@override final  String id;
/// User's age in years. `null` until the user provides it.
@override final  int? age;
/// Biological sex string: `'male'`, `'female'`, or `'other'`.
@override final  String? gender;
/// Height in centimetres. `null` until provided.
@override final  double? heightCm;
/// Weight in kilograms. `null` until provided.
@override final  double? weightKg;
/// Physical activity level: `'low'`, `'medium'`, or `'high'`.
@override final  String? activityLevel;
/// User's dietary preference (free-form string, e.g. `'vegan'`).
@override final  String? dietaryPreference;
/// User's primary goal, e.g. `'reduce_co2'`, `'lose_weight'`.
@override final  String? goal;
/// Measurement system in use. Defaults to `'metric'`.
@override@JsonKey() final  String units;
/// Version tag for the CO₂ methodology data used to compute CO₂ targets.
@override@JsonKey() final  String co2MethodologyVersion;
/// BCP-47 locale tag for locale-sensitive formatting, e.g. `'de-DE'`.
@override final  String? localeTag;
/// Computed macro/calorie targets. `null` until first save.
@override final  CalcTargets? targets;
/// UTC timestamp when this profile record was first created.
@override final  DateTime? createdAt;
/// UTC timestamp when this profile record was last modified.
@override final  DateTime? updatedAt;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileCopyWith<_UserProfile> get copyWith => __$UserProfileCopyWithImpl<_UserProfile>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.age, age) || other.age == age)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.heightCm, heightCm) || other.heightCm == heightCm)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.activityLevel, activityLevel) || other.activityLevel == activityLevel)&&(identical(other.dietaryPreference, dietaryPreference) || other.dietaryPreference == dietaryPreference)&&(identical(other.goal, goal) || other.goal == goal)&&(identical(other.units, units) || other.units == units)&&(identical(other.co2MethodologyVersion, co2MethodologyVersion) || other.co2MethodologyVersion == co2MethodologyVersion)&&(identical(other.localeTag, localeTag) || other.localeTag == localeTag)&&(identical(other.targets, targets) || other.targets == targets)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,age,gender,heightCm,weightKg,activityLevel,dietaryPreference,goal,units,co2MethodologyVersion,localeTag,targets,createdAt,updatedAt);

@override
String toString() {
  return 'UserProfile(id: $id, age: $age, gender: $gender, heightCm: $heightCm, weightKg: $weightKg, activityLevel: $activityLevel, dietaryPreference: $dietaryPreference, goal: $goal, units: $units, co2MethodologyVersion: $co2MethodologyVersion, localeTag: $localeTag, targets: $targets, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$UserProfileCopyWith<$Res> implements $UserProfileCopyWith<$Res> {
  factory _$UserProfileCopyWith(_UserProfile value, $Res Function(_UserProfile) _then) = __$UserProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, int? age, String? gender, double? heightCm, double? weightKg, String? activityLevel, String? dietaryPreference, String? goal, String units, String co2MethodologyVersion, String? localeTag, CalcTargets? targets, DateTime? createdAt, DateTime? updatedAt
});


@override $CalcTargetsCopyWith<$Res>? get targets;

}
/// @nodoc
class __$UserProfileCopyWithImpl<$Res>
    implements _$UserProfileCopyWith<$Res> {
  __$UserProfileCopyWithImpl(this._self, this._then);

  final _UserProfile _self;
  final $Res Function(_UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? age = freezed,Object? gender = freezed,Object? heightCm = freezed,Object? weightKg = freezed,Object? activityLevel = freezed,Object? dietaryPreference = freezed,Object? goal = freezed,Object? units = null,Object? co2MethodologyVersion = null,Object? localeTag = freezed,Object? targets = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_UserProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,age: freezed == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,heightCm: freezed == heightCm ? _self.heightCm : heightCm // ignore: cast_nullable_to_non_nullable
as double?,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,activityLevel: freezed == activityLevel ? _self.activityLevel : activityLevel // ignore: cast_nullable_to_non_nullable
as String?,dietaryPreference: freezed == dietaryPreference ? _self.dietaryPreference : dietaryPreference // ignore: cast_nullable_to_non_nullable
as String?,goal: freezed == goal ? _self.goal : goal // ignore: cast_nullable_to_non_nullable
as String?,units: null == units ? _self.units : units // ignore: cast_nullable_to_non_nullable
as String,co2MethodologyVersion: null == co2MethodologyVersion ? _self.co2MethodologyVersion : co2MethodologyVersion // ignore: cast_nullable_to_non_nullable
as String,localeTag: freezed == localeTag ? _self.localeTag : localeTag // ignore: cast_nullable_to_non_nullable
as String?,targets: freezed == targets ? _self.targets : targets // ignore: cast_nullable_to_non_nullable
as CalcTargets?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CalcTargetsCopyWith<$Res>? get targets {
    if (_self.targets == null) {
    return null;
  }

  return $CalcTargetsCopyWith<$Res>(_self.targets!, (value) {
    return _then(_self.copyWith(targets: value));
  });
}
}

// dart format on
