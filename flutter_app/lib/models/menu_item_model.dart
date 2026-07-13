class MenuItemModel {
  final String id;
  final String categoryId;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final bool isVeg; // Always true in this system
  final String dietaryTag; // 'veg' or 'vegan'
  final String availability; // 'available', 'limited', 'sold_out'
  final int? limitedQuantity;
  final double avgRating;
  final int ratingCount;

  MenuItemModel({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    this.isVeg = true,
    required this.dietaryTag,
    required this.availability,
    this.limitedQuantity,
    this.avgRating = 0.0,
    this.ratingCount = 0,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'],
      categoryId: json['category_id'],
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      imageUrl: json['image_url'],
      isVeg: json['is_veg'] ?? true, // Strict enforcement
      dietaryTag: json['dietary_tag'],
      availability: json['availability'],
      limitedQuantity: json['limited_quantity'],
      avgRating: double.parse(json['avg_rating'].toString()),
      ratingCount: json['rating_count'],
    );
  }
}
