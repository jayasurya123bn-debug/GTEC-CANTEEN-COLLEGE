import 'package:intl/intl.dart';

class Helpers {
  static String formatPrice(double price) {
    return '₹${price.toStringAsFixed(2)}';
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }
}
