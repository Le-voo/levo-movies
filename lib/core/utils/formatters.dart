import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'TBA';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (_) {
      return dateString;
    }
  }

  static String formatYear(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'TBA';
    try {
      final date = DateTime.parse(dateString);
      return date.year.toString();
    } catch (_) {
      return dateString.length >= 4 ? dateString.substring(0, 4) : dateString;
    }
  }

  static String formatRating(double? rating) {
    if (rating == null || rating == 0) return 'NR';
    return rating.toStringAsFixed(1);
  }

  static String formatRuntime(int? minutes) {
    if (minutes == null || minutes <= 0) return 'Unknown';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours == 0) return '${mins}m';
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }

  static String formatCurrency(int? amount) {
    if (amount == null || amount <= 0) return 'N/A';
    if (amount >= 1000000000) {
      return '\$${(amount / 1000000000).toStringAsFixed(1)}B';
    }
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(0)}K';
    }
    return '\$$amount';
  }
}
