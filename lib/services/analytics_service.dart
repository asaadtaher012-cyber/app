import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> initialize() async {
    await _analytics.setAnalyticsCollectionEnabled(true);
    await _analytics.setUserId(id: 'user_${DateTime.now().millisecondsSinceEpoch}');
  }

  // User Events
  Future<void> logUserRegistration(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  Future<void> logUserLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  Future<void> logUserLogout() async {
    await _analytics.logEvent(name: 'user_logout');
  }

  // Trip Events
  Future<void> logTripBooked({
    required String tripId,
    required String from,
    required String to,
    required double price,
    required String paymentMethod,
  }) async {
    await _analytics.logEvent(
      name: 'trip_booked',
      parameters: {
        'trip_id': tripId,
        'from_location': from,
        'to_location': to,
        'price': price,
        'payment_method': paymentMethod,
      },
    );
  }

  Future<void> logTripCancelled({
    required String tripId,
    required String reason,
  }) async {
    await _analytics.logEvent(
      name: 'trip_cancelled',
      parameters: {
        'trip_id': tripId,
        'cancellation_reason': reason,
      },
    );
  }

  Future<void> logTripCompleted({
    required String tripId,
    required double rating,
  }) async {
    await _analytics.logEvent(
      name: 'trip_completed',
      parameters: {
        'trip_id': tripId,
        'rating': rating,
      },
    );
  }

  // Payment Events
  Future<void> logPaymentInitiated({
    required String paymentId,
    required double amount,
    required String paymentMethod,
  }) async {
    await _analytics.logEvent(
      name: 'payment_initiated',
      parameters: {
        'payment_id': paymentId,
        'amount': amount,
        'payment_method': paymentMethod,
      },
    );
  }

  Future<void> logPaymentCompleted({
    required String paymentId,
    required double amount,
    required String paymentMethod,
  }) async {
    await _analytics.logEvent(
      name: 'payment_completed',
      parameters: {
        'payment_id': paymentId,
        'amount': amount,
        'payment_method': paymentMethod,
      },
    );
  }

  Future<void> logPaymentFailed({
    required String paymentId,
    required String error,
  }) async {
    await _analytics.logEvent(
      name: 'payment_failed',
      parameters: {
        'payment_id': paymentId,
        'error': error,
      },
    );
  }

  // Feature Usage Events
  Future<void> logFeatureUsed(String featureName) async {
    await _analytics.logEvent(
      name: 'feature_used',
      parameters: {
        'feature_name': featureName,
      },
    );
  }

  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  Future<void> logButtonClicked(String buttonName, String screenName) async {
    await _analytics.logEvent(
      name: 'button_clicked',
      parameters: {
        'button_name': buttonName,
        'screen_name': screenName,
      },
    );
  }

  // Rating Events
  Future<void> logDriverRated({
    required String driverId,
    required double rating,
    required String tripId,
  }) async {
    await _analytics.logEvent(
      name: 'driver_rated',
      parameters: {
        'driver_id': driverId,
        'rating': rating,
        'trip_id': tripId,
      },
    );
  }

  // Emergency Events
  Future<void> logEmergencyAlertSent({
    required String alertType,
    required String location,
  }) async {
    await _analytics.logEvent(
      name: 'emergency_alert_sent',
      parameters: {
        'alert_type': alertType,
        'location': location,
      },
    );
  }

  // Loyalty Events
  Future<void> logLoyaltyPointsEarned({
    required int points,
    required String source,
  }) async {
    await _analytics.logEvent(
      name: 'loyalty_points_earned',
      parameters: {
        'points': points,
        'source': source,
      },
    );
  }

  Future<void> logRewardClaimed({
    required String rewardId,
    required int pointsUsed,
  }) async {
    await _analytics.logEvent(
      name: 'reward_claimed',
      parameters: {
        'reward_id': rewardId,
        'points_used': pointsUsed,
      },
    );
  }

  // Error Events
  Future<void> logError({
    required String error,
    required String screen,
    String? additionalInfo,
  }) async {
    await _analytics.logEvent(
      name: 'app_error',
      parameters: {
        'error': error,
        'screen': screen,
        'additional_info': additionalInfo ?? '',
      },
    );
  }

  // Performance Events
  Future<void> logAppPerformance({
    required String metric,
    required double value,
    String? unit,
  }) async {
    await _analytics.logEvent(
      name: 'app_performance',
      parameters: {
        'metric': metric,
        'value': value,
        'unit': unit ?? '',
      },
    );
  }

  // Custom Events
  Future<void> logCustomEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    await _analytics.logEvent(
      name: eventName,
      parameters: parameters,
    );
  }

  // User Properties
  Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  // App Lifecycle Events
  Future<void> logAppOpened() async {
    await _analytics.logAppOpen();
  }

  Future<void> logAppBackgrounded() async {
    await _analytics.logEvent(name: 'app_backgrounded');
  }

  Future<void> logAppForegrounded() async {
    await _analytics.logEvent(name: 'app_foregrounded');
  }

  // Search Events
  Future<void> logSearch({
    required String searchTerm,
    required String screen,
  }) async {
    await _analytics.logSearch(
      searchTerm: searchTerm,
    );
  }

  // Share Events
  Future<void> logShare({
    required String contentType,
    required String itemId,
    required String method,
  }) async {
    await _analytics.logShare(
      contentType: contentType,
      itemId: itemId,
      method: method,
    );
  }

  // E-commerce Events
  Future<void> logPurchase({
    required String transactionId,
    required double value,
    required String currency,
    required List<Map<String, dynamic>> items,
  }) async {
    await _analytics.logPurchase(
      transactionId: transactionId,
      value: value,
      currency: currency,
      parameters: {
        'items': items,
      },
    );
  }

  // Get Analytics Instance
  FirebaseAnalytics get analytics => _analytics;
}
