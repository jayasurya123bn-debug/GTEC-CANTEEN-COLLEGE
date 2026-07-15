import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/pre_order_item_model.dart';
import '../models/meal_slot_model.dart';
import '../models/token_receipt_model.dart';

class PreOrderService {
  static final Dio _dio = ApiService.client;

  // ─── GET /pre-order/available?meal_slot=lunch ─────────────────────────────
  static Future<Map<String, dynamic>> getAvailableItems({String? mealSlot}) async {
    final params = mealSlot != null ? {'meal_slot': mealSlot} : null;
    final res = await _dio.get('/pre-order/available', queryParameters: params);
    final data = res.data as Map<String, dynamic>;

    final rawItems = (data['items'] as List<dynamic>? ?? []);
    final items = rawItems
        .map((j) => PreOrderItemModel.fromJson(j as Map<String, dynamic>))
        .toList();

    MealSlotModel? slot;
    if (data['slot'] != null) {
      slot = MealSlotModel.fromJson(data['slot'] as Map<String, dynamic>);
    }

    return {'slot': slot, 'items': items};
  }

  // ─── GET /pre-order/slot-status ─────────────────────────────────────────
  static Future<Map<String, dynamic>> getSlotStatus() async {
    final res = await _dio.get('/pre-order/slot-status');
    final data = res.data as Map<String, dynamic>;
    MealSlotModel? slot;
    if (data['slot'] != null) {
      slot = MealSlotModel.fromJson(data['slot'] as Map<String, dynamic>);
    }
    return {
      'active':                   data['active'] as bool? ?? false,
      'slot':                     slot,
      'estimated_wait_minutes':   data['estimated_wait_minutes'] as int? ?? 0,
    };
  }

  // ─── POST /pre-order ──────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> createPreOrder({
    required String mealSlot,
    required List<Map<String, dynamic>> items,
    String? notes,
    String? pickupTime,
  }) async {
    final res = await _dio.post('/pre-order', data: {
      'meal_slot':   mealSlot,
      'items':       items,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      if (pickupTime != null && pickupTime.isNotEmpty) 'pickup_time': pickupTime,
    });
    return res.data as Map<String, dynamic>;
  }

  // ─── GET /pre-order/my-tokens ────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getMyTokens() async {
    final res = await _dio.get('/pre-order/my-tokens');
    final data = res.data as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(data['tokens'] as List);
  }

  // ─── GET /pre-order/:id/token-receipt ────────────────────────────────────
  static Future<TokenReceiptModel> getTokenReceipt(String orderId) async {
    final res = await _dio.get('/pre-order/$orderId/token-receipt');
    return TokenReceiptModel.fromJson(res.data as Map<String, dynamic>);
  }

  // ─── PATCH /pre-order/cancel/:orderId ────────────────────────────────────
  static Future<void> cancelPreOrder(String orderId) async {
    await _dio.patch('/pre-order/cancel/$orderId');
  }

  // ─── PUT profile fields (department/year/section) ─────────────────────────
  static Future<void> updateStudentProfile({
    String? department,
    String? year,
    String? section,
  }) async {
    await _dio.put('/auth/profile', data: {
      if (department != null) 'department': department,
      if (year      != null) 'year':       year,
      if (section   != null) 'section':    section,
    });
  }
}
