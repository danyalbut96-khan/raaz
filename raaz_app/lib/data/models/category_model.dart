/// Data model for a Category (system-seeded, not user-created)
class CategoryModel {
  final String id;
  final String name;
  final String? icon;
  final int sortOrder;

  const CategoryModel({
    required this.id,
    required this.name,
    this.icon,
    this.sortOrder = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': icon,
    'sort_order': sortOrder,
  };
}
