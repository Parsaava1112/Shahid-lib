import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: _analytics);

  static Future<void> logBookOpened(int bookId, String bookTitle, String type) async {
    await _analytics.logEvent(
      name: 'book_opened',
      parameters: {
        'book_id': bookId,
        'book_title': bookTitle,
        'book_type': type,
      },
    );
  }

  static Future<void> logBookCompleted(int bookId, String bookTitle) async {
    await _analytics.logEvent(
      name: 'book_completed',
      parameters: {'book_id': bookId, 'book_title': bookTitle},
    );
  }

  static Future<void> logLogin(String method) async {
    await _analytics.logEvent(
      name: 'user_login',
      parameters: {'method': method},
    );
  }

  static Future<void> logRating(int bookId, double rating) async {
    await _analytics.logEvent(
      name: 'book_rated',
      parameters: {'book_id': bookId, 'rating': rating},
    );
  }

  static Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }
}