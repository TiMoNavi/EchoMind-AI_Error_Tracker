import 'package:json_annotation/json_annotation.dart';

part 'model_item.g.dart';

@JsonSerializable()
class ModelItem {
  final int id;
  final String name;
  final int? level;
  @JsonKey(name: 'category_name')
  final String? categoryName;
  final List<ModelItem>? children;

  const ModelItem({
    required this.id,
    required this.name,
    this.level,
    this.categoryName,
    this.children,
  });

  factory ModelItem.fromJson(Map<String, dynamic> json) =>
      _$ModelItemFromJson(json);
  Map<String, dynamic> toJson() => _$ModelItemToJson(this);
}
