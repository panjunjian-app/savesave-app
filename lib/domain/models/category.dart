import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';
part 'category.g.dart';

/// Income/expense category. `isCustom` distinguishes built-ins from user entries.
@freezed
abstract class Category with _$Category {
  const Category._();

  const factory Category({
    required String id,
    required String userId,
    required String name,
    required String type,
    @Default('') String icon,
    @Default('#C6A15B') String color,
    @Default(false) bool isCustom,
    @Default(0) int sortOrder,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
}
