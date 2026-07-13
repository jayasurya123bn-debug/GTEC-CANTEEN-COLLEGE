import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class ReviewProvider with ChangeNotifier {
  Future<List<ReviewModel>> fetchReviewsForItem(String itemId) async {
    try {
      final res = await ApiService.client.get('${ApiConfig.reviews}/menu/$itemId');
      List<dynamic> data = res.data['reviews'];
      return data.map((j) => ReviewModel.fromJson(j)).toList();
    } catch (e) {
      print('Error fetching reviews: $e');
      return [];
    }
  }

  Future<void> submitReview(String itemId, int rating, String comment) async {
    await ApiService.client.post('${ApiConfig.reviews}/menu/$itemId', data: {
      'rating': rating,
      'comment': comment,
    });
  }
}
