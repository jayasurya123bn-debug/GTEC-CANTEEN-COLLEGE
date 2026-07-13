import 'menu_item_model.dart';

class MenuCategoryModel {
  final String category;
  final List<MenuItemModel> items;

  MenuCategoryModel({
    required this.category,
    required this.items,
  });

  factory MenuCategoryModel.fromJson(Map<String, dynamic> json) {
    var list = json['items'] as List;
    List<MenuItemModel> itemsList = list.map((i) => MenuItemModel.fromJson(i)).toList();
    
    return MenuCategoryModel(
      category: json['category'],
      items: itemsList,
    );
  }
}
