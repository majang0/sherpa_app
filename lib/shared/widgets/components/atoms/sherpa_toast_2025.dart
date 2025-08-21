// lib/shared/widgets/components/atoms/sherpa_toast_2025.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors_2025.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/glass_neu_style_system.dart';
import '../../../../core/animation/micro_interactions.dart';

/// 2025 디자인 트렌드를 반영한 현대적 토스트 알림 컴포넌트
/// 다양한 상황과 스타일을 지원하는 고급 알림 시스템
class SherpaToast2025 {
  static OverlayEntry? _currentToast;
  
  // ==================== 기본 토스트 표시 메서드 ====================

  /// 기본 토스트 표시
  static void show(
    BuildContext context, {
    required String message,
    SherpaToastType type = SherpaToastType.info,
    SherpaToastVariant2025 variant = SherpaToastVariant2025.glass,
    SherpaToastPosition position = SherpaToastPosition.bottom,
    Duration duration = const Duration(seconds: 3),
    Widget? icon,
    String? action,
    VoidCallback? onActionPressed,
    bool dismissible = true,
    bool enableHapticFeedback = true,
    String? category,
  }) {
    _showToast(
      context,
      _ToastWidget(
        message: message,
        type: type,
        variant: variant,
        position: position,
        duration: duration,
        icon: icon,
        action: action,
        onActionPressed: onActionPressed,
        dismissible: dismissible,
        enableHapticFeedback: enableHapticFeedback,
        category: category,
      ),
    );
  }

  /// 성공 토스트
  static void success(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    String? action,
    VoidCallback? onActionPressed,
    SherpaToastPosition position = SherpaToastPosition.bottom,
  }) {
    show(
      context,
      message: message,
      type: SherpaToastType.success,
      duration: duration,
      action: action,
      onActionPressed: onActionPressed,
      position: position,
      icon: const Icon(Icons.check_circle, size: 20),
    );
  }

  /// 오류 토스트
  static void error(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
    String? action,
    VoidCallback? onActionPressed,
    SherpaToastPosition position = SherpaToastPosition.bottom,
  }) {
    show(
      context,
      message: message,
      type: SherpaToastType.error,
      duration: duration,
      action: action,
      onActionPressed: onActionPressed,
      position: position,
      icon: const Icon(Icons.error, size: 20),
    );
  }

  /// 경고 토스트
  static void warning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    String? action,
    VoidCallback? onActionPressed,
    SherpaToastPosition position = SherpaToastPosition.bottom,
  }) {
    show(
      context,
      message: message,
      type: SherpaToastType.warning,
      duration: duration,
      action: action,
      onActionPressed: onActionPressed,
      position: position,
      icon: const Icon(Icons.warning, size: 20),
    );
  }

  /// 정보 토스트
  static void info(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    String? action,
    VoidCallback? onActionPressed,
    SherpaToastPosition position = SherpaToastPosition.bottom,
  }) {
    show(
      context,
      message: message,
      type: SherpaToastType.info,
      duration: duration,
      action: action,
      onActionPressed: onActionPressed,
      position: position,
      icon: const Icon(Icons.info, size: 20),
    );
  }

  /// 로딩 토스트 (지속형)
  static void loading(
    BuildContext context, {
    required String message,
    SherpaToastPosition position = SherpaToastPosition.center,
  }) {
    show(
      context,
      message: message,
      type: SherpaToastType.loading,
      variant: SherpaToastVariant2025.floating,
      position: position,
      duration: const Duration(days: 1), // 수동으로 제거할 때까지
      dismissible: false,
      icon: const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(AppColors2025.primary),
        ),
      ),
    );
  }

  /// 사용자 정의 토스트
  static void custom(
    BuildContext context, {
    required Widget child,
    SherpaToastPosition position = SherpaToastPosition.bottom,
    Duration duration = const Duration(seconds: 3),
    bool dismissible = true,
  }) {
    _showToast(
      context,
      child,
      position: position,
      duration: duration,
      dismissible: dismissible,
    );
  }

  /// 현재 토스트 제거
  static void dismiss() {
    _currentToast?.remove();
    _currentToast = null;
  }

  // ==================== 내부 메서드들 ====================

  static void _showToast(
    BuildContext context,
    Widget child, {
    SherpaToastPosition position = SherpaToastPosition.bottom,
    Duration duration = const Duration(seconds: 3),
    bool dismissible = true,
  }) {
    // 기존 토스트 제거
    dismiss();

    final overlay = Overlay.of(context);
    final mediaQuery = MediaQuery.of(context);

    _currentToast = OverlayEntry(
      builder: (context) => _ToastOverlay(
        child: child,
        position: position,
        duration: duration,
        dismissible: dismissible,
        mediaQuery: mediaQuery,
        onDismiss: dismiss,
      ),
    );

    overlay.insert(_currentToast!);
  }
}

// ==================== 토스트 오버레이 위젯 ====================

class _ToastOverlay extends StatefulWidget {
  final Widget child;
  final SherpaToastPosition position;
  final Duration duration;
  final bool dismissible;
  final MediaQueryData mediaQuery;
  final VoidCallback onDismiss;

  const _ToastOverlay({
    required this.child,
    required this.position,
    required this.duration,
    required this.dismissible,
    required this.mediaQuery,
    required this.onDismiss,
  });

  @override
  State<_ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<_ToastOverlay>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: MicroInteractions.normal,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: MicroInteractions.easeOutQuart,
    ));

    _slideAnimation = Tween<Offset>(
      begin: _getInitialOffset(),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: MicroInteractions.easeOutQuart,
    ));

    _animationController.forward();

    // 자동 제거 타이머
    if (widget.duration != const Duration(days: 1)) {
      Future.delayed(widget.duration, () {
        if (mounted) {
          _dismiss();
        }
      });
    }
  }

  Offset _getInitialOffset() {
    switch (widget.position) {
      case SherpaToastPosition.top:
        return const Offset(0, -1);
      case SherpaToastPosition.bottom:
        return const Offset(0, 1);
      case SherpaToastPosition.center:
        return const Offset(0, 0.5);
    }
  }

  void _dismiss() {
    _animationController.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: _getTop(),
      bottom: _getBottom(),
      left: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: widget.dismissible
                  ? GestureDetector(
                      onTap: _dismiss,
                      child: widget.child,
                    )
                  : widget.child,
            ),
          );
        },
      ),
    );
  }

  double? _getTop() {
    switch (widget.position) {
      case SherpaToastPosition.top:
        return widget.mediaQuery.padding.top + 16;
      case SherpaToastPosition.center:
        return null;
      case SherpaToastPosition.bottom:
        return null;
    }
  }

  double? _getBottom() {
    switch (widget.position) {
      case SherpaToastPosition.top:
        return null;
      case SherpaToastPosition.center:
        return null;
      case SherpaToastPosition.bottom:
        return widget.mediaQuery.padding.bottom + 16;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

// ==================== 토스트 위젯 ====================

class _ToastWidget extends StatelessWidget {
  final String message;
  final SherpaToastType type;
  final SherpaToastVariant2025 variant;
  final SherpaToastPosition position;
  final Duration duration;
  final Widget? icon;
  final String? action;
  final VoidCallback? onActionPressed;
  final bool dismissible;
  final bool enableHapticFeedback;
  final String? category;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.variant,
    required this.position,
    required this.duration,
    this.icon,
    this.action,
    this.onActionPressed,
    required this.dismissible,
    required this.enableHapticFeedback,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getToastConfiguration();

    // 햅틱 피드백
    if (enableHapticFeedback) {
      switch (type) {
        case SherpaToastType.success:
          HapticFeedback.mediumImpact();
          break;
        case SherpaToastType.error:
          HapticFeedback.heavyImpact();
          break;
        case SherpaToastType.warning:
          HapticFeedback.lightImpact();
          break;
        default:
          HapticFeedback.selectionClick();
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: position == SherpaToastPosition.center ? 32 : 0,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: _getDecoration(config),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[ 
            IconTheme(
              data: IconThemeData(
                color: config.iconColor,
                size: 20,
              ),
              child: icon!,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: config.textColor,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (action != null && onActionPressed != null) ...[ 
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () {
                onActionPressed?.call();
                SherpaToast2025.dismiss();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: config.actionColor,
                  borderRadius: BorderRadius.circular(AppSizes.radiusS),
                ),
                child: Text(
                  action!,
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: config.actionTextColor,
                  ),
                ),
              ),
            ),
          ],
          if (dismissible) ...[ 
            const SizedBox(width: 8),
            GestureDetector(
              onTap: SherpaToast2025.dismiss,
              child: Container(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: config.textColor.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  ToastConfiguration _getToastConfiguration() {
    final baseColor = category != null
        ? AppColors2025.getCategoryColor2025(category!)
        : _getTypeColor();

    return ToastConfiguration(
      backgroundColor: baseColor,
      textColor: _getTextColor(baseColor),
      iconColor: _getIconColor(baseColor),
      actionColor: _getActionColor(baseColor),
      actionTextColor: _getActionTextColor(baseColor),
    );
  }

  Color _getTypeColor() {
    switch (type) {
      case SherpaToastType.success:
        return AppColors2025.success;
      case SherpaToastType.error:
        return AppColors2025.error;
      case SherpaToastType.warning:
        return AppColors2025.warning;
      case SherpaToastType.info:
        return AppColors2025.info;
      case SherpaToastType.loading:
        return AppColors2025.primary;
    }
  }

  Color _getTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 
        ? AppColors2025.textPrimary 
        : AppColors2025.textOnPrimary;
  }

  Color _getIconColor(Color backgroundColor) {
    return _getTextColor(backgroundColor);
  }

  Color _getActionColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 
        ? backgroundColor.withOpacity(0.2)
        : AppColors2025.surface.withOpacity(0.2);
  }

  Color _getActionTextColor(Color backgroundColor) {
    return _getTextColor(backgroundColor);
  }

  BoxDecoration _getDecoration(ToastConfiguration config) {
    switch (variant) {
      case SherpaToastVariant2025.glass:
        return GlassNeuStyle.glassMorphism(
          elevation: GlassNeuElevation.medium,
          color: config.backgroundColor,
          borderRadius: AppSizes.radiusM,
          opacity: 0.95,
        );

      case SherpaToastVariant2025.neu:
        return GlassNeuStyle.softNeumorphism(
          baseColor: config.backgroundColor,
          borderRadius: AppSizes.radiusM,
          intensity: 0.1,
        );

      case SherpaToastVariant2025.floating:
        return GlassNeuStyle.floatingGlass(
          color: config.backgroundColor,
          borderRadius: AppSizes.radiusL,
          elevation: 16,
        );

      case SherpaToastVariant2025.solid:
        return BoxDecoration(
          color: config.backgroundColor,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          boxShadow: [
            BoxShadow(
              color: AppColors2025.shadowLight,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        );

      case SherpaToastVariant2025.outlined:
        return BoxDecoration(
          color: AppColors2025.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          border: Border.all(
            color: config.backgroundColor,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors2025.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        );
    }
  }
}

// ==================== 열거형 정의 ====================

enum SherpaToastType {
  success,      // 성공 알림
  error,        // 오류 알림
  warning,      // 경고 알림
  info,         // 정보 알림
  loading,      // 로딩 알림
}

enum SherpaToastVariant2025 {
  glass,        // 글래스모피즘
  neu,          // 뉴모피즘
  floating,     // 플로팅
  solid,        // 솔리드
  outlined,     // 아웃라인
}

enum SherpaToastPosition {
  top,          // 상단
  center,       // 중앙
  bottom,       // 하단
}

// ==================== 도우미 클래스들 ====================

class ToastConfiguration {
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final Color actionColor;
  final Color actionTextColor;

  const ToastConfiguration({
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    required this.actionColor,
    required this.actionTextColor,
  });
}