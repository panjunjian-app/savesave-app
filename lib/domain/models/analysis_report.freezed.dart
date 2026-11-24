// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analysis_report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AnalysisReport {

 String get id; String get scopePeriodType; String get scopePeriodLabel; String get scopeLedgerKey; String get scopeAnchorDate; String get reportJson; String get dataVersion; String get createdAt; String get expiresAt; bool get isStale; String? get goalKey; String get modelId; String get consentVersion;
/// Create a copy of AnalysisReport
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AnalysisReportCopyWith<AnalysisReport> get copyWith => _$AnalysisReportCopyWithImpl<AnalysisReport>(this as AnalysisReport, _$identity);

  /// Serializes this AnalysisReport to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as AnalysisReport;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AnalysisReport&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.scopePeriodType, _this.scopePeriodType) || other.scopePeriodType == _this.scopePeriodType)&&(identical(other.scopePeriodLabel, _this.scopePeriodLabel) || other.scopePeriodLabel == _this.scopePeriodLabel)&&(identical(other.scopeLedgerKey, _this.scopeLedgerKey) || other.scopeLedgerKey == _this.scopeLedgerKey)&&(identical(other.scopeAnchorDate, _this.scopeAnchorDate) || other.scopeAnchorDate == _this.scopeAnchorDate)&&(identical(other.reportJson, _this.reportJson) || other.reportJson == _this.reportJson)&&(identical(other.dataVersion, _this.dataVersion) || other.dataVersion == _this.dataVersion)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&(identical(other.isStale, _this.isStale) || other.isStale == _this.isStale)&&(identical(other.goalKey, _this.goalKey) || other.goalKey == _this.goalKey)&&(identical(other.modelId, _this.modelId) || other.modelId == _this.modelId)&&(identical(other.consentVersion, _this.consentVersion) || other.consentVersion == _this.consentVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as AnalysisReport;
  return Object.hash(runtimeType,_this.id,_this.scopePeriodType,_this.scopePeriodLabel,_this.scopeLedgerKey,_this.scopeAnchorDate,_this.reportJson,_this.dataVersion,_this.createdAt,_this.expiresAt,_this.isStale,_this.goalKey,_this.modelId,_this.consentVersion);
}

@override
String toString() {
  final _this = this as AnalysisReport;
  return 'AnalysisReport(id: ${_this.id}, scopePeriodType: ${_this.scopePeriodType}, scopePeriodLabel: ${_this.scopePeriodLabel}, scopeLedgerKey: ${_this.scopeLedgerKey}, scopeAnchorDate: ${_this.scopeAnchorDate}, reportJson: ${_this.reportJson}, dataVersion: ${_this.dataVersion}, createdAt: ${_this.createdAt}, expiresAt: ${_this.expiresAt}, isStale: ${_this.isStale}, goalKey: ${_this.goalKey}, modelId: ${_this.modelId}, consentVersion: ${_this.consentVersion})';
}


}

/// @nodoc
abstract mixin class $AnalysisReportCopyWith<$Res>  {
  factory $AnalysisReportCopyWith(AnalysisReport value, $Res Function(AnalysisReport) _then) = _$AnalysisReportCopyWithImpl;
@useResult
$Res call({
 String id, String scopePeriodType, String scopePeriodLabel, String scopeLedgerKey, String scopeAnchorDate, String reportJson, String dataVersion, String createdAt, String expiresAt, bool isStale, String? goalKey, String modelId, String consentVersion
});




}
/// @nodoc
class _$AnalysisReportCopyWithImpl<$Res>
    implements $AnalysisReportCopyWith<$Res> {
  _$AnalysisReportCopyWithImpl(this._self, this._then);

  final AnalysisReport _self;
  final $Res Function(AnalysisReport) _then;

/// Create a copy of AnalysisReport
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? scopePeriodType = null,Object? scopePeriodLabel = null,Object? scopeLedgerKey = null,Object? scopeAnchorDate = null,Object? reportJson = null,Object? dataVersion = null,Object? createdAt = null,Object? expiresAt = null,Object? isStale = null,Object? goalKey = freezed,Object? modelId = null,Object? consentVersion = null,}) {
  return _then(AnalysisReport(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,scopePeriodType: null == scopePeriodType ? _self.scopePeriodType : scopePeriodType // ignore: cast_nullable_to_non_nullable
as String,scopePeriodLabel: null == scopePeriodLabel ? _self.scopePeriodLabel : scopePeriodLabel // ignore: cast_nullable_to_non_nullable
as String,scopeLedgerKey: null == scopeLedgerKey ? _self.scopeLedgerKey : scopeLedgerKey // ignore: cast_nullable_to_non_nullable
as String,scopeAnchorDate: null == scopeAnchorDate ? _self.scopeAnchorDate : scopeAnchorDate // ignore: cast_nullable_to_non_nullable
as String,reportJson: null == reportJson ? _self.reportJson : reportJson // ignore: cast_nullable_to_non_nullable
as String,dataVersion: null == dataVersion ? _self.dataVersion : dataVersion // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String,isStale: null == isStale ? _self.isStale : isStale // ignore: cast_nullable_to_non_nullable
as bool,goalKey: freezed == goalKey ? _self.goalKey : goalKey // ignore: cast_nullable_to_non_nullable
as String?,modelId: null == modelId ? _self.modelId : modelId // ignore: cast_nullable_to_non_nullable
as String,consentVersion: null == consentVersion ? _self.consentVersion : consentVersion // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AnalysisReport].
extension AnalysisReportPatterns on AnalysisReport {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AnalysisReport value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AnalysisReport() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AnalysisReport value)  $default,){
final _that = this;
switch (_that) {
case _AnalysisReport():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AnalysisReport value)?  $default,){
final _that = this;
switch (_that) {
case _AnalysisReport() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String scopePeriodType,  String scopePeriodLabel,  String scopeLedgerKey,  String scopeAnchorDate,  String reportJson,  String dataVersion,  String createdAt,  String expiresAt,  bool isStale,  String? goalKey,  String modelId,  String consentVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AnalysisReport() when $default != null:
return $default(_that.id,_that.scopePeriodType,_that.scopePeriodLabel,_that.scopeLedgerKey,_that.scopeAnchorDate,_that.reportJson,_that.dataVersion,_that.createdAt,_that.expiresAt,_that.isStale,_that.goalKey,_that.modelId,_that.consentVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String scopePeriodType,  String scopePeriodLabel,  String scopeLedgerKey,  String scopeAnchorDate,  String reportJson,  String dataVersion,  String createdAt,  String expiresAt,  bool isStale,  String? goalKey,  String modelId,  String consentVersion)  $default,) {final _that = this;
switch (_that) {
case _AnalysisReport():
return $default(_that.id,_that.scopePeriodType,_that.scopePeriodLabel,_that.scopeLedgerKey,_that.scopeAnchorDate,_that.reportJson,_that.dataVersion,_that.createdAt,_that.expiresAt,_that.isStale,_that.goalKey,_that.modelId,_that.consentVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String scopePeriodType,  String scopePeriodLabel,  String scopeLedgerKey,  String scopeAnchorDate,  String reportJson,  String dataVersion,  String createdAt,  String expiresAt,  bool isStale,  String? goalKey,  String modelId,  String consentVersion)?  $default,) {final _that = this;
switch (_that) {
case _AnalysisReport() when $default != null:
return $default(_that.id,_that.scopePeriodType,_that.scopePeriodLabel,_that.scopeLedgerKey,_that.scopeAnchorDate,_that.reportJson,_that.dataVersion,_that.createdAt,_that.expiresAt,_that.isStale,_that.goalKey,_that.modelId,_that.consentVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AnalysisReport extends AnalysisReport {
  const _AnalysisReport({required this.id, required this.scopePeriodType, required this.scopePeriodLabel, required this.scopeLedgerKey, required this.scopeAnchorDate, required this.reportJson, required this.dataVersion, required this.createdAt, required this.expiresAt, this.isStale = false, this.goalKey, required this.modelId, required this.consentVersion}): super._();
  factory _AnalysisReport.fromJson(Map<String, dynamic> json) => _$AnalysisReportFromJson(json);

@override final  String id;
@override final  String scopePeriodType;
@override final  String scopePeriodLabel;
@override final  String scopeLedgerKey;
@override final  String scopeAnchorDate;
@override final  String reportJson;
@override final  String dataVersion;
@override final  String createdAt;
@override final  String expiresAt;
@override@JsonKey() final  bool isStale;
@override final  String? goalKey;
@override final  String modelId;
@override final  String consentVersion;

/// Create a copy of AnalysisReport
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AnalysisReportCopyWith<_AnalysisReport> get copyWith => __$AnalysisReportCopyWithImpl<_AnalysisReport>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AnalysisReportToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AnalysisReport&&(identical(other.id, id) || other.id == id)&&(identical(other.scopePeriodType, scopePeriodType) || other.scopePeriodType == scopePeriodType)&&(identical(other.scopePeriodLabel, scopePeriodLabel) || other.scopePeriodLabel == scopePeriodLabel)&&(identical(other.scopeLedgerKey, scopeLedgerKey) || other.scopeLedgerKey == scopeLedgerKey)&&(identical(other.scopeAnchorDate, scopeAnchorDate) || other.scopeAnchorDate == scopeAnchorDate)&&(identical(other.reportJson, reportJson) || other.reportJson == reportJson)&&(identical(other.dataVersion, dataVersion) || other.dataVersion == dataVersion)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.isStale, isStale) || other.isStale == isStale)&&(identical(other.goalKey, goalKey) || other.goalKey == goalKey)&&(identical(other.modelId, modelId) || other.modelId == modelId)&&(identical(other.consentVersion, consentVersion) || other.consentVersion == consentVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,scopePeriodType,scopePeriodLabel,scopeLedgerKey,scopeAnchorDate,reportJson,dataVersion,createdAt,expiresAt,isStale,goalKey,modelId,consentVersion);
}

@override
String toString() {
    return 'AnalysisReport(id: $id, scopePeriodType: $scopePeriodType, scopePeriodLabel: $scopePeriodLabel, scopeLedgerKey: $scopeLedgerKey, scopeAnchorDate: $scopeAnchorDate, reportJson: $reportJson, dataVersion: $dataVersion, createdAt: $createdAt, expiresAt: $expiresAt, isStale: $isStale, goalKey: $goalKey, modelId: $modelId, consentVersion: $consentVersion)';
}


}

/// @nodoc
abstract mixin class _$AnalysisReportCopyWith<$Res> implements $AnalysisReportCopyWith<$Res> {
  factory _$AnalysisReportCopyWith(_AnalysisReport value, $Res Function(_AnalysisReport) _then) = __$AnalysisReportCopyWithImpl;
@override @useResult
$Res call({
 String id, String scopePeriodType, String scopePeriodLabel, String scopeLedgerKey, String scopeAnchorDate, String reportJson, String dataVersion, String createdAt, String expiresAt, bool isStale, String? goalKey, String modelId, String consentVersion
});




}
/// @nodoc
class __$AnalysisReportCopyWithImpl<$Res>
    implements _$AnalysisReportCopyWith<$Res> {
  __$AnalysisReportCopyWithImpl(this._self, this._then);

  final _AnalysisReport _self;
  final $Res Function(_AnalysisReport) _then;

/// Create a copy of AnalysisReport
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? scopePeriodType = null,Object? scopePeriodLabel = null,Object? scopeLedgerKey = null,Object? scopeAnchorDate = null,Object? reportJson = null,Object? dataVersion = null,Object? createdAt = null,Object? expiresAt = null,Object? isStale = null,Object? goalKey = freezed,Object? modelId = null,Object? consentVersion = null,}) {
  return _then(_AnalysisReport(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,scopePeriodType: null == scopePeriodType ? _self.scopePeriodType : scopePeriodType // ignore: cast_nullable_to_non_nullable
as String,scopePeriodLabel: null == scopePeriodLabel ? _self.scopePeriodLabel : scopePeriodLabel // ignore: cast_nullable_to_non_nullable
as String,scopeLedgerKey: null == scopeLedgerKey ? _self.scopeLedgerKey : scopeLedgerKey // ignore: cast_nullable_to_non_nullable
as String,scopeAnchorDate: null == scopeAnchorDate ? _self.scopeAnchorDate : scopeAnchorDate // ignore: cast_nullable_to_non_nullable
as String,reportJson: null == reportJson ? _self.reportJson : reportJson // ignore: cast_nullable_to_non_nullable
as String,dataVersion: null == dataVersion ? _self.dataVersion : dataVersion // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String,isStale: null == isStale ? _self.isStale : isStale // ignore: cast_nullable_to_non_nullable
as bool,goalKey: freezed == goalKey ? _self.goalKey : goalKey // ignore: cast_nullable_to_non_nullable
as String?,modelId: null == modelId ? _self.modelId : modelId // ignore: cast_nullable_to_non_nullable
as String,consentVersion: null == consentVersion ? _self.consentVersion : consentVersion // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
