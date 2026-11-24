// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'savings_goal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SavingsGoal {

 String get id; String get userId; String get name; int get targetAmountCents; String? get deadline; String get icon; String get themeColor; String? get note; String get status; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of SavingsGoal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavingsGoalCopyWith<SavingsGoal> get copyWith => _$SavingsGoalCopyWithImpl<SavingsGoal>(this as SavingsGoal, _$identity);

  /// Serializes this SavingsGoal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as SavingsGoal;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavingsGoal&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.targetAmountCents, _this.targetAmountCents) || other.targetAmountCents == _this.targetAmountCents)&&(identical(other.deadline, _this.deadline) || other.deadline == _this.deadline)&&(identical(other.icon, _this.icon) || other.icon == _this.icon)&&(identical(other.themeColor, _this.themeColor) || other.themeColor == _this.themeColor)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as SavingsGoal;
  return Object.hash(runtimeType,_this.id,_this.userId,_this.name,_this.targetAmountCents,_this.deadline,_this.icon,_this.themeColor,_this.note,_this.status,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as SavingsGoal;
  return 'SavingsGoal(id: ${_this.id}, userId: ${_this.userId}, name: ${_this.name}, targetAmountCents: ${_this.targetAmountCents}, deadline: ${_this.deadline}, icon: ${_this.icon}, themeColor: ${_this.themeColor}, note: ${_this.note}, status: ${_this.status}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $SavingsGoalCopyWith<$Res>  {
  factory $SavingsGoalCopyWith(SavingsGoal value, $Res Function(SavingsGoal) _then) = _$SavingsGoalCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String name, int targetAmountCents, String? deadline, String icon, String themeColor, String? note, String status, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$SavingsGoalCopyWithImpl<$Res>
    implements $SavingsGoalCopyWith<$Res> {
  _$SavingsGoalCopyWithImpl(this._self, this._then);

  final SavingsGoal _self;
  final $Res Function(SavingsGoal) _then;

/// Create a copy of SavingsGoal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? targetAmountCents = null,Object? deadline = freezed,Object? icon = null,Object? themeColor = null,Object? note = freezed,Object? status = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(SavingsGoal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,targetAmountCents: null == targetAmountCents ? _self.targetAmountCents : targetAmountCents // ignore: cast_nullable_to_non_nullable
as int,deadline: freezed == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as String?,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,themeColor: null == themeColor ? _self.themeColor : themeColor // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SavingsGoal].
extension SavingsGoalPatterns on SavingsGoal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavingsGoal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavingsGoal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavingsGoal value)  $default,){
final _that = this;
switch (_that) {
case _SavingsGoal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavingsGoal value)?  $default,){
final _that = this;
switch (_that) {
case _SavingsGoal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  int targetAmountCents,  String? deadline,  String icon,  String themeColor,  String? note,  String status,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavingsGoal() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.targetAmountCents,_that.deadline,_that.icon,_that.themeColor,_that.note,_that.status,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  int targetAmountCents,  String? deadline,  String icon,  String themeColor,  String? note,  String status,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SavingsGoal():
return $default(_that.id,_that.userId,_that.name,_that.targetAmountCents,_that.deadline,_that.icon,_that.themeColor,_that.note,_that.status,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String name,  int targetAmountCents,  String? deadline,  String icon,  String themeColor,  String? note,  String status,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SavingsGoal() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.targetAmountCents,_that.deadline,_that.icon,_that.themeColor,_that.note,_that.status,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SavingsGoal extends SavingsGoal {
  const _SavingsGoal({required this.id, required this.userId, required this.name, required this.targetAmountCents, this.deadline, this.icon = '', this.themeColor = '#1F6F5C', this.note, this.status = 'active', required this.createdAt, required this.updatedAt}): super._();
  factory _SavingsGoal.fromJson(Map<String, dynamic> json) => _$SavingsGoalFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String name;
@override final  int targetAmountCents;
@override final  String? deadline;
@override@JsonKey() final  String icon;
@override@JsonKey() final  String themeColor;
@override final  String? note;
@override@JsonKey() final  String status;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of SavingsGoal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavingsGoalCopyWith<_SavingsGoal> get copyWith => __$SavingsGoalCopyWithImpl<_SavingsGoal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SavingsGoalToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavingsGoal&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.targetAmountCents, targetAmountCents) || other.targetAmountCents == targetAmountCents)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.themeColor, themeColor) || other.themeColor == themeColor)&&(identical(other.note, note) || other.note == note)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,userId,name,targetAmountCents,deadline,icon,themeColor,note,status,createdAt,updatedAt);
}

@override
String toString() {
    return 'SavingsGoal(id: $id, userId: $userId, name: $name, targetAmountCents: $targetAmountCents, deadline: $deadline, icon: $icon, themeColor: $themeColor, note: $note, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SavingsGoalCopyWith<$Res> implements $SavingsGoalCopyWith<$Res> {
  factory _$SavingsGoalCopyWith(_SavingsGoal value, $Res Function(_SavingsGoal) _then) = __$SavingsGoalCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String name, int targetAmountCents, String? deadline, String icon, String themeColor, String? note, String status, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$SavingsGoalCopyWithImpl<$Res>
    implements _$SavingsGoalCopyWith<$Res> {
  __$SavingsGoalCopyWithImpl(this._self, this._then);

  final _SavingsGoal _self;
  final $Res Function(_SavingsGoal) _then;

/// Create a copy of SavingsGoal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? targetAmountCents = null,Object? deadline = freezed,Object? icon = null,Object? themeColor = null,Object? note = freezed,Object? status = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_SavingsGoal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,targetAmountCents: null == targetAmountCents ? _self.targetAmountCents : targetAmountCents // ignore: cast_nullable_to_non_nullable
as int,deadline: freezed == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as String?,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,themeColor: null == themeColor ? _self.themeColor : themeColor // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
