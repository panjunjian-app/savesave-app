// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ledger.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Ledger {

 String get id; String get userId; String get name; String get icon; String get color; int get sortOrder; DateTime get createdAt; DateTime get updatedAt;
/// Create a copy of Ledger
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LedgerCopyWith<Ledger> get copyWith => _$LedgerCopyWithImpl<Ledger>(this as Ledger, _$identity);

  /// Serializes this Ledger to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Ledger;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Ledger&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.icon, _this.icon) || other.icon == _this.icon)&&(identical(other.color, _this.color) || other.color == _this.color)&&(identical(other.sortOrder, _this.sortOrder) || other.sortOrder == _this.sortOrder)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Ledger;
  return Object.hash(runtimeType,_this.id,_this.userId,_this.name,_this.icon,_this.color,_this.sortOrder,_this.createdAt,_this.updatedAt);
}

@override
String toString() {
  final _this = this as Ledger;
  return 'Ledger(id: ${_this.id}, userId: ${_this.userId}, name: ${_this.name}, icon: ${_this.icon}, color: ${_this.color}, sortOrder: ${_this.sortOrder}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt})';
}


}

/// @nodoc
abstract mixin class $LedgerCopyWith<$Res>  {
  factory $LedgerCopyWith(Ledger value, $Res Function(Ledger) _then) = _$LedgerCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String name, String icon, String color, int sortOrder, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class _$LedgerCopyWithImpl<$Res>
    implements $LedgerCopyWith<$Res> {
  _$LedgerCopyWithImpl(this._self, this._then);

  final Ledger _self;
  final $Res Function(Ledger) _then;

/// Create a copy of Ledger
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? icon = null,Object? color = null,Object? sortOrder = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(Ledger(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Ledger].
extension LedgerPatterns on Ledger {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Ledger value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Ledger() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Ledger value)  $default,){
final _that = this;
switch (_that) {
case _Ledger():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Ledger value)?  $default,){
final _that = this;
switch (_that) {
case _Ledger() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  String icon,  String color,  int sortOrder,  DateTime createdAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Ledger() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.icon,_that.color,_that.sortOrder,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  String icon,  String color,  int sortOrder,  DateTime createdAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Ledger():
return $default(_that.id,_that.userId,_that.name,_that.icon,_that.color,_that.sortOrder,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String name,  String icon,  String color,  int sortOrder,  DateTime createdAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Ledger() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.icon,_that.color,_that.sortOrder,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Ledger extends Ledger {
  const _Ledger({required this.id, required this.userId, required this.name, this.icon = '', this.color = '#1F6F5C', this.sortOrder = 0, required this.createdAt, required this.updatedAt}): super._();
  factory _Ledger.fromJson(Map<String, dynamic> json) => _$LedgerFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String name;
@override@JsonKey() final  String icon;
@override@JsonKey() final  String color;
@override@JsonKey() final  int sortOrder;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;

/// Create a copy of Ledger
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LedgerCopyWith<_Ledger> get copyWith => __$LedgerCopyWithImpl<_Ledger>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LedgerToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Ledger&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,userId,name,icon,color,sortOrder,createdAt,updatedAt);
}

@override
String toString() {
    return 'Ledger(id: $id, userId: $userId, name: $name, icon: $icon, color: $color, sortOrder: $sortOrder, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$LedgerCopyWith<$Res> implements $LedgerCopyWith<$Res> {
  factory _$LedgerCopyWith(_Ledger value, $Res Function(_Ledger) _then) = __$LedgerCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String name, String icon, String color, int sortOrder, DateTime createdAt, DateTime updatedAt
});




}
/// @nodoc
class __$LedgerCopyWithImpl<$Res>
    implements _$LedgerCopyWith<$Res> {
  __$LedgerCopyWithImpl(this._self, this._then);

  final _Ledger _self;
  final $Res Function(_Ledger) _then;

/// Create a copy of Ledger
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? icon = null,Object? color = null,Object? sortOrder = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_Ledger(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
