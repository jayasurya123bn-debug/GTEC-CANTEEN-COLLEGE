class OrderModel {
  final String id;
  final String userId;
  final String? userName;
  final List<dynamic> items;
  final double totalAmount;
  final String timeSlot;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    this.userName,
    required this.items,
    required this.totalAmount,
    required this.timeSlot,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      userId: json['user_id'] ?? json['userId'],
      userName: json['user_name'] ?? json['userName'],
      items: json['items'] ?? [],
      totalAmount: double.parse(json['total_amount']?.toString() ?? '0'),
      timeSlot: json['time_slot'] ?? json['timeSlot'] ?? '',
      status: json['status'] ?? 'pending',
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at'] ?? json['createdAt']),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['updatedAt']),
    );
  }
}
