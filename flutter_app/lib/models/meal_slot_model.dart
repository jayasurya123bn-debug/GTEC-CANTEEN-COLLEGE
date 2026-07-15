class MealSlotModel {
  final String id;
  final String slotName;
  final String startTime;
  final String endTime;
  final int currentTokenNumber;
  final int nowServing;
  final bool isActive;
  final String date;

  const MealSlotModel({
    required this.id,
    required this.slotName,
    required this.startTime,
    required this.endTime,
    required this.currentTokenNumber,
    required this.nowServing,
    required this.isActive,
    required this.date,
  });

  factory MealSlotModel.fromJson(Map<String, dynamic> json) {
    return MealSlotModel(
      id:                   json['id'] as String,
      slotName:             json['slot_name'] as String,
      startTime:            json['start_time'] as String,
      endTime:              json['end_time'] as String,
      currentTokenNumber:   json['current_token_number'] as int? ?? 0,
      nowServing:           json['now_serving'] as int? ?? 0,
      isActive:             json['is_active'] as bool? ?? true,
      date:                 json['date'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':                   id,
    'slot_name':            slotName,
    'start_time':           startTime,
    'end_time':             endTime,
    'current_token_number': currentTokenNumber,
    'now_serving':          nowServing,
    'is_active':            isActive,
    'date':                 date,
  };

  /// Human-readable label for the slot, e.g. "Lunch (12:00–14:00)"
  String get displayLabel {
    final name = slotName[0].toUpperCase() + slotName.substring(1);
    final start = startTime.substring(0, 5);
    final end   = endTime.substring(0, 5);
    return '$name ($start–$end)';
  }

  /// Estimated wait in minutes based on remaining tokens from now_serving
  int estimatedWaitForToken(int tokenNumber) {
    return (tokenNumber - nowServing).clamp(0, 9999) * 2;
  }
}
