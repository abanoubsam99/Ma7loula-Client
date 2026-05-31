import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

import '../../firebase_options.dart';
import '../widgets/order_alert_screen.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final helper = NotificationsHelper();
  await helper._ensureBackgroundReady();
  await helper.processIncomingMessage(message);
}

class NotificationsHelper {
  static final NotificationsHelper _instance = NotificationsHelper._internal();
  factory NotificationsHelper() => _instance;

  NotificationsHelper._internal();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  static const String orderChannelId = 'order_alerts_channel';
  static const String visitChannelId = 'visit_alerts_channel';

  /// معرف ثابت — كل إشعار جديد يستبدل السابق (إشعار واحد فقط في الشريط)
  static const int _alertNotificationId = 9001;

  /// نمط اهتزاز قوي ومكرر
  static final Int64List _strongVibrationPattern = Int64List.fromList([
    0, 1000, 300, 1000, 300, 1000, 300, 1000, 300, 1000, 300, 1500,
  ]);

  static Map<String, dynamic>? _pendingAlertData;
  static String? _lastProcessedAlertKey;
  static DateTime? _lastProcessedAt;
  static bool _isAlertScreenOpen = false;
  static String? _openAlertOrderKey;

  // Global Navigator Key للوصول للـ context من أي مكان
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Initialize Firebase Messaging and set up listeners
  Future<void> initialize() async {
    await _initializeFirebase();
    await _initializeLocalNotifications();

    // Setup Firebase Cloud Messaging (FCM) listeners for incoming messages
    _setupFCMListeners();

    // Get FCM token (optional, if you want to store or use it)
    await _getFCMToken();
  }

  /// يستدعى بعد أول إطار عندما يكون الـ Navigator جاهزا
  Future<void> handleLaunchNotification() async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationOpenedApp(initialMessage);
    }
  }

  /// Initialize Firebase
  Future<void> _initializeFirebase() async {
    // التحقق إذا كان Firebase مهيأ بالفعل
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      if (e.toString().contains('duplicate-app')) {
        print('✅ Firebase already initialized');
      } else {
        rethrow;
      }
    }
    
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request notification permissions for iOS
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iOSSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );
    
    await flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    final AndroidNotificationChannel orderChannel = AndroidNotificationChannel(
      orderChannelId,
      'طلبات التوصيل',
      description: 'إشعارات الطلبات الجديدة للمندوبين',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      vibrationPattern: _strongVibrationPattern,
      showBadge: true,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 0, 0),
    );

    final AndroidNotificationChannel visitChannel = AndroidNotificationChannel(
      visitChannelId,
      'مواعيد الزيارات',
      description: 'تنبيهات مواعيد الزيارات للمندوبين',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      vibrationPattern: _strongVibrationPattern,
      showBadge: true,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 165, 0),
    );

    await androidPlugin?.createNotificationChannel(orderChannel);
    await androidPlugin?.createNotificationChannel(visitChannel);
  }

  /// تهيئة الإشعارات المحلية في الـ background isolate
  Future<void> _ensureBackgroundReady() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iOSSettings = DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(settings);

    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    final AndroidNotificationChannel orderChannel = AndroidNotificationChannel(
      orderChannelId,
      'طلبات التوصيل',
      description: 'إشعارات الطلبات الجديدة للمندوبين',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      vibrationPattern: _strongVibrationPattern,
      showBadge: true,
    );

    final AndroidNotificationChannel visitChannel = AndroidNotificationChannel(
      visitChannelId,
      'مواعيد الزيارات',
      description: 'تنبيهات مواعيد الزيارات للمندوبين',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      vibrationPattern: _strongVibrationPattern,
      showBadge: true,
    );

    await androidPlugin?.createNotificationChannel(orderChannel);
    await androidPlugin?.createNotificationChannel(visitChannel);
  }

  /// Setup listeners for Firebase Cloud Messaging
  void _setupFCMListeners() {
    // Handle incoming notifications when the app is in the foreground
    FirebaseMessaging.onMessage.listen(_handleIncomingNotification);

    // Handle background messages (when app is closed or in background)
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    // Handle when notification is tapped
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpenedApp);
  }

  /// Handle when notification is opened from background
  void _handleNotificationOpenedApp(RemoteMessage message) {
    print("📱 فتح التطبيق من الإشعار: ${message.data}");
    if (!_isActionableAlert(message.data)) return;
    _pendingAlertData = Map<String, dynamic>.from(message.data);
    _openAlertFromData(message.data);
  }

  static bool _isActionableAlert(Map<String, dynamic> data) {
    if (data.isEmpty) return false;
    final status = data['status']?.toString();
    return status == 'new' ||
        status == 'pending_customer' ||
        status == 'offer_pending';
  }

  static String _alertDedupeKey(Map<String, dynamic> data) {
    final orderId = data['order_vendor_id']?.toString() ?? '';
    final status = data['status']?.toString() ?? '';
    final eventType = data['event_type']?.toString() ?? '';
    return '$orderId|$status|$eventType';
  }

  bool _shouldProcessAlert(Map<String, dynamic> data) {
    if (!_isActionableAlert(data)) return false;
    final key = _alertDedupeKey(data);
    final now = DateTime.now();
    if (_lastProcessedAlertKey == key &&
        _lastProcessedAt != null &&
        now.difference(_lastProcessedAt!) < const Duration(seconds: 5)) {
      return false;
    }
    _lastProcessedAlertKey = key;
    _lastProcessedAt = now;
    return true;
  }

  void _openAlertFromData(Map<String, dynamic> data) {
    if (!_isActionableAlert(data)) return;
    _pendingAlertData = Map<String, dynamic>.from(data);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showFullScreenOrderAlert(data);
    });
  }

  /// Handle incoming FCM notifications when the app is in the foreground
  void _handleIncomingNotification(RemoteMessage message) {
    processIncomingMessage(message, showFullScreen: true);
  }

  /// معالجة الإشعار الوارد (foreground / background)
  Future<void> processIncomingMessage(
    RemoteMessage message, {
    bool showFullScreen = false,
  }) async {
    if (message.data.isEmpty || !_shouldProcessAlert(message.data)) return;

    final title = message.notification?.title ??
        message.data['title']?.toString() ??
        'طلب توصيل جديد 🚨';
    final body = message.notification?.body ??
        message.data['body']?.toString() ??
        'لديك إشعار جديد يحتاج انتباهك';
    final type = _resolveNotificationType(message.data, title, body);

    _pendingAlertData = Map<String, dynamic>.from(message.data);

    final hasContext = navigatorKey.currentContext != null;

    // التطبيق مفتوح: افتح صفحة التنبيه مباشرة (صوت واهتزاز من الشاشة نفسها)
    if (showFullScreen && hasContext) {
      _openAlertFromData(message.data);
      return;
    }

    // الخلفية: إشعار واحد فقط — لا نكرر إذا FCM عرض الإشعار بالفعل
    final fcmAlreadyDisplayed = message.notification != null;
    if (!fcmAlreadyDisplayed) {
      await _showHighPriorityNotification(
        title,
        body,
        type,
        alertData: message.data,
      );
    }

    if (hasContext) {
      _openAlertFromData(message.data);
    }
  }

  String _resolveNotificationType(
    Map<String, dynamic> data,
    String title,
    String body,
  ) {
    final combined = '$title $body'.toLowerCase();
    if (combined.contains('زيارة') || combined.contains('visit')) {
      return 'visit';
    }
    return 'order';
  }

  /// عرض Full Screen Alert للطلب الجديد
  static void showFullScreenOrderAlert(Map<String, dynamic> data) {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    if (!_isActionableAlert(data)) return;

    final orderKey = _alertDedupeKey(data);
    if (_isAlertScreenOpen && _openAlertOrderKey == orderKey) return;

    _isAlertScreenOpen = true;
    _openAlertOrderKey = orderKey;

    final notificationData = NotificationData.fromMap(data);
    final legacyOrderId = notificationData.orderId.isNotEmpty
        ? notificationData.orderId
        : notificationData.orderVendorId;

    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => OrderAlertScreen(
          notificationData: notificationData,
          notificationTitle: data['title']?.toString(),
          notificationBody: data['body']?.toString(),
          orderId: legacyOrderId,
          orderReference: data['title']?.toString() ?? 'N/A',
          customerName: extractCustomerName(data['body']?.toString()),
          location: extractLocation(data['body']?.toString()),
          orderDetails: data['body']?.toString(),
        ),
        fullscreenDialog: true,
      ),
    )
        .then((_) {
      _isAlertScreenOpen = false;
      _openAlertOrderKey = null;
    });
  }

  /// استخراج اسم العميل من body الإشعار
  static String extractCustomerName(String? body) {
    if (body == null) return 'عميل جديد';
    // TODO: تحسين الاستخراج بناء على صيغة الإشعار من Backend
    return body.split(':').first.trim();
  }
  
  /// استخراج الموقع من body الإشعار
  static String extractLocation(String? body) {
    if (body == null) return 'غير محدد';
    // TODO: تحسين الاستخراج بناء على صيغة الإشعار من Backend
    final parts = body.split(':');
    return parts.length > 1 ? parts[1].trim() : 'غير محدد';
  }
  
  String _encodeNotificationPayload(String type, Map<String, dynamic> data) {
    return jsonEncode({'type': type, 'data': data});
  }

  Map<String, dynamic>? _decodeNotificationPayload(String? payload) {
    if (payload == null || payload.isEmpty) return _pendingAlertData;
    try {
      final decoded = jsonDecode(payload) as Map<String, dynamic>;
      final data = decoded['data'];
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
    } catch (_) {}
    return _pendingAlertData;
  }

  /// عرض إشعار ذو أولوية عالية — يظهر من فوق الشاشة مع صوت واهتزاز قوي
  Future<void> _showHighPriorityNotification(
    String? title,
    String? body,
    String type, {
    Map<String, dynamic>? alertData,
  }) async {
    await flutterLocalNotificationsPlugin.cancel(_alertNotificationId);
    final isVisit = type == 'visit';
    final channelId = isVisit ? visitChannelId : orderChannelId;
    final channelName = isVisit ? 'مواعيد الزيارات' : 'طلبات التوصيل';
    final channelDesc = isVisit
        ? 'تنبيهات مواعيد الزيارات للمندوبين'
        : 'إشعارات الطلبات الجديدة للمندوبين';

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      vibrationPattern: _strongVibrationPattern,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      ticker: isVisit ? 'موعد زيارة قريب 🚨' : 'طلب توصيل جديد 🚨',
      autoCancel: true,
      ongoing: false,
      onlyAlertOnce: false,
      channelAction: AndroidNotificationChannelAction.createIfNotExists,
      additionalFlags: Int32List.fromList([4]), // FLAG_INSISTENT — يكرر الصوت
      ledOnMs: 1000,
      ledOffMs: 500,
      styleInformation: BigTextStyleInformation(
        body ?? '',
        contentTitle: title,
        summaryText: isVisit ? 'موعد زيارة' : 'طلب جديد',
      ),
    );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true, 
      //sound: 'order_alert.caf', // صوت مخصص لـ iOS
      categoryIdentifier: 'ALERT_CATEGORY',
      interruptionLevel: InterruptionLevel.critical, // مهم جدا لـ iOS
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    final data = alertData ?? _pendingAlertData ?? {};
    final payload = _encodeNotificationPayload(type, data);

    await flutterLocalNotificationsPlugin.show(
      _alertNotificationId,
      title ?? (isVisit ? "موعد زيارة قريب 🚨" : "طلب توصيل جديد 🚨"),
      body ?? (isVisit ? "لديك زيارة محددة تحتاج موافقتك" : "لديك طلب جديد يحتاج موافقتك"),
      platformDetails,
      payload: payload,
    );
  }

  /// معالجة النقر على الإشعار — فتح صفحة التنبيه
  void _onNotificationTapped(NotificationResponse response) {
    final alertData = _decodeNotificationPayload(response.payload);
    if (alertData == null || alertData.isEmpty) return;
    _openAlertFromData(alertData);
  }

  /// Get FCM token (optional, can be used to store or use the token in your app)
  static Future<String?> _getFCMToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    print("FCM Token: $token");
    return token;
  }

  /// Unsubscribe from topic (optional, if you are using FCM topics)
  Future<void> unsubscribeFromTopic(String topic) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.unsubscribeFromTopic(topic);
    print("Unsubscribed from topic: $topic");
  }

  /// Subscribe to a topic (optional, if you are using FCM topics)
  Future<void> subscribeToTopic(String topic) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.subscribeToTopic(topic);
    print("Subscribed to topic: $topic");
  }

  void handleBackgroundNotification(RemoteMessage message) {
    processIncomingMessage(message);
  }
}
