import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

import '../../firebase_options.dart';
import '../../view/screens/main_screen/tabs/my_orders_tab/order_details_screen.dart';
import '../widgets/order_alert_screen.dart';


class NotificationsHelper {
  static final NotificationsHelper _instance = NotificationsHelper._internal();
  factory NotificationsHelper() => _instance;

  NotificationsHelper._internal();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
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

  /// Initialize Firebase
  Future<void> _initializeFirebase() async {
    // التحقق إذا كان Firebase مُهيأ بالفعل
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

    // إنشاء قناة إشعارات عالية الأهمية للطلبات
    const AndroidNotificationChannel orderChannel = AndroidNotificationChannel(
      'order_alerts_channel',
      'طلبات التوصيل',
      description: 'إشعارات الطلبات الجديدة للمندوبين',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    // إنشاء قناة إشعارات للزيارات
    const AndroidNotificationChannel visitChannel = AndroidNotificationChannel(
      'visit_alerts_channel',
      'مواعيد الزيارات',
      description: 'تنبيهات مواعيد الزيارات للمندوبين',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    final plugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    await plugin?.createNotificationChannel(orderChannel);
    await plugin?.createNotificationChannel(visitChannel);
  }

  /// Setup listeners for Firebase Cloud Messaging
  void _setupFCMListeners() {
    // Handle incoming notifications when the app is in the foreground
    FirebaseMessaging.onMessage.listen(_handleIncomingNotification);

    // Handle background messages (when app is closed or in background)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle when notification is tapped
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpenedApp);
  }

  /// Handle when notification is opened from background
  void _handleNotificationOpenedApp(RemoteMessage message) {
    print("📱 فتح التطبيق من الإشعار: ${message.data}");
    
    final context = navigatorKey.currentContext;
    if (context == null) return;

    // الحصول على النوع من الـ data أو من محتوى الإشعار
    final status = message.data['status']?.toString() ;
    // final status = message.data['status']?.toString() ??
    //              (message.notification != null ? _getNotificationType(message.notification!) : '');

    if (status!=null && (status == 'new'||status == 'pending_customer'||status == 'offer_pending')) {
      // final orderId = message.data['order_id']?.toString() ?? (message.notification != null ? _extractOrderId(message.notification!.title) : '');
      // final orderModel = _findOrderModel(orderId);
      //
      if (message.data!=null && message.data['order_id'] != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OrderDetails(orderNum: int.parse(message.data['order_id'].toString()),orderType: 0,),
          ),
        );
        _showFullScreenOrderAlert(message.data!);
      } else if (message.data != null&&message.data["status"]) {
        // Backup
        _showFullScreenOrderAlert(message.data!);
      }
    }
  }

  /// Handle incoming FCM notifications when the app is in the foreground
  void _handleIncomingNotification(RemoteMessage message) {
    if (message.data!=null) {
      _handleDataMessage(message.notification!);
    }
  }

  /// Handle FCM data messages (background or foreground)
  void _handleDataMessage(RemoteNotification data) {
    // _showFullScreenOrderAlert(data);

    // // التحقق من نوع الإشعار
    // // final notificationType = _getNotificationType(data);
    //
    // if (data !=null &&(data[""]) 'visit') {
    //   // عرض Full Screen Alert للزيارة
    //   _showFullScreenVisitAlert(data);
    // } else {
    //   // عرض Full Screen Alert للطلب الجديد
    //   _showFullScreenOrderAlert(data);
    // }
  }
  
  // /// تحديد نوع الإشعار (طلب أو زيارة)
  // String _getNotificationType(RemoteNotification data) {
  //   // يمكن التحقق من العنوان أو محتوى الإشعار
  //   final title = data.title?.toLowerCase() ?? '';
  //   final body = data.body?.toLowerCase() ?? '';
  //
  //   if (title.contains('زيارة') || title.contains('visit') ||
  //       body.contains('زيارة') || body.contains('visit')) {
  //     return 'visit';
  //   }
  //   return 'order';
  // }

  /// عرض Full Screen Alert للطلب الجديد
  void _showFullScreenOrderAlert(Map<String, dynamic> data) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      // استخراج order_id من الإشعار
      // final orderId = _extractOrderId(data.title);
      
      // // محاولة إيجاد OrderModel من القائمة
      // OrderModel? orderModel = _findOrderModel(orderId);
      //
      if(data!=null)
      // فتح شاشة Full Screen Alert
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OrderAlertScreen(
            notificationData: NotificationData(
                eventType: '${data["event_type"].toString()}',
                actionRequiredFor: '${data["action_required_for"].toString()}',
                kind: '${data["kind"].toString()}',
                orderId: '${data["order_id"].toString()}',
                status: '${data["status"].toString()}',
                orderVendorStatus: '${data["order_vendor_status"].toString()}',
                orderVendorId: '${data["order_vendor_id"].toString()}',
                type: '${data["type"].toString()}',
                offeredTotal: '${data["offered_total"].toString()}',
                vendorId: '${data["vendor_id"].toString()}'
            ),
            orderId: "${data["order_id"].toString()}",
            orderReference: data["title"] ?? 'N/A',
            customerName: _extractCustomerName(data["body"]),
            location: _extractLocation(data["body"]),
            orderDetails: data["body"],
            // orderModel: orderModel, // تمرير OrderModel إذا وُجد
          ),
          fullscreenDialog: true,
        ),
      );
    }
    
    // عرض notification عادي كـ backup
    _showHighPriorityNotification("${data["title"]}", "${data["body"]}", 'order');
  }

  /// عرض Full Screen Alert للزيارة
  // void _showFullScreenVisitAlert(RemoteNotification data) {
  //   final context = navigatorKey.currentContext;
  //   if (context != null) {
  //     // استخراج visit_id من الإشعار
  //     final visitId = _extractVisitId(data.title);
  //
  //     // محاولة إيجاد VisitDetailsData من القائمة
  //     // VisitDetailsData? visitData = _findVisitData(visitId);
  //
  //     // // فتح شاشة Full Screen Alert للزيارة
  //     // Navigator.of(context).push(
  //     //   MaterialPageRoute(
  //     //     builder: (context) => VisitAlertScreen(
  //     //       visitId: visitId,
  //     //       businessName: visitData?.businessName ?? _extractBusinessName(data.body),
  //     //       customerName: visitData?.customerName ?? _extractCustomerName(data.body),
  //     //       location: visitData?.customerLocation ?? _extractLocation(data.body),
  //     //       visitDate: visitData?.createdAt ?? _extractVisitDate(data.body),
  //     //       visitData: visitData, // تمرير البيانات الكاملة إذا وُجدت
  //     //     ),
  //     //     fullscreenDialog: true,
  //     //   ),
  //     // );
  //   }
  //
  //   // عرض notification عادي كـ backup
  //   _showHighPriorityNotification(data.title, data.body, 'visit');
  // }

  /// استخراج order_id من العنوان
  String _extractOrderId(String? title) {
    if (title == null) return 'unknown';
    // مثال: "ORD-12345" → "12345"
    final parts = title.split('-');
    return parts.length > 1 ? parts.last : title;
  }
  
  /// استخراج visit_id من العنوان
  String _extractVisitId(String? title) {
    if (title == null) return 'unknown';
    // مثال: "VISIT-12345" → "12345" أو استخراج الأرقام من النص
    final parts = title.split('-');
    if (parts.length > 1) return parts.last;
    
    // محاولة استخراج الأرقام من النص
    final numbers = RegExp(r'\d+').firstMatch(title);
    return numbers?.group(0) ?? title;
  }

  // /// محاولة إيجاد OrderModel من القائمة الموجودة
  // OrderModel? _findOrderModel(String orderId) {
  //   try {
  //     // البحث في الطلبات الجديدة
  //     final order = OrdersServices.dataNew.firstWhere(
  //       (order) => order.id.toString() == orderId || order.reference == orderId,
  //       orElse: () => throw Exception('Order not found'),
  //     );
  //     return order;
  //   } catch (e) {
  //     print('⚠️ لم يتم العثور على الطلب في القائمة المحلية: $orderId');
  //     return null;
  //   }
  // }
  //
  // /// محاولة إيجاد VisitDetailsData من القائمة الموجودة
  // VisitDetailsData? _findVisitData(String visitId) {
  //   try {
  //     // البحث في الزيارات (يمكن تعديله حسب كيفية تخزين الزيارات)
  //     // افترض أن هناك قائمة VisitsServices.visits
  //     // final visit = VisitsServices.visits.firstWhere(
  //     //   (visit) => visit.id.toString() == visitId,
  //     //   orElse: () => throw Exception('Visit not found'),
  //     // );
  //     // return visit;
  //
  //     print('⚠️ لم يتم العثور على الزيارة في القائمة المحلية: $visitId');
  //     return null;
  //   } catch (e) {
  //     print('⚠️ خطأ في البحث عن الزيارة: $e');
  //     return null;
  //   }
  // }

  /// استخراج اسم العميل من body الإشعار
  String _extractCustomerName(String? body) {
    if (body == null) return 'عميل جديد';
    // TODO: تحسين الاستخراج بناءً على صيغة الإشعار من Backend
    return body.split(':').first.trim();
  }
  
  /// استخراج اسم المنشأة التجارية من body الإشعار
  String _extractBusinessName(String? body) {
    if (body == null) return 'غير محدد';
    // TODO: تحسين الاستخراج بناءً على صيغة الإشعار من Backend
    final parts = body.split('|');
    return parts.isNotEmpty ? parts.first.trim() : 'غير محدد';
  }

  /// استخراج الموقع من body الإشعار
  String _extractLocation(String? body) {
    if (body == null) return 'غير محدد';
    // TODO: تحسين الاستخراج بناءً على صيغة الإشعار من Backend
    final parts = body.split(':');
    return parts.length > 1 ? parts[1].trim() : 'غير محدد';
  }
  
  /// استخراج موعد الزيارة من body الإشعار
  String _extractVisitDate(String? body) {
    if (body == null) return 'غير محدد';
    // TODO: تحسين الاستخراج بناءً على صيغة الإشعار من Backend
    final dateMatch = RegExp(r'\d{4}-\d{2}-\d{2}').firstMatch(body ?? '');
    return dateMatch?.group(0) ?? 'غير محدد';
  }

  /// عرض إشعار ذو أولوية عالية (Backup للـ Full Screen Alert)
  Future<void> _showHighPriorityNotification(String? title, String? body, String type) async {
    final isVisit = type == 'visit';
    final channelId = isVisit ? 'visit_alerts_channel' : 'order_alerts_channel';
    final channelName = isVisit ? 'مواعيد الزيارات' : 'طلبات التوصيل';
    final channelDesc = isVisit 
        ? 'تنبيهات مواعيد الزيارات للمندوبين'
        : 'إشعارات الطلبات الجديدة للمندوبين';
    
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true, // مهم جداً للأندرويد
      category: AndroidNotificationCategory.alarm,
      ticker: isVisit ? 'موعد زيارة قريب' : 'طلب توصيل جديد',
 //     sound: RawResourceAndroidNotificationSound('order_alert'),
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
      interruptionLevel: InterruptionLevel.critical, // مهم جداً لـ iOS
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title ?? (isVisit ? "موعد زيارة قريب 🚨" : "طلب توصيل جديد 🚨"),
      body ?? (isVisit ? "لديك زيارة محددة تحتاج موافقتك" : "لديك طلب جديد يحتاج موافقتك"),
      platformDetails,
      payload: type == 'visit' ? 'visit|$title' : 'order|$title',
    );
  }

  /// معالجة النقر على الإشعار
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload ?? '';
    final parts = payload.split('|');
    final type = parts.first;
    final title = parts.length > 1 ? parts[1] : '';

    final context = navigatorKey.currentContext;
    if (context == null) return;

    if (type == 'order' || type == 'order_alert') {
      print('📱 تم النقر على إشعار الطلب');
      final orderId = _extractOrderId(title);
      // final orderModel = _findOrderModel(orderId);
      //
      // if (orderModel != null) {
      //   Navigator.of(context).push(
      //     MaterialPageRoute(
      //       builder: (context) => OrderDetailsScreen(orderModel: orderModel),
      //     ),
      //   );
      // } else {
      //   print('⚠️ لم يتم العثور على تفاصيل الطلب');
      // }
    } else if (type == 'visit' || type == 'visit_alert') {
      print('📱 تم النقر على إشعار الزيارة');
      final visitId = _extractVisitId(title);
      // final visitData = _findVisitData(visitId);
      //
      // if (visitData != null) {
      //   Navigator.of(context).push(
      //     MaterialPageRoute(
      //       builder: (context) => VisitDetails(visitDetailsData: visitData),
      //     ),
      //   );
      // } else {
      //   print('⚠️ لم يتم العثور على تفاصيل الزيارة');
      // }
    }
  }

  /// Background message handler (to handle notifications when the app is in the background)
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    final helper = NotificationsHelper();
    if (message.notification!=null) {
      helper._handleDataMessage(message.notification!);
    }
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
}
