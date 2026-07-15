class TokenReceiptItemModel {
  final String menuItemId;
  final String name;
  final int quantity;
  final double price;
  final double subtotal;

  const TokenReceiptItemModel({
    required this.menuItemId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  factory TokenReceiptItemModel.fromJson(Map<String, dynamic> json) {
    return TokenReceiptItemModel(
      menuItemId: json['menu_item_id'] as String? ?? '',
      name:       json['name'] as String,
      quantity:   json['quantity'] as int,
      price:      double.parse((json['price'] ?? 0).toString()),
      subtotal:   double.parse((json['subtotal'] ?? 0).toString()),
    );
  }
}

class TokenReceiptModel {
  final String orderId;
  final int tokenNumber;
  final int tokenStart;
  final int tokenEnd;
  final String studentName;
  final String department;
  final String year;
  final String section;
  final String mealSlotName;
  final String slotStartTime;
  final String slotEndTime;
  final List<TokenReceiptItemModel> items;
  final double totalAmount;
  final int totalItems;
  final String? pickupTime;
  final String? notes;
  final String status;
  final DateTime orderDate;
  final int estimatedWaitMinutes;

  const TokenReceiptModel({
    required this.orderId,
    required this.tokenNumber,
    required this.tokenStart,
    required this.tokenEnd,
    required this.studentName,
    required this.department,
    required this.year,
    required this.section,
    required this.mealSlotName,
    required this.slotStartTime,
    required this.slotEndTime,
    required this.items,
    required this.totalAmount,
    required this.totalItems,
    this.pickupTime,
    this.notes,
    required this.status,
    required this.orderDate,
    required this.estimatedWaitMinutes,
  });

  factory TokenReceiptModel.fromJson(Map<String, dynamic> json) {
    final receipt = json['receipt'] ?? json;
    final rawItems = receipt['items'] as List<dynamic>? ?? [];
    return TokenReceiptModel(
      orderId:               receipt['order_id'] as String,
      tokenNumber:           receipt['token_number'] as int,
      tokenStart:            receipt['token_start'] as int,
      tokenEnd:              receipt['token_end'] as int,
      studentName:           receipt['student_name'] as String,
      department:            receipt['department'] as String? ?? '—',
      year:                  receipt['year'] as String? ?? '—',
      section:               receipt['section'] as String? ?? '—',
      mealSlotName:          receipt['meal_slot_name'] as String,
      slotStartTime:         receipt['slot_start_time'] as String? ?? '',
      slotEndTime:           receipt['slot_end_time'] as String? ?? '',
      items:                 rawItems.map((i) => TokenReceiptItemModel.fromJson(i as Map<String, dynamic>)).toList(),
      totalAmount:           double.parse((receipt['total_amount'] ?? 0).toString()),
      totalItems:            receipt['total_items'] as int? ?? 0,
      pickupTime:            receipt['pickup_time'] as String?,
      notes:                 receipt['notes'] as String?,
      status:                receipt['status'] as String? ?? 'pending',
      orderDate:             DateTime.parse(receipt['order_date'] as String),
      estimatedWaitMinutes:  receipt['estimated_wait_minutes'] as int? ?? 0,
    );
  }

  /// Token range label: "#5–9" or "#5" if single portion.
  String get tokenRangeLabel {
    if (tokenStart == tokenEnd) return '#$tokenEnd';
    return '#$tokenStart–$tokenEnd';
  }

  /// Slot display label, e.g. "Lunch (12:00–14:00)".
  String get slotDisplayLabel {
    final name = mealSlotName[0].toUpperCase() + mealSlotName.substring(1);
    return '$name (${slotStartTime.substring(0, 5)}–${slotEndTime.substring(0, 5)})';
  }

  /// Share text for share button.
  String get shareText {
    final buffer = StringBuffer();
    buffer.writeln('🌿 GTEC Pure Veg Canteen — Pre-Order Token');
    buffer.writeln('Token: #$tokenNumber ($tokenRangeLabel)');
    buffer.writeln('Slot:  $slotDisplayLabel');
    buffer.writeln('Name:  $studentName | $department $year Sec $section');
    if (pickupTime != null) buffer.writeln('Pickup: $pickupTime');
    buffer.writeln('─────────────────');
    for (final item in items) {
      buffer.writeln('${item.quantity}× ${item.name}  ₹${item.subtotal.toStringAsFixed(0)}');
    }
    buffer.writeln('─────────────────');
    buffer.writeln('Total: ₹${totalAmount.toStringAsFixed(0)}');
    buffer.writeln('Est. Wait: ~$estimatedWaitMinutes min');
    return buffer.toString();
  }
}
