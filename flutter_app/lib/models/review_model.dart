class ReviewModel {
  final String id;
  final String userName;
  final double rating;
  final String? comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.userName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id:        json['id']?.toString() ?? '',
      userName:  json['user_name'] ?? 'Student',
      rating:    double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      comment:   json['comment'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
