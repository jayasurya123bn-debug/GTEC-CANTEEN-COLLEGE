class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String? type;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.type,
    this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      type: json['type'],
      data: json['data'] is Map ? json['data'] : null,
      isRead: json['is_read'] ?? json['isRead'] ?? false,
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt']),
    );
  }
}
