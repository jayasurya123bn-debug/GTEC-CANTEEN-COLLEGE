class MenuItemModel {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final bool isVeg;
  final String dietaryTag;    // 'veg' | 'vegan'
  final String availability;  // 'available' | 'limited' | 'sold_out'
  final double avgRating;
  final int ratingCount;
  final String categoryId;
  final String categoryName;

  MenuItemModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    this.isVeg = true,
    required this.dietaryTag,
    required this.availability,
    this.avgRating = 0.0,
    this.ratingCount = 0,
    required this.categoryId,
    required this.categoryName,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json, {String categoryName = ''}) {
    return MenuItemModel(
      id:           json['id']?.toString() ?? '',
      name:         json['name'] ?? '',
      description:  json['description'],
      price:        double.tryParse(json['price'].toString()) ?? 0.0,
      imageUrl:     json['image_url'],
      isVeg:        json['is_veg'] ?? true,
      dietaryTag:   json['dietary_tag'] ?? 'veg',
      availability: json['availability'] ?? 'available',
      avgRating:    double.tryParse(json['avg_rating']?.toString() ?? '0') ?? 0.0,
      ratingCount:  int.tryParse(json['rating_count']?.toString() ?? '0') ?? 0,
      categoryId:   json['category_id']?.toString() ?? '',
      categoryName: json['category_name'] ?? categoryName,
    );
  }

  MenuItemModel copyWith({String? availability}) {
    return MenuItemModel(
      id:           id,
      name:         name,
      description:  description,
      price:        price,
      imageUrl:     imageUrl,
      isVeg:        isVeg,
      dietaryTag:   dietaryTag,
      availability: availability ?? this.availability,
      avgRating:    avgRating,
      ratingCount:  ratingCount,
      categoryId:   categoryId,
      categoryName: categoryName,
    );
  }
}
