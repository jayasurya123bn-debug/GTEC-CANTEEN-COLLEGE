class ReviewModel {
  final String id;
  final String itemId;
  final String? userName;
  final String? itemName;
  final int rating;
  final String? comment;
  final bool isApproved;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.itemId,
    this.userName,
    this.itemName,
    required this.rating,
    this.comment,
    required this.isApproved,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      itemId: json['item_id'] ?? json['itemId'],
      userName: json['user_name'] ?? json['userName'],
      itemName: json['item_name'] ?? json['itemName'],
      rating: json['rating'],
      comment: json['comment'],
      isApproved: json['is_approved'] ?? json['isApproved'] ?? false,
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt']),
    );
  }
}
