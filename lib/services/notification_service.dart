import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _fcmToken;

  Future<void> initialize() async {
    await _initializeLocalNotifications();
    await _initializeFirebaseMessaging();
    await _requestPermissions();
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  Future<void> _initializeFirebaseMessaging() async {
    // Get FCM token
    _fcmToken = await _firebaseMessaging.getToken();
    print('FCM Token: $_fcmToken');

    // Listen to token refresh
    _firebaseMessaging.onTokenRefresh.listen((token) {
      _fcmToken = token;
      _updateUserToken(token);
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  Future<void> _requestPermissions() async {
    // Request notification permission
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Request local notification permission
    await Permission.notification.request();
  }

  Future<void> _updateUserToken(String token) async {
    try {
      // Update user's FCM token in database
      // This would typically be done when user logs in
      print('Updating user token: $token');
    } catch (e) {
      print('Error updating user token: $e');
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Received foreground message: ${message.messageId}');
    
    // Show local notification
    await _showLocalNotification(
      title: message.notification?.title ?? 'إشعار جديد',
      body: message.notification?.body ?? 'لديك إشعار جديد',
      payload: message.data.toString(),
    );
  }

  Future<void> _handleNotificationTap(RemoteMessage message) async {
    print('Notification tapped: ${message.messageId}');
    
    // Handle navigation based on notification data
    final data = message.data;
    if (data.containsKey('screen')) {
      _navigateToScreen(data['screen'], data);
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('Local notification tapped: ${response.payload}');
    
    // Handle local notification tap
    if (response.payload != null) {
      // Parse payload and navigate
    }
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'schoolz_channel',
      'Schoolz Notifications',
      channelDescription: 'Notifications for Schoolz app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Save notification to database
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'body': body,
        'data': data ?? {},
        'read': false,
        'createdAt': Timestamp.now(),
      });

      // In a real app, you would send this via FCM Admin SDK
      // For now, we'll just save to database
      print('Notification saved for user: $userId');
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  Future<void> sendTripNotification({
    required String userId,
    required String tripId,
    required String type, // 'departure', 'arrival', 'delay', 'cancellation'
    Map<String, dynamic>? additionalData,
  }) async {
    String title = '';
    String body = '';

    switch (type) {
      case 'departure':
        title = 'انطلاق الحافلة';
        body = 'الحافلة في طريقها إليك';
        break;
      case 'arrival':
        title = 'وصول الحافلة';
        body = 'الحافلة وصلت إلى موقعك';
        break;
      case 'delay':
        title = 'تأخير في الرحلة';
        body = 'هناك تأخير في رحلتك';
        break;
      case 'cancellation':
        title = 'إلغاء الرحلة';
        body = 'تم إلغاء رحلتك';
        break;
    }

    await sendNotificationToUser(
      userId: userId,
      title: title,
      body: body,
      data: {
        'type': 'trip',
        'tripId': tripId,
        'screen': 'trip_details',
        ...?additionalData,
      },
    );
  }

  Future<void> sendPaymentNotification({
    required String userId,
    required String paymentId,
    required String status,
    double? amount,
  }) async {
    String title = '';
    String body = '';

    switch (status) {
      case 'completed':
        title = 'تم الدفع بنجاح';
        body = amount != null ? 'تم دفع $amount جنيه' : 'تم الدفع بنجاح';
        break;
      case 'failed':
        title = 'فشل في الدفع';
        body = 'حدث خطأ أثناء معالجة الدفع';
        break;
      case 'refunded':
        title = 'تم استرداد المبلغ';
        body = amount != null ? 'تم استرداد $amount جنيه' : 'تم استرداد المبلغ';
        break;
    }

    await sendNotificationToUser(
      userId: userId,
      title: title,
      body: body,
      data: {
        'type': 'payment',
        'paymentId': paymentId,
        'screen': 'payment_history',
      },
    );
  }

  Future<void> sendEmergencyNotification({
    required String userId,
    required String message,
  }) async {
    await sendNotificationToUser(
      userId: userId,
      title: 'تنبيه طوارئ',
      body: message,
      data: {
        'type': 'emergency',
        'screen': 'emergency',
      },
    );
  }

  Future<List<Map<String, dynamic>>> getUserNotifications(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['title'],
          'body': data['body'],
          'data': data['data'],
          'read': data['read'],
          'createdAt': data['createdAt'],
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'read': true,
        'readAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('read', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          'read': true,
          'readAt': Timestamp.now(),
        });
      }
      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  void _navigateToScreen(String screen, Map<String, dynamic> data) {
    switch (screen) {
      case 'trip_details':
        // Navigate to trip details
        break;
      case 'payment_history':
        // Navigate to payment history
        break;
      case 'emergency':
        // Navigate to emergency screen
        break;
      default:
        // Navigate to home
        break;
    }
  }

  String? get fcmToken => _fcmToken;
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
  // Handle background message
}
