// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'calc_targets.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CalcTargets {

/// Daily calorie target in kcal. `null` = missing inputs.
 double? get kcalTarget;/// Daily protein target in grams. `null` = missing inputs.
 double? get proteinGTarget;/// Daily carbohydrates target in grams. `null` = missing inputs.
 double? get carbsGTarget;/// Daily fat target in grams. `null` = missing inputs.
 double? get fatGTarget;/// Daily CO₂ footprint target in grams. Hidden from UI until Phase 3.
 double? get co2GTarget;/// Whether [kcalTarget] was manually overridden by the user.
 bool get kcalIsOverridden;/// Whether [proteinGTarget] was manually overridden by the user.
 bool get proteinIsOverridden;/// Whether [carbsGTarget] was manually overridden by the user.
 bool get carbsIsOverridden;/// Whether [fatIsOverridden] was manually overridden by the user.
 bool get fatIsOverridden;
/// Create a copy of CalcTargets
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CalcTargetsCopyWith<CalcTargets> get copyWith => _$CalcTargetsCopyWithImpl<CalcTargets>(this as CalcTargets, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CalcTargets&&(identical(other.kcalTarget, kcalTarget) || other.kcalTarget == kcalTarget)&&(identical(other.proteinGTarget, proteinGTarget) || other.proteinGTarget == proteinGTarget)&&(identical(other.carbsGTarget, carbsGTarget) || other.carbsGTarget == carbsGTarget)&&(identical(other.fatGTarget, fatGTarget) || other.fatGTarget == fatGTarget)&&(identical(other.co2GTarget, co2GTarget) || other.co2GTarget == co2GTarget)&&(identical(other.kcalIsOverridden, kcalIsOverridden) || other.kcalIsOverridden == kcalIsOverridden)&&(identical(other.proteinIsOverridden, proteinIsOverridden) || other.proteinIsOverridden == proteinIsOverridden)&&(identical(other.carbsIsOverridden, carbsIsOverridden) || other.carbsIsOverridden == carbsIsOverridden)&&(identical(other.fatIsOverridden, fatIsOverridden) || other.fatIsOverridden == fatIsOverridden));
}


@override
int get hashCode => Object.hash(runtimeType,kcalTarget,proteinGTarget,carbsGTarget,fatGTarget,co2GTarget,kcalIsOverridden,proteinIsOverridden,carbsIsOverridden,fatIsOverridden);

@override
String toString() {
  return 'CalcTargets(kcalTarget: $kcalTarget, proteinGTarget: $proteinGTarget, carbsGTarget: $carbsGTarget, fatGTarget: $fatGTarget, co2GTarget: $co2GTarget, kcalIsOverridden: $kcalIsOverridden, proteinIsOverridden: $proteinIsOverridden, carbsIsOverridden: $carbsIsOverridden, fatIsOverridden: $fatIsOverridden)';
}


}

/// @nodoc
abstract mixin class $CalcTargetsCopyWith<$Res>  {
  factory $CalcTargetsCopyWith(CalcTargets value, $Res Function(CalcTargets) _then) = _$CalcTargetsCopyWithImpl;
@useResult
$Res call({
 double? kcalTarget, double? proteinGTarget, double? carbsGTarget, double? fatGTarget, double? co2GTarget, bool kcalIsOverridden, bool proteinIsOverridden, bool carbsIsOverridden, bool fatIsOverridden
});




}
/// @nodoc
class _$CalcTargetsCopyWithImpl<$Res>
    implements $CalcTargetsCopyWith<$Res> {
  _$CalcTargetsCopyWithImpl(this._self, this._then);

  final CalcTargets _self;
  final $Res Function(CalcTargets) _then;

/// Create a copy of CalcTargets
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? kcalTarget = freezed,Object? proteinGTarget = freezed,Object? carbsGTarget = freezed,Object? fatGTarget = freezed,Object? co2GTarget = freezed,Object? kcalIsOverridden = null,Object? proteinIsOverridden = null,Object? carbsIsOverridden = null,Object? fatIsOverridden = null,}) {
  return _then(_self.copyWith(
kcalTarget: freezed == kcalTarget ? _self.kcalTarget : kcalTarget // ignore: cast_nullable_to_non_nullable
as double?,proteinGTarget: freezed == proteinGTarget ? _self.proteinGTarget : proteinGTarget // ignore: cast_nullable_to_non_nullable
as double?,carbsGTarget: freezed == carbsGTarget ? _self.carbsGTarget : carbsGTarget // ignore: cast_nullable_to_non_nullable
as double?,fatGTarget: freezed == fatGTarget ? _self.fatGTarget : fatGTarget // ignore: cast_nullable_to_non_nullable
as double?,co2GTarget: freezed == co2GTarget ? _self.co2GTarget : co2GTarget // ignore: cast_nullable_to_non_nullable
as double?,kcalIsOverridden: null == kcalIsOverridden ? _self.kcalIsOverridden : kcalIsOverridden // ignore: cast_nullable_to_non_nullable
as bool,proteinIsOverridden: null == proteinIsOverridden ? _self.proteinIsOverridden : proteinIsOverridden // ignore: cast_nullable_to_non_nullable
as bool,carbsIsOverridden: null == carbsIsOverridden ? _self.carbsIsOverridden : carbsIsOverridden // ignore: cast_nullable_to_non_nullable
as bool,fatIsOverridden: null == fatIsOverridden ? _self.fatIsOverridden : fatIsOverridden // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CalcTargets].
extension CalcTargetsPatterns on CalcTargets {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CalcTargets value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CalcTargets() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CalcTargets value)  $default,){
final _that = this;
switch (_that) {
case _CalcTargets():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CalcTargets value)?  $default,){
final _that = this;
switch (_that) {
case _CalcTargets() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double? kcalTarget,  double? proteinGTarget,  double? carbsGTarget,  double? fatGTarget,  double? co2GTarget,  bool kcalIsOverridden,  bool proteinIsOverridden,  bool carbsIsOverridden,  bool fatIsOverridden)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CalcTargets() when $default != null:
return $default(_that.kcalTarget,_that.proteinGTarget,_that.carbsGTarget,_that.fatGTarget,_that.co2GTarget,_that.kcalIsOverridden,_that.proteinIsOverridden,_that.carbsIsOverridden,_that.fatIsOverridden);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double? kcalTarget,  double? proteinGTarget,  double? carbsGTarget,  double? fatGTarget,  double? co2GTarget,  bool kcalIsOverridden,  bool proteinIsOverridden,  bool carbsIsOverridden,  bool fatIsOverridden)  $default,) {final _that = this;
switch (_that) {
case _CalcTargets():
return $default(_that.kcalTarget,_that.proteinGTarget,_that.carbsGTarget,_that.fatGTarget,_that.co2GTarget,_that.kcalIsOverridden,_that.proteinIsOverridden,_that.carbsIsOverridden,_that.fatIsOverridden);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double? kcalTarget,  double? proteinGTarget,  double? carbsGTarget,  double? fatGTarget,  double? co2GTarget,  bool kcalIsOverridden,  bool proteinIsOverridden,  bool carbsIsOverridden,  bool fatIsOverridden)?  $default,) {final _that = this;
switch (_that) {
case _CalcTargets() when $default != null:
return $default(_that.kcalTarget,_that.proteinGTarget,_that.carbsGTarget,_that.fatGTarget,_that.co2GTarget,_that.kcalIsOverridden,_that.proteinIsOverridden,_that.carbsIsOverridden,_that.fatIsOverridden);case _:
  return null;

}
}

}

/// @nodoc


class _CalcTargets implements CalcTargets {
  const _CalcTargets({this.kcalTarget, this.proteinGTarget, this.carbsGTarget, this.fatGTarget, this.co2GTarget, this.kcalIsOverridden = false, this.proteinIsOverridden = false, this.carbsIsOverridden = false, this.fatIsOverridden = false});
  

/// Daily calorie target in kcal. `null` = missing inputs.
@override final  double? kcalTarget;
/// Daily protein target in grams. `null` = missing inputs.
@override final  double? proteinGTarget;
/// Daily carbohydrates target in grams. `null` = missing inputs.
@override final  double? carbsGTarget;
/// Daily fat target in grams. `null` = missing inputs.
@override final  double? fatGTarget;
/// Daily CO₂ footprint target in grams. Hidden from UI until Phase 3.
@override final  double? co2GTarget;
/// Whether [kcalTarget] was manually overridden by the user.
@override@JsonKey() final  bool kcalIsOverridden;
/// Whether [proteinGTarget] was manually overridden by the user.
@override@JsonKey() final  bool proteinIsOverridden;
/// Whether [carbsGTarget] was manually overridden by the user.
@override@JsonKey() final  bool carbsIsOverridden;
/// Whether [fatIsOverridden] was manually overridden by the user.
@override@JsonKey() final  bool fatIsOverridden;

/// Create a copy of CalcTargets
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CalcTargetsCopyWith<_CalcTargets> get copyWith => __$CalcTargetsCopyWithImpl<_CalcTargets>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CalcTargets&&(identical(other.kcalTarget, kcalTarget) || other.kcalTarget == kcalTarget)&&(identical(other.proteinGTarget, proteinGTarget) || other.proteinGTarget == proteinGTarget)&&(identical(other.carbsGTarget, carbsGTarget) || other.carbsGTarget == carbsGTarget)&&(identical(other.fatGTarget, fatGTarget) || other.fatGTarget == fatGTarget)&&(identical(other.co2GTarget, co2GTarget) || other.co2GTarget == co2GTarget)&&(identical(other.kcalIsOverridden, kcalIsOverridden) || other.kcalIsOverridden == kcalIsOverridden)&&(identical(other.proteinIsOverridden, proteinIsOverridden) || other.proteinIsOverridden == proteinIsOverridden)&&(identical(other.carbsIsOverridden, carbsIsOverridden) || other.carbsIsOverridden == carbsIsOverridden)&&(identical(other.fatIsOverridden, fatIsOverridden) || other.fatIsOverridden == fatIsOverridden));
}


@override
int get hashCode => Object.hash(runtimeType,kcalTarget,proteinGTarget,carbsGTarget,fatGTarget,co2GTarget,kcalIsOverridden,proteinIsOverridden,carbsIsOverridden,fatIsOverridden);

@override
String toString() {
  return 'CalcTargets(kcalTarget: $kcalTarget, proteinGTarget: $proteinGTarget, carbsGTarget: $carbsGTarget, fatGTarget: $fatGTarget, co2GTarget: $co2GTarget, kcalIsOverridden: $kcalIsOverridden, proteinIsOverridden: $proteinIsOverridden, carbsIsOverridden: $carbsIsOverridden, fatIsOverridden: $fatIsOverridden)';
}


}

/// @nodoc
abstract mixin class _$CalcTargetsCopyWith<$Res> implements $CalcTargetsCopyWith<$Res> {
  factory _$CalcTargetsCopyWith(_CalcTargets value, $Res Function(_CalcTargets) _then) = __$CalcTargetsCopyWithImpl;
@override @useResult
$Res call({
 double? kcalTarget, double? proteinGTarget, double? carbsGTarget, double? fatGTarget, double? co2GTarget, bool kcalIsOverridden, bool proteinIsOverridden, bool carbsIsOverridden, bool fatIsOverridden
});




}
/// @nodoc
class __$CalcTargetsCopyWithImpl<$Res>
    implements _$CalcTargetsCopyWith<$Res> {
  __$CalcTargetsCopyWithImpl(this._self, this._then);

  final _CalcTargets _self;
  final $Res Function(_CalcTargets) _then;

/// Create a copy of CalcTargets
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? kcalTarget = freezed,Object? proteinGTarget = freezed,Object? carbsGTarget = freezed,Object? fatGTarget = freezed,Object? co2GTarget = freezed,Object? kcalIsOverridden = null,Object? proteinIsOverridden = null,Object? carbsIsOverridden = null,Object? fatIsOverridden = null,}) {
  return _then(_CalcTargets(
kcalTarget: freezed == kcalTarget ? _self.kcalTarget : kcalTarget // ignore: cast_nullable_to_non_nullable
as double?,proteinGTarget: freezed == proteinGTarget ? _self.proteinGTarget : proteinGTarget // ignore: cast_nullable_to_non_nullable
as double?,carbsGTarget: freezed == carbsGTarget ? _self.carbsGTarget : carbsGTarget // ignore: cast_nullable_to_non_nullable
as double?,fatGTarget: freezed == fatGTarget ? _self.fatGTarget : fatGTarget // ignore: cast_nullable_to_non_nullable
as double?,co2GTarget: freezed == co2GTarget ? _self.co2GTarget : co2GTarget // ignore: cast_nullable_to_non_nullable
as double?,kcalIsOverridden: null == kcalIsOverridden ? _self.kcalIsOverridden : kcalIsOverridden // ignore: cast_nullable_to_non_nullable
as bool,proteinIsOverridden: null == proteinIsOverridden ? _self.proteinIsOverridden : proteinIsOverridden // ignore: cast_nullable_to_non_nullable
as bool,carbsIsOverridden: null == carbsIsOverridden ? _self.carbsIsOverridden : carbsIsOverridden // ignore: cast_nullable_to_non_nullable
as bool,fatIsOverridden: null == fatIsOverridden ? _self.fatIsOverridden : fatIsOverridden // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
