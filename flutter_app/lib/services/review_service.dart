import 'api_service.dart';
import '../config/api_config.dart';

class ReviewService {
  static Future<List<dynamic>> getReviewsForMenu(String menuId) async {
    final res = await ApiService.client.get('${ApiConfig.reviews}/menu/$menuId');
    return res.data['reviews'];
  }

  static Future<void> submitReview(String menuId, double rating, String comment) async {
    await ApiService.client.post('${ApiConfig.reviews}/menu/$menuId', data: {
      'rating': rating,
      'comment': comment,
    });
  }
}
