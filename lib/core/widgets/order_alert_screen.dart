import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ma7lola/core/widgets/responsive_helper.dart';

import 'package:audioplayers/audioplayers.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 App Theme
// ═══════════════════════════════════════════════════════════════════════════
class AppTheme {
  static const Color primary = Color(0xFF6842E2);
  static const Color primaryLight = Color(0xFF8B6CEF);
  static const Color primaryDark = Color(0xFF5234B5);
  static const Color secondary = Color(0xFF00C88D);
  static const Color accent = Color(0xFFFBBF4D);
  static const Color error = Color(0xFFFF6B6B);
  static const Color info = Color(0xFF74B9FF);
  static const Color white = Colors.white;
  static const Color cyan = Color(0xFF28E6C5);

  static const Color darkBackground = Color(0xFF0A0A12);
  static const Color darkCard = Color(0xFF14141F);
  static const Color darkSurface = Color(0xFF1E1E2D);
  static const Color darkBorder = Color(0xFF2A2A3D);
  static const Color darkText = Color(0xFFF5F5F7);
  static const Color darkTextSecondary = Color(0xFF8E8EA0);

  static const Color lightBackground = Color(0xFFF8F9FC);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF1F3F8);
  static const Color lightBorder = Color(0xFFE8EBF0);
  static const Color lightText = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF6E7191);

  static Color getBackground(bool isDark) =>
      isDark ? darkBackground : lightBackground;
  static Color getCard(bool isDark) => isDark ? darkCard : lightCard;
  static Color getSurface(bool isDark) => isDark ? darkSurface : lightSurface;
  static Color getBorder(bool isDark) => isDark ? darkBorder : lightBorder;
  static Color getText(bool isDark) => isDark ? darkText : lightText;
  static Color getTextSecondary(bool isDark) =>
      isDark ? darkTextSecondary : lightTextSecondary;

  static LinearGradient get primaryGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static LinearGradient get secondaryGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, Color(0xFF00E6A0)],
  );

  static LinearGradient get accentGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, Color(0xFFFFD93D)],
  );

  static LinearGradient get cyanGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cyan, Color(0xFF06B6D4)],
  );

  static LinearGradient get errorGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [error, Color(0xFFFF8A8A)],
  );

  static LinearGradient alertBackgroundGradient(bool isDark) => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: isDark
        ? [
      const Color(0xFF1A1040),
      const Color(0xFF0D0D1A),
      darkBackground,
    ]
        : [
      primary.withOpacity(0.15),
      lightBackground,
      white,
    ],
  );

  static List<BoxShadow> softShadow(bool isDark) => [
    BoxShadow(
      color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
      blurRadius: 20,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
  ];

  static List<BoxShadow> glowShadow(Color color, bool isDark) => [
    BoxShadow(
      color: color.withOpacity(isDark ? 0.4 : 0.3),
      blurRadius: 20,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
  ];
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔧 AnimatedBuilder Helper
// ═══════════════════════════════════════════════════════════════════════════
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) => builder(context, child);
}

// ═══════════════════════════════════════════════════════════════════════════
// 📦 Notification Data Model
// ═══════════════════════════════════════════════════════════════════════════
class NotificationData {
  final String eventType;
  final String actionRequiredFor;
  final String kind;
  final String orderId;
  final String status;
  final String orderVendorStatus;
  final String orderVendorId;
  final String type;
  final String offeredTotal;
  final String vendorId;

  const NotificationData({
    required this.eventType,
    required this.actionRequiredFor,
    required this.kind,
    required this.orderId,
    required this.status,
    required this.orderVendorStatus,
    required this.orderVendorId,
    required this.type,
    required this.offeredTotal,
    required this.vendorId,
  });

  factory NotificationData.fromMap(Map<String, dynamic> data) {
    return NotificationData(
      eventType: data['event_type'] ?? '',
      actionRequiredFor: data['action_required_for'] ?? '',
      kind: data['kind'] ?? '',
      orderId: data['order_id'] ?? '',
      status: data['status'] ?? '',
      orderVendorStatus: data['order_vendor_status'] ?? '',
      orderVendorId: data['order_vendor_id'] ?? '',
      type: data['type'] ?? '',
      offeredTotal: data['offered_total'] ?? '',
      vendorId: data['vendor_id'] ?? '',
    );
  }
}

/// 🚨 Full Screen Alert Screen for new delivery/vendor offer notifications
class OrderAlertScreen extends StatefulWidget {
  // --- Legacy fields (optional, kept for backward compatibility) ---
  final String? orderId;
  final String? orderReference;
  final String? customerName;
  final String? location;
  final String? orderDetails;

  // --- NEW: FCM notification data ---
  final String? notificationTitle;
  final String? notificationBody;
  final NotificationData? notificationData;

  // --- Callbacks for accept / reject ---
  final Future<void> Function()? onAccept;
  final Future<void> Function()? onReject;

  const OrderAlertScreen({
    Key? key,
    // legacy
    this.orderId,
    this.orderReference,
    this.customerName,
    this.location,
    this.orderDetails,
    // new
    this.notificationTitle,
    this.notificationBody,
    this.notificationData,
    this.onAccept,
    this.onReject,
  }) : super(key: key);

  /// Convenience constructor for FCM payloads
  factory OrderAlertScreen.fromFcm({
    Key? key,
    required String notificationTitle,
    required String notificationBody,
    required Map<String, dynamic> data,
    Future<void> Function()? onAccept,
    Future<void> Function()? onReject,
  }) {
    return OrderAlertScreen(
      key: key,
      notificationTitle: notificationTitle,
      notificationBody: notificationBody,
      notificationData: NotificationData.fromMap(data),
      onAccept: onAccept,
      onReject: onReject,
    );
  }

  @override
  State<OrderAlertScreen> createState() => _OrderAlertScreenState();
}

class _OrderAlertScreenState extends State<OrderAlertScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late AnimationController _ringController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _ringAnimation;
  late Timer _countdownTimer;
  late AudioPlayer _audioPlayer;

  int _remainingSeconds = 30;
  bool _isAccepting = false;
  bool _isRejecting = false;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  // Helpers to read data from either legacy fields or FCM payload
  String get _displayOrderId =>
      widget.notificationData?.orderId ?? widget.orderId ?? '-';

  String get _displayType =>
      widget.notificationData?.type ?? '-';

  String get _displayEventType =>
      widget.notificationData?.eventType ?? '-';

  String get _displayActionRequiredFor =>
      widget.notificationData?.actionRequiredFor ?? '-';

  String get _displayKind =>
      widget.notificationData?.kind ?? '-';

  String get _displayOfferedTotal =>
      widget.notificationData?.offeredTotal != null &&
          widget.notificationData!.offeredTotal.isNotEmpty
          ? '${widget.notificationData!.offeredTotal} SAR'
          : '-';

  String get _displayTitle =>
      widget.notificationTitle ?? '🚨 طلب توصيل جديد!';

  String get _displayBody =>
      widget.notificationBody ??
          widget.orderDetails ??
          'لديك طلب جديد يحتاج منك الموافقة';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startCountdown();
    _playAlarmSound();
    _setupSystemUI();
  }

  void _setupSystemUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // ✅ Fixed: 30 seconds ring duration
    _ringController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _floatAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _ringAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeOut),
    );

    _pulseController.repeat(reverse: true);
    _floatController.repeat(reverse: true);
    // Ring expands once over 30 s then stops (mirrors the countdown)
    _ringController.forward();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _handleTimeout();
      }
    });
  }

  void _playAlarmSound() async {
    _audioPlayer = AudioPlayer();
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play(AssetSource('sounds/order_alert.mp3'));
    } catch (e) {
      debugPrint('❌ خطأ في تشغيل الصوت: $e');
      HapticFeedback.vibrate();
    }
  }

  void _stopAlarmSound() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
  }

  void _handleTimeout() {
    _stopAlarmSound();
    _countdownTimer.cancel();
    if (mounted) Navigator.of(context).pop();
    debugPrint('⏰ انتهى الوقت للطلب: $_displayOrderId');
  }

  Future<void> _handleAccept() async {
    if (_isAccepting || _isRejecting) return;
    setState(() => _isAccepting = true);
    HapticFeedback.mediumImpact();
    try {
      if (widget.onAccept != null) {
        await widget.onAccept!();
      }
      _stopAlarmSound();
      _countdownTimer.cancel();
      if (mounted) {
        _showSuccessSnackBar('✅ تم قبول الطلب بنجاح');
        await Future.delayed(const Duration(milliseconds: 600));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAccepting = false);
        _showErrorSnackBar('حدث خطأ أثناء قبول الطلب');
      }
    }
  }

  Future<void> _handleReject() async {
    if (_isAccepting || _isRejecting) return;
    setState(() => _isRejecting = true);
    HapticFeedback.mediumImpact();
    try {
      if (widget.onReject != null) {
        await widget.onReject!();
      }
      _stopAlarmSound();
      _countdownTimer.cancel();
      if (mounted) {
        _showErrorSnackBar('❌ تم رفض الطلب');
        await Future.delayed(const Duration(milliseconds: 600));
        Navigator.of(context).pop(false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isRejecting = false);
        _showErrorSnackBar('حدث خطأ أثناء رفض الطلب');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.error_rounded, color: AppTheme.white),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppTheme.white),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    _ringController.dispose();
    _countdownTimer.cancel();
    _stopAlarmSound();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async => false,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppTheme.getBackground(_isDark),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: AppTheme.getBackground(_isDark),
          body: Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              gradient: AppTheme.alertBackgroundGradient(_isDark),
            ),
            child: Stack(
              children: [
                _buildBackgroundEffects(size),
                _buildFloatingParticles(size),
                _buildDecorativeLines(size),
                _buildAnimatedRings(size),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 32),
                          _buildNotificationInfo(),   // ✅ NEW FCM data section
                          const SizedBox(height: 24),
                          _buildCountdownTimer(),
                          const SizedBox(height: 32),
                          _buildActionButtons(),       // ✅ Accept / Reject
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🎨 Background Effects (unchanged)
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildBackgroundEffects(Size size) {
    return Stack(
      children: [
        Positioned(
          top: -size.height * 0.1,
          right: -size.width * 0.3,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) => Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: size.width * 0.7,
                height: size.width * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primary.withOpacity(_isDark ? 0.25 : 0.15),
                      AppTheme.primary.withOpacity(0.08),
                      AppTheme.primary.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -size.height * 0.05,
          left: -size.width * 0.2,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) => Transform.scale(
              scale: 2 - _pulseAnimation.value,
              child: Container(
                width: size.width * 0.5,
                height: size.width * 0.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.secondary.withOpacity(_isDark ? 0.2 : 0.1),
                      AppTheme.secondary.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: size.height * 0.15,
          left: size.width * 0.1,
          child: AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) => Transform.translate(
              offset: Offset(_floatAnimation.value, _floatAnimation.value * 0.5),
              child: Container(
                width: size.width * 0.3,
                height: size.width * 0.3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.accent.withOpacity(_isDark ? 0.15 : 0.08),
                      AppTheme.accent.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingParticles(Size size) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Stack(
          children: List.generate(15, (index) {
            final random = math.Random(index);
            final x = random.nextDouble() * size.width;
            final y = random.nextDouble() * size.height;
            final particleSize = 3 + random.nextDouble() * 6;
            final delay = random.nextDouble();
            final color = index % 3 == 0
                ? AppTheme.accent
                : (index % 3 == 1 ? AppTheme.primary : AppTheme.secondary);
            return Positioned(
              left: x,
              top: y + (_floatAnimation.value * (index.isEven ? 1 : -1) * delay),
              child: Container(
                width: particleSize,
                height: particleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withOpacity(_isDark ? 0.6 : 0.4),
                      color.withOpacity(0),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildDecorativeLines(Size size) {
    return Positioned.fill(
      child: CustomPaint(painter: _LinesPainter(isDark: _isDark)),
    );
  }

  Widget _buildAnimatedRings(Size size) {
    return Positioned(
      top: size.height * 0.08,
      left: 0,
      right: 0,
      child: Center(
        child: AnimatedBuilder(
          animation: _ringAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: (1.5 - _ringAnimation.value).clamp(0.0, 1.0),
              child: Container(
                width: 150 * _ringAnimation.value,
                height: 150 * _ringAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primary.withOpacity(0.3),
                    width: 3,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 🔔 Header
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildHeader() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _floatAnimation,
          builder: (context, child) => Transform.translate(
            offset: Offset(0, _floatAnimation.value * 0.5),
            child: child,
          ),
          child: ScaleTransition(
            scale: _pulseAnimation,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.primary.withOpacity(0),
                        AppTheme.primary.withOpacity(_isDark ? 0.2 : 0.12),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(_isDark ? 0.5 : 0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_offer_rounded,
                    size: 50,
                    color: AppTheme.white,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppTheme.secondaryGradient,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.getCard(_isDark),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.secondary.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: AppTheme.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        ShaderMask(
          shaderCallback: (bounds) =>
              AppTheme.primaryGradient.createShader(bounds),
          child: Text(
            _displayTitle,
            style: TextStyle(
              fontSize: ResponsiveHelper.fontDisplay,
              fontWeight: FontWeight.bold,
              color: AppTheme.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(_isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
          ),
          child: Text(
            _displayBody,
            style: TextStyle(
              fontSize: ResponsiveHelper.fontLarge,
              color: AppTheme.getTextSecondary(_isDark),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // 📦 Notification Info (FCM data fields)
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildNotificationInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getCard(_isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.getBorder(_isDark)),
        boxShadow: AppTheme.softShadow(_isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    AppTheme.primary.withOpacity(0.2),
                    AppTheme.primary.withOpacity(0.1),
                  ]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.info_outline_rounded,
                    color: AppTheme.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'تفاصيل الإشعار',
                style: TextStyle(
                  fontSize: ResponsiveHelper.fontHeadingSmall,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getText(_isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Order ID
          _buildInfoRow(
            icon: Icons.tag_rounded,
            label: 'رقم الطلب',
            value: '#$_displayOrderId',
            color: AppTheme.primary,
          ),
          _buildDivider(),

          // Type
          _buildInfoRow(
            icon: Icons.category_rounded,
            label: 'النوع',
            value: _displayType,
            color: AppTheme.cyan,
          ),
          _buildDivider(),

          // Event Type
          _buildInfoRow(
            icon: Icons.event_rounded,
            label: 'نوع الحدث',
            value: _displayEventType,
            color: AppTheme.accent,
          ),
          _buildDivider(),

          // Kind
          _buildInfoRow(
            icon: Icons.label_rounded,
            label: 'التصنيف',
            value: _displayKind,
            color: AppTheme.info,
          ),
          _buildDivider(),

          // Action Required For
          _buildInfoRow(
            icon: Icons.person_pin_rounded,
            label: 'مطلوب من',
            value: _displayActionRequiredFor,
            color: AppTheme.secondary,
          ),
          _buildDivider(),

          // Offered Total  ← highlighted prominently
          _buildOfferedTotalRow(),
        ],
      ),
    );
  }

  /// Special highlighted row for the offered price
  Widget _buildOfferedTotalRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.secondary.withOpacity(_isDark ? 0.2 : 0.12),
            AppTheme.secondary.withOpacity(_isDark ? 0.1 : 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.secondary.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.secondary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.attach_money_rounded,
                color: AppTheme.secondary,
                size: ResponsiveHelper.iconLarge),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'السعر المعروض',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.fontMedium,
                    color: AppTheme.getTextSecondary(_isDark),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppTheme.secondaryGradient.createShader(bounds),
                  child: Text(
                    _displayOfferedTotal,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppTheme.getBorder(_isDark),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    int maxLines = 1,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(_isDark ? 0.2 : 0.12),
                color.withOpacity(_isDark ? 0.1 : 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Icon(icon, color: color, size: ResponsiveHelper.iconLarge),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: ResponsiveHelper.fontMedium,
                  color: AppTheme.getTextSecondary(_isDark),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: ResponsiveHelper.fontHeadingSmall,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getText(_isDark),
                ),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ⏱ Countdown Timer (unchanged logic, uses 30 s)
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildCountdownTimer() {
    final progress = _remainingSeconds / 30;
    final isUrgent = _remainingSeconds <= 10;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.getCard(_isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isUrgent
              ? AppTheme.error.withOpacity(0.3)
              : AppTheme.getBorder(_isDark),
        ),
        boxShadow: isUrgent
            ? [
          BoxShadow(
            color: AppTheme.error.withOpacity(_isDark ? 0.3 : 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ]
            : AppTheme.softShadow(_isDark),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.timer_rounded,
                color: isUrgent ? AppTheme.error : AppTheme.primary,
                size: ResponsiveHelper.iconMedium,
              ),
              const SizedBox(width: 8),
              Text(
                'الوقت المتبقي',
                style: TextStyle(
                  fontSize: ResponsiveHelper.fontLarge,
                  color: AppTheme.getTextSecondary(_isDark),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 130,
                height: 130,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 10,
                  backgroundColor: AppTheme.getSurface(_isDark),
                  valueColor: AlwaysStoppedAnimation(
                    isUrgent ? AppTheme.error : AppTheme.secondary,
                  ),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.getSurface(_isDark),
                  border: Border.all(
                    color: (isUrgent ? AppTheme.error : AppTheme.secondary)
                        .withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) => Transform.scale(
                        scale: isUrgent ? _pulseAnimation.value : 1.0,
                        child: Text(
                          '$_remainingSeconds',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: isUrgent
                                ? AppTheme.error
                                : AppTheme.getText(_isDark),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      'ثانية',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.fontMedium,
                        color: AppTheme.getTextSecondary(_isDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isUrgent) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(_isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.error.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_rounded,
                      color: AppTheme.error,
                      size: ResponsiveHelper.iconSmall),
                  const SizedBox(width: 8),
                  Text(
                    'الوقت على وشك الانتهاء!',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.fontMedium,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ✅ Accept / ❌ Reject buttons
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Accept
        SizedBox(
          width: double.infinity,
          child: _ActionButton(
            onPressed: _isAccepting || _isRejecting ? null : _handleAccept,
            label: 'قبول العرض',
            icon: Icons.check_circle_rounded,
            gradient: AppTheme.secondaryGradient,
            isLoading: _isAccepting,
            isDark: _isDark,
          ),
        ),
        const SizedBox(height: 14),

        // Reject
        SizedBox(
          width: double.infinity,
          child: _ActionButton(
            onPressed: _isAccepting || _isRejecting ? null : _handleReject,
            label: 'رفض العرض',
            icon: Icons.cancel_rounded,
            gradient: AppTheme.errorGradient,
            isLoading: _isRejecting,
            isDark: _isDark,
          ),
        ),
        const SizedBox(height: 14),

        // Dismiss alert only (no action)
        TextButton(
          onPressed: () {
            _stopAlarmSound();
            _countdownTimer.cancel();
            Navigator.of(context).pop();
          },
          child: Text(
            'إغلاق التنبيه فقط',
            style: TextStyle(
              fontSize: ResponsiveHelper.fontMedium,
              color: AppTheme.getTextSecondary(_isDark),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 🎨 Lines Painter
// ═══════════════════════════════════════════════════════════════════════════
class _LinesPainter extends CustomPainter {
  final bool isDark;
  _LinesPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary.withOpacity(isDark ? 0.03 : 0.02)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (double i = -size.height; i < size.width + size.height; i += 50) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ═══════════════════════════════════════════════════════════════════════════
// 🔘 Action Button (unchanged)
// ═══════════════════════════════════════════════════════════════════════════
class _ActionButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData icon;
  final LinearGradient gradient;
  final bool isLoading;
  final bool isDark;

  const _ActionButton({
    required this.onPressed,
    required this.label,
    required this.icon,
    required this.gradient,
    this.isLoading = false,
    required this.isDark,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null
          ? (_) {
        _controller.forward();
        setState(() => _isPressed = true);
      }
          : null,
      onTapUp: widget.onPressed != null
          ? (_) {
        _controller.reverse();
        setState(() => _isPressed = false);
        widget.onPressed!();
      }
          : null,
      onTapCancel: () {
        _controller.reverse();
        setState(() => _isPressed = false);
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: widget.onPressed != null
                ? widget.gradient
                : LinearGradient(colors: [
              Colors.grey.withOpacity(0.3),
              Colors.grey.withOpacity(0.2),
            ]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: widget.onPressed != null
                ? [
              BoxShadow(
                color: widget.gradient.colors.first
                    .withOpacity(_isPressed ? 0.3 : 0.5),
                blurRadius: _isPressed ? 15 : 25,
                offset: Offset(0, _isPressed ? 5 : 10),
              ),
            ]
                : [],
          ),
          child: widget.isLoading
              ? const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor:
                AlwaysStoppedAnimation(AppTheme.white),
              ),
            ),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon,
                  color: AppTheme.white,
                  size: ResponsiveHelper.iconLarge),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: ResponsiveHelper.fontHeadingSmall,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}