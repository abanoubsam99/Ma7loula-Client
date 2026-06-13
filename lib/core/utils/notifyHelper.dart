import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../firebase_options.dart';
import '../../view/screens/main_screen/tabs/my_orders_tab/order_details_screen.dart';

/// ════════════════════════════════════════════════════════════════════════
/// Background isolate handler — لازم يكون top-level وعليه @pragma.
/// يشتغل لما التطبيق في الخلفية أو مقفول (terminated).
///
/// ملاحظة مهمة: لو الرسالة جاية من السيرفر وفيها بلوك `notification`، النظام
/// (Android/iOS) بيعرض الإشعار تلقائياً حتى لو التطبيق مقفول — مش محتاجين كود
/// لعرضه. الكود ده بيعرض إشعار محلي فقط لو الرسالة data-only (من غير
/// `notification`) كـ fallback.
/// ════════════════════════════════════════════════════════════════════════
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // التطبيق متهيّأ بالفعل
  }

  if (message.notification == null && message.data.isNotEmpty) {
    final helper = NotificationsHelper();
    await helper.ensureBackgroundReady();
    await helper.showOrderNotification(message);
  }
}

class NotificationsHelper {
  static final NotificationsHelper _instance = NotificationsHelper._internal();
  factory NotificationsHelper() => _instance;
  NotificationsHelper._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// قناة موحّدة عالية الأهمية — لازم تطابق `default_notification_channel_id`
  /// الموجودة في AndroidManifest.xml عشان الإشعارات اللي بيعرضها النظام وقت
  /// إغلاق التطبيق تستخدم نفس القناة (صوت + heads-up).
  static const String channelId = 'high_importance_channel';
  static const String channelName = 'إشعارات الطلبات';
  static const String channelDescription = 'إشعارات حالة الطلبات والعروض';

  static final Int64List _vibrationPattern =
      Int64List.fromList([0, 600, 250, 600]);

  /// Global Navigator Key للوصول للـ Navigator من أي مكان (حتى الإشعارات).
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// بيانات إشعار في انتظار فتح صفحة التفاصيل — تُستخدم لو الـ Navigator لسه
  /// مش جاهز (التطبيق بيفتح من حالة الإغلاق).
  static Map<String, dynamic>? _pendingRouteData;

  // ──────────────────────────────────────────────────────────────────────
  // Initialization
  // ──────────────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    await _initializeFirebase();
    await _initializeLocalNotifications();
    _setupFCMListeners();
    await _getFCMToken();
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      if (!e.toString().contains('duplicate-app')) rethrow;
    }

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // نوقف عرض iOS التلقائي للإشعار وهو foreground عشان نعرض إشعار محلي واحد
    // على المنصتين ويبقى سلوك الضغط موحّد.
    await messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings =
        InitializationSettings(android: androidSettings, iOS: iOSSettings);

    await flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _createChannel();
  }

  /// تهيئة الإشعارات المحلية في الـ background isolate.
  Future<void> ensureBackgroundReady() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSSettings = DarwinInitializationSettings();
    const settings =
        InitializationSettings(android: androidSettings, iOS: iOSSettings);

    await flutterLocalNotificationsPlugin.initialize(settings);
    await _createChannel();
  }

  Future<void> _createChannel() async {
    final androidPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      vibrationPattern: _vibrationPattern,
      showBadge: true,
    );

    await androidPlugin?.createNotificationChannel(channel);
  }

  void _setupFCMListeners() {
    // التطبيق مفتوح (foreground)
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    // التطبيق في الخلفية أو مقفول
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    // الضغط على الإشعار والتطبيق في الخلفية (مش مقفول بالكامل)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpenedApp);
  }

  // ──────────────────────────────────────────────────────────────────────
  // Launch (terminated → tap) handling
  // ──────────────────────────────────────────────────────────────────────

  /// يُستدعى بعد أول إطار: يفتح صفحة تفاصيل الطلب لو التطبيق اتفتح من إشعار
  /// وهو مقفول (terminated). بيغطي 3 حالات:
  ///  1) إشعار FCM فيه `notification` → getInitialMessage
  ///  2) إشعار محلي (data-only) → getNotificationAppLaunchDetails
  ///  3) أي route كان مُعلّق لحد ما الـ Navigator جاهز
  Future<void> handleLaunchNotification() async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null && initialMessage.data.isNotEmpty) {
      _navigateToOrderDetails(initialMessage.data);
      return;
    }

    final launchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      final data = _decodePayload(launchDetails!.notificationResponse?.payload);
      if (data != null) {
        _navigateToOrderDetails(data);
        return;
      }
    }

    if (_pendingRouteData != null) {
      final data = _pendingRouteData!;
      _pendingRouteData = null;
      _navigateToOrderDetails(data);
    }
  }

  // ──────────────────────────────────────────────────────────────────────
  // Message handlers
  // ──────────────────────────────────────────────────────────────────────

  /// التطبيق مفتوح: النظام مش بيعرض الإشعار، فنعرض إشعار محلي قابل للضغط.
  void _handleForegroundMessage(RemoteMessage message) {
    showOrderNotification(message);
  }

  /// الضغط على إشعار FCM والتطبيق في الخلفية.
  void _handleNotificationOpenedApp(RemoteMessage message) {
    _navigateToOrderDetails(message.data);
  }

  /// الضغط على إشعار محلي (foreground / data-only).
  void _onNotificationTapped(NotificationResponse response) {
    final data = _decodePayload(response.payload);
    if (data != null) _navigateToOrderDetails(data);
  }

  /// عرض إشعار محلي عالي الأهمية يحمل بيانات الطلب في payload.
  Future<void> showOrderNotification(RemoteMessage message) async {
    final title = message.notification?.title ??
        message.data['title']?.toString() ??
        'تحديث على طلبك';
    final body = message.notification?.body ??
        message.data['body']?.toString() ??
        'اضغط لعرض تفاصيل الطلب';

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      vibrationPattern: _vibrationPattern,
      visibility: NotificationVisibility.public,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(body, contentTitle: title),
    );

    const iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(android: androidDetails, iOS: iOSDetails);

    await flutterLocalNotificationsPlugin.show(
      message.messageId?.hashCode ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: jsonEncode(message.data),
    );
  }

  // ──────────────────────────────────────────────────────────────────────
  // Navigation → Order Details
  // ──────────────────────────────────────────────────────────────────────

  void _navigateToOrderDetails(Map<String, dynamic> data) {
    final route = _extractOrderRoute(data);
    if (route == null) {
      debugPrint('⚠️ إشعار من غير order_id صالح — تم تجاهل الفتح: $data');
      return;
    }

    final navigator = navigatorKey.currentState;
    if (navigator != null) {
      navigator.push(
        MaterialPageRoute(
          builder: (_) => OrderDetails(
            orderNum: route.orderNum,
            orderType: route.orderType,
          ),
        ),
      );
      return;
    }

    // الـ Navigator لسه مش جاهز (التطبيق بيفتح من الإغلاق) — خزّن وأعد المحاولة
    // بعد أول إطار.
    _pendingRouteData = data;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final nav = navigatorKey.currentState;
      if (nav == null || _pendingRouteData == null) return;
      final pending = _pendingRouteData!;
      _pendingRouteData = null;
      final r = _extractOrderRoute(pending);
      if (r == null) return;
      nav.push(
        MaterialPageRoute(
          builder: (_) =>
              OrderDetails(orderNum: r.orderNum, orderType: r.orderType),
        ),
      );
    });
  }

  /// يستخرج رقم ونوع الطلب من بيانات الإشعار.
  /// يرجّع null لو مفيش order id صالح.
  _OrderRoute? _extractOrderRoute(Map<String, dynamic> data) {
    if (data.isEmpty) return null;
    final rawId = data['order_id'] ??
        data['orderId'] ??
        data['id'] ??
        data['order_vendor_id'];
    final orderNum = int.tryParse('${rawId ?? ''}'.trim());
    if (orderNum == null) return null;

    final orderType =
        _resolveOrderType(data['order_type'] ?? data['type'] ?? data['category']);
    return _OrderRoute(orderNum, orderType);
  }

  /// تحويل نوع الطلب من نص/رقم إلى الـ index المستخدَم في OrderDetails:
  /// 0=battery، 1=tires، 2=car-parts، 3=winch، 4=emergency.
  int _resolveOrderType(dynamic raw) {
    final value = '${raw ?? ''}'.trim().toLowerCase();
    switch (value) {
      case '0':
      case 'battery':
      case 'batteries':
        return 0;
      case '1':
      case 'tire':
      case 'tires':
        return 1;
      case '2':
      case 'car-parts':
      case 'car_parts':
      case 'carparts':
      case 'parts':
        return 2;
      case '3':
      case 'winch':
        return 3;
      case '4':
      case 'emergency':
        return 4;
      default:
        return int.tryParse(value) ?? 2;
    }
  }

  Map<String, dynamic>? _decodePayload(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return null;
  }

  // ──────────────────────────────────────────────────────────────────────
  // FCM token & topics
  // ──────────────────────────────────────────────────────────────────────

  Future<String?> _getFCMToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    debugPrint('FCM Token: $token');
    return token;
  }

  Future<void> subscribeToTopic(String topic) =>
      FirebaseMessaging.instance.subscribeToTopic(topic);

  Future<void> unsubscribeFromTopic(String topic) =>
      FirebaseMessaging.instance.unsubscribeFromTopic(topic);
}

/// رقم ونوع الطلب المستخرَجين من إشعار.
class _OrderRoute {
  final int orderNum;
  final int orderType;
  const _OrderRoute(this.orderNum, this.orderType);
}
