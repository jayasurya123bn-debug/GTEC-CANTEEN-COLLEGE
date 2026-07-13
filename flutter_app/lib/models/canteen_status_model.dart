class CanteenStatusModel {
  final bool isOpen;
  final String busyness;
  final String? broadcastMessage;
  final DateTime updatedAt;

  CanteenStatusModel({
    required this.isOpen,
    required this.busyness,
    this.broadcastMessage,
    required this.updatedAt,
  });

  factory CanteenStatusModel.fromJson(Map<String, dynamic> json) {
    return CanteenStatusModel(
      isOpen: json['is_open'] ?? json['isOpen'] ?? false,
      busyness: json['busyness'] ?? 'low',
      broadcastMessage: json['broadcast_message'] ?? json['broadcastMessage'],
      updatedAt: DateTime.parse(json['updated_at'] ?? json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
