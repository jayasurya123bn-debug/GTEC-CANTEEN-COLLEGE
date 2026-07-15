import 'menu_item_model.dart';

/// Extends MenuItemModel with pre-order specific capacity information.
class PreOrderItemModel extends MenuItemModel {
  final int remainingPreOrderCapacity;
  final String preOrderStatus; // 'available' | 'limited' | 'sold_out'
  final bool isPreOrderable;
  final int bookedQuantity;
  final int preOrderLimit;

  PreOrderItemModel({
    required super.id,
    required super.categoryId,
    required super.name,
    super.description,
    required super.price,
    super.imageUrl,
    super.isVeg = true,
    required super.dietaryTag,
    required super.availability,
    super.limitedQuantity,
    super.avgRating = 0.0,
    super.ratingCount = 0,
    required this.remainingPreOrderCapacity,
    required this.preOrderStatus,
    required this.isPreOrderable,
    required this.bookedQuantity,
    required this.preOrderLimit,
  });

  factory PreOrderItemModel.fromJson(Map<String, dynamic> json) {
    return PreOrderItemModel(
      id:                        json['id'] as String,
      categoryId:                json['category_id'] as String,
      name:                      json['name'] as String,
      description:               json['description'] as String?,
      price:                     double.parse(json['price'].toString()),
      imageUrl:                  json['image_url'] as String?,
      isVeg:                     json['is_veg'] as bool? ?? true,
      dietaryTag:                json['dietary_tag'] as String? ?? 'veg',
      availability:              json['availability'] as String? ?? 'available',
      limitedQuantity:           json['limited_quantity'] as int?,
      avgRating:                 double.parse((json['avg_rating'] ?? 0).toString()),
      ratingCount:               json['rating_count'] as int? ?? 0,
      remainingPreOrderCapacity: json['remaining_pre_order_capacity'] as int? ?? 0,
      preOrderStatus:            json['pre_order_status'] as String? ?? 'available',
      isPreOrderable:            json['is_pre_orderable'] as bool? ?? false,
      bookedQuantity:            json['booked_quantity'] as int? ?? 0,
      preOrderLimit:             json['pre_order_limit'] as int? ?? 50,
    );
  }

  /// Returns a copy with updated capacity fields (used when socket events arrive).
  PreOrderItemModel copyWithCapacity({
    int? remaining,
    String? status,
  }) {
    return PreOrderItemModel(
      id:                        id,
      categoryId:                categoryId,
      name:                      name,
      description:               description,
      price:                     price,
      imageUrl:                  imageUrl,
      isVeg:                     isVeg,
      dietaryTag:                dietaryTag,
      availability:              availability,
      limitedQuantity:           limitedQuantity,
      avgRating:                 avgRating,
      ratingCount:               ratingCount,
      remainingPreOrderCapacity: remaining ?? remainingPreOrderCapacity,
      preOrderStatus:            status   ?? preOrderStatus,
      isPreOrderable:            (remaining ?? remainingPreOrderCapacity) > 0,
      bookedQuantity:            preOrderLimit - (remaining ?? remainingPreOrderCapacity),
      preOrderLimit:             preOrderLimit,
    );
  }

  /// Warning text shown when item is limited.
  String? get limitedWarning {
    if (preOrderStatus == 'limited') {
      return 'Only $remainingPreOrderCapacity left!';
    }
    return null;
  }
}
