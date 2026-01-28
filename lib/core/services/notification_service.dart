/// ==========================================================================
/// notification_service.dart
/// ==========================================================================
/// Firebase Cloud Messaging (FCM) xizmati.
/// Push bildirishnomalari, topic subscriptions, local notifications.
/// ==========================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Notification turi
enum NotificationType {
  /// Aksiya va chegirmalar
  promotion,
  
  /// Yangi sovg'alar
  reward,
  
  /// Ball o'zgarishi
  points,
  
  /// Do'kon yangiliklari
  store,
  
  /// Umumiy
  general,
}

/// Notification sozlamalari
class NotificationSettings {
  final bool enabled;
  final bool promotions;
  final bool rewards;
  final bool points;
  final bool stores;
  final bool sound;
  final bool vibration;

  const NotificationSettings({
    this.enabled = true,
    this.promotions = true,
    this.rewards = true,
    this.points = true,
    this.stores = true,
    this.sound = true,
    this.vibration = true,
  });

  NotificationSettings copyWith({
    bool? enabled,
    bool? promotions,
    bool? rewards,
    bool? points,
    bool? stores,
    bool? sound,
    bool? vibration,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      promotions: promotions ?? this.promotions,
      rewards: rewards ?? this.rewards,
      points: points ?? this.points,
      stores: stores ?? this.stores,
      sound: sound ?? this.sound,
      vibration: vibration ?? this.vibration,
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'promotions': promotions,
    'rewards': rewards,
    'points': points,
    'stores': stores,
    'sound': sound,
    'vibration': vibration,
  };

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enabled: json['enabled'] ?? true,
      promotions: json['promotions'] ?? true,
      rewards: json['rewards'] ?? true,
      points: json['points'] ?? true,
      stores: json['stores'] ?? true,
      sound: json['sound'] ?? true,
      vibration: json['vibration'] ?? true,
    );
  }
}

/// Background message handler (top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('🔔 Background message: ${message.messageId}');
  }
}

/// FCM Notification Service
class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance => _instance ??= NotificationService._();
  
  NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  NotificationSettings _settings = const NotificationSettings();
  
  final StreamController<RemoteMessage> _messageController = 
      StreamController<RemoteMessage>.broadcast();
  final StreamController<String?> _tokenController = 
      StreamController<String?>.broadcast();

  /// FCM token
  String? get fcmToken => _fcmToken;
  
  /// Bildirishnoma sozlamalari
  NotificationSettings get settings => _settings;
  
  /// Message stream
  Stream<RemoteMessage> get onMessage => _messageController.stream;
  
  /// Token refresh stream
  Stream<String?> get onTokenRefresh => _tokenController.stream;

  /// Xizmatni boshlash
  Future<void> initialize() async {
    // Background handler ro'yxatdan o'tkazish
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Ruxsat so'rash
    await _requestPermission();

    // Local notifications sozlash
    await _initializeLocalNotifications();

    // FCM token olish
    await _getFcmToken();

    // Token yangilanishini tinglash
    _messaging.onTokenRefresh.listen((token) {
      _fcmToken = token;
      _tokenController.add(token);
      if (kDebugMode) print('🔄 FCM Token yangilandi');
    });

    // Foreground xabarlarni tinglash
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // App ochilganda xabar bilan
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // App yopiq bo'lganda kelgan xabar
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }

    // Default topic'larga obuna
    await _subscribeToDefaultTopics();

    if (kDebugMode) {
      print('✅ NotificationService initialized');
      print('   FCM Token: ${_fcmToken?.substring(0, 20)}...');
    }
  }

  /// Ruxsat so'rash
  Future<bool> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    final granted = settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    if (kDebugMode) {
      print('🔔 Notification permission: ${settings.authorizationStatus}');
    }

    return granted;
  }

  /// Local notifications sozlash
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Android notification channel
    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        'loyalty_card_channel',
        'LoyaltyCard Notifications',
        description: 'Loyalty card app notifications',
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  /// FCM token olish
  Future<void> _getFcmToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      _tokenController.add(_fcmToken);
    } catch (e) {
      if (kDebugMode) print('❌ FCM token olishda xato: $e');
    }
  }

  /// Default topic'larga obuna
  Future<void> _subscribeToDefaultTopics() async {
    if (_settings.promotions) await subscribeToTopic('promotions');
    if (_settings.rewards) await subscribeToTopic('rewards');
    if (_settings.points) await subscribeToTopic('points');
  }

  /// Foreground xabar handler
  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('🔔 Foreground message: ${message.notification?.title}');
    }

    _messageController.add(message);

    // Local notification ko'rsatish
    if (message.notification != null) {
      _showLocalNotification(
        title: message.notification!.title ?? 'LoyaltyCard',
        body: message.notification!.body ?? '',
        payload: jsonEncode(message.data),
      );
    }
  }

  /// App ochilganda xabar handler
  void _handleMessageOpenedApp(RemoteMessage message) {
    if (kDebugMode) {
      print('📱 App opened from notification: ${message.data}');
    }
    _messageController.add(message);
    _handleDeepLink(message.data);
  }

  /// Notification bosilganda
  void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) {
      print('👆 Notification tapped: ${response.payload}');
    }
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        _handleDeepLink(data);
      } catch (e) {
        if (kDebugMode) print('❌ Payload parsing error: $e');
      }
    }
  }

  /// Deep linking logic
  void _handleDeepLink(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final id = data['id'] as String?;
    
    // app.dart dagi navigatorKey orqali navigatsiya
    // Import 'package:loyaltycard/app.dart' needed but since we use dynamic we'll be careful
    // Note: In a real project, we'd use a dedicated NavigationService
  }

  /// Proximity notification (Yaqinlashganda)
  Future<void> showProximityNotification({
    required String storeId,
    required String storeName,
    required double distance,
  }) async {
    final distStr = distance < 1000 
        ? '${distance.toInt()} m' 
        : '${(distance / 1000).toStringAsFixed(1)} km';
        
    await _showLocalNotification(
      title: 'Yaqinindagi do\'kon! 📍',
      body: '$storeName sizdan bor-yog\'i $distStr uzoqlikda. Kirib o\'ting!',
      payload: jsonEncode({
        'type': 'store',
        'id': storeId,
      }),
    );
  }

  /// Ballar tugashi haqida ogohlantirish
  Future<void> showPointsExpiryNotification({
    required String storeName,
    required int points,
    required int daysLeft,
  }) async {
    await _showLocalNotification(
      title: 'Ballar muddati tugamoqda! ⚠️',
      body: '$storeName dagi $points ballingiz $daysLeft kundan keyin yonib ketadi.',
      payload: jsonEncode({'type': 'wallet'}),
    );
  }

  /// Local notification ko'rsatish
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'loyalty_card_channel',
      'LoyaltyCard Notifications',
      channelDescription: 'Loyalty card app notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // ==================== Public API ====================

  /// Topic'ga obuna bo'lish
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      if (kDebugMode) print('✅ Subscribed to: $topic');
    } catch (e) {
      if (kDebugMode) print('❌ Subscribe error: $e');
    }
  }

  /// Topic'dan chiqish
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      if (kDebugMode) print('✅ Unsubscribed from: $topic');
    } catch (e) {
      if (kDebugMode) print('❌ Unsubscribe error: $e');
    }
  }

  /// Do'konga obuna
  Future<void> subscribeToStore(String storeId) async {
    await subscribeToTopic('store_$storeId');
  }

  /// Do'kondan chiqish
  Future<void> unsubscribeFromStore(String storeId) async {
    await unsubscribeFromTopic('store_$storeId');
  }

  /// Sozlamalarni yangilash
  Future<void> updateSettings(NotificationSettings newSettings) async {
    final old = _settings;
    _settings = newSettings;

    // Topic subscription'larni yangilash
    if (old.promotions != newSettings.promotions) {
      if (newSettings.promotions) {
        await subscribeToTopic('promotions');
      } else {
        await unsubscribeFromTopic('promotions');
      }
    }

    if (old.rewards != newSettings.rewards) {
      if (newSettings.rewards) {
        await subscribeToTopic('rewards');
      } else {
        await unsubscribeFromTopic('rewards');
      }
    }

    if (old.points != newSettings.points) {
      if (newSettings.points) {
        await subscribeToTopic('points');
      } else {
        await unsubscribeFromTopic('points');
      }
    }
  }

  /// Test notification yuborish
  Future<void> sendTestNotification() async {
    await _showLocalNotification(
      title: 'Test Notification',
      body: 'Bu test bildirishnomasi. Hammasi ishlayapti! 🎉',
    );
  }

  /// Xizmatni to'xtatish
  void dispose() {
    _messageController.close();
    _tokenController.close();
  }
}
