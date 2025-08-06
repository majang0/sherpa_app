// lib/shared/widgets/components/atoms/sherpa_alert_2025.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors_2025.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/glass_neu_style_system.dart';
import '../../../../core/animation/micro_interactions.dart';

/// 2025 디자인 트렌드를 반영한 현대적 알림 대화상자 컴포넌트
/// 다양한 상황과 스타일을 지원하는 고급 알림 시스템
class SherpaAlert2025 {
  // ==================== 기본 알림 대화상자 ====================

  /// 기본 알림 표시
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    String? content,
    Widget? contentWidget,
    List<SherpaAlertAction>? actions,
    SherpaAlertType type = SherpaAlertType.info,
    SherpaAlertVariant2025 variant = SherpaAlertVariant2025.glass,
    Widget? icon,
    bool barrierDismissible = true,
    bool enableHapticFeedback = true,
    String? category,
    Color? customColor,
    EdgeInsetsGeometry? contentPadding,
    EdgeInsetsGeometry? actionsPadding,
    MainAxisAlignment? actionsAlignment,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => _SherpaAlertDialog(
        title: title,
        content: content,
        contentWidget: contentWidget,
        actions: actions,
        type: type,
        variant: variant,
        icon: icon,
        enableHapticFeedback: enableHapticFeedback,
        category: category,
        customColor: customColor,
        contentPadding: contentPadding,
        actionsPadding: actionsPadding,
        actionsAlignment: actionsAlignment,
      ),
    );
  }

  /// 확인 대화상자
  static Future<bool?> confirm(
    BuildContext context, {
    required String title,
    String? content,
    String confirmText = '확인',
    String cancelText = '취소',
    SherpaAlertType type = SherpaAlertType.warning,
    bool isDestructive = false,
    String? category,
  }) {
    return show<bool>(
      context,
      title: title,
      content: content,
      type: type,
      category: category,
      icon: _getDefaultIcon(type),
      actions: [
        SherpaAlertAction(
          text: cancelText,
          style: SherpaAlertActionStyle.outlined,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        SherpaAlertAction(
          text: confirmText,
          style: isDestructive 
              ? SherpaAlertActionStyle.destructive 
              : SherpaAlertActionStyle.filled,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }

  /// 성공 알림
  static Future<void> success(
    BuildContext context, {
    required String title,
    String? content,
    String buttonText = '확인',
  }) {
    return show(
      context,
      title: title,
      content: content,
      type: SherpaAlertType.success,
      icon: const Icon(Icons.check_circle, size: 48),
      actions: [
        SherpaAlertAction(
          text: buttonText,
          style: SherpaAlertActionStyle.filled,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  /// 오류 알림
  static Future<void> error(
    BuildContext context, {
    required String title,
    String? content,
    String buttonText = '확인',
    String? retryText,
    VoidCallback? onRetry,
  }) {
    final actions = <SherpaAlertAction>[
      if (retryText != null && onRetry != null)
        SherpaAlertAction(
          text: retryText,
          style: SherpaAlertActionStyle.outlined,
          onPressed: () {
            Navigator.of(context).pop();
            onRetry();
          },
        ),
      SherpaAlertAction(
        text: buttonText,
        style: SherpaAlertActionStyle.filled,
        onPressed: () => Navigator.of(context).pop(),
      ),
    ];

    return show(
      context,
      title: title,
      content: content,
      type: SherpaAlertType.error,
      icon: const Icon(Icons.error, size: 48),
      actions: actions,
    );
  }

  /// 경고 알림
  static Future<bool?> warning(
    BuildContext context, {
    required String title,
    String? content,
    String confirmText = '계속',
    String cancelText = '취소',
  }) {
    return show<bool>(
      context,
      title: title,
      content: content,
      type: SherpaAlertType.warning,
      icon: const Icon(Icons.warning, size: 48),
      actions: [
        SherpaAlertAction(
          text: cancelText,
          style: SherpaAlertActionStyle.outlined,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        SherpaAlertAction(
          text: confirmText,
          style: SherpaAlertActionStyle.filled,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }

  /// 입력 대화상자
  static Future<String?> input(
    BuildContext context, {
    required String title,
    String? content,
    String? placeholder,
    String? initialValue,
    String confirmText = '확인',
    String cancelText = '취소',
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    String? category,
  }) {
    final controller = TextEditingController(text: initialValue);
    
    return show<String>(
      context,
      title: title,
      content: content,
      category: category,
      contentWidget: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          autofocus: true,
          decoration: InputDecoration(
            hintText: placeholder,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: BorderSide(color: AppColors2025.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              borderSide: BorderSide(
                color: category != null
                    ? AppColors2025.getCategoryColor2025(category)
                    : AppColors2025.primary,
                width: 2,
              ),
            ),
          ),
        ),
      ),
      actions: [
        SherpaAlertAction(
          text: cancelText,
          style: SherpaAlertActionStyle.outlined,
          onPressed: () => Navigator.of(context).pop(),
        ),
        SherpaAlertAction(
          text: confirmText,
          style: SherpaAlertActionStyle.filled,
          onPressed: () => Navigator.of(context).pop(controller.text),
        ),
      ],
    );
  }

  /// 선택 대화상자
  static Future<T?> select<T>(
    BuildContext context, {
    required String title,
    String? content,
    required List<SherpaSelectOption<T>> options,
    String? cancelText,
    String? category,
  }) {
    final actions = <SherpaAlertAction>[];
    
    if (cancelText != null) {
      actions.add(
        SherpaAlertAction(
          text: cancelText,
          style: SherpaAlertActionStyle.outlined,
          onPressed: () => Navigator.of(context).pop(),
        ),
      );
    }

    return show<T>(
      context,
      title: title,
      content: content,
      category: category,
      contentWidget: Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((option) {
          return InkWell(
            onTap: () => Navigator.of(context).pop(option.value),
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                border: Border.all(
                  color: AppColors2025.border,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  if (option.icon != null) ...[ 
                    option.icon!,
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.title,
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors2025.textPrimary,
                          ),
                        ),
                        if (option.subtitle != null) ...[ 
                          const SizedBox(height: 4),
                          Text(
                            option.subtitle!,
                            style: GoogleFonts.notoSans(
                              fontSize: 14,
                              color: AppColors2025.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
      actions: actions,
    );
  }

  /// 로딩 대화상자
  static Future<T?> loading<T>(
    BuildContext context, {
    required String title,
    String? content,
    bool barrierDismissible = false,
  }) {
    return show<T>(
      context,
      title: title,
      content: content,
      barrierDismissible: barrierDismissible,
      contentWidget: const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  // ==================== 헬퍼 메서드들 ====================

  static Widget? _getDefaultIcon(SherpaAlertType type) {
    switch (type) {
      case SherpaAlertType.success:
        return const Icon(Icons.check_circle, size: 48);
      case SherpaAlertType.error:
        return const Icon(Icons.error, size: 48);
      case SherpaAlertType.warning:
        return const Icon(Icons.warning, size: 48);
      case SherpaAlertType.info:
        return const Icon(Icons.info, size: 48);
    }
  }
}

// ==================== 알림 대화상자 위젯 ====================

class _SherpaAlertDialog extends StatefulWidget {
  final String title;
  final String? content;
  final Widget? contentWidget;
  final List<SherpaAlertAction>? actions;
  final SherpaAlertType type;
  final SherpaAlertVariant2025 variant;
  final Widget? icon;
  final bool enableHapticFeedback;
  final String? category;
  final Color? customColor;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? actionsPadding;
  final MainAxisAlignment? actionsAlignment;

  const _SherpaAlertDialog({
    required this.title,
    this.content,
    this.contentWidget,
    this.actions,
    required this.type,
    required this.variant,
    this.icon,
    required this.enableHapticFeedback,
    this.category,
    this.customColor,
    this.contentPadding,
    this.actionsPadding,
    this.actionsAlignment,
  });

  @override
  State<_SherpaAlertDialog> createState() => _SherpaAlertDialogState();
}

class _SherpaAlertDialogState extends State<_SherpaAlertDialog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: MicroInteractions.normal,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: MicroInteractions.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: MicroInteractions.easeOutQuart,
    ));

    _animationController.forward();

    // 햅틱 피드백
    if (widget.enableHapticFeedback) {
      switch (widget.type) {
        case SherpaAlertType.success:
          HapticFeedback.mediumImpact();
          break;
        case SherpaAlertType.error:
          HapticFeedback.heavyImpact();
          break;
        case SherpaAlertType.warning:
          HapticFeedback.lightImpact();
          break;
        default:
          HapticFeedback.selectionClick();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getAlertConfiguration();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: AlertDialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              contentPadding: EdgeInsets.zero,
              content: Container(
                constraints: const BoxConstraints(
                  maxWidth: 400,
                  minWidth: 280,
                ),
                decoration: _getDecoration(config),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 헤더 영역
                    Padding(
                      padding: widget.contentPadding ?? 
                               const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Column(
                        children: [
                          if (widget.icon != null) ...[ 
                            IconTheme(
                              data: IconThemeData(
                                color: config.iconColor,
                                size: 48,
                              ),
                              child: widget.icon!,
                            ),
                            const SizedBox(height: 16),
                          ],
                          Text(
                            widget.title,
                            style: GoogleFonts.notoSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors2025.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (widget.content != null) ...[ 
                            const SizedBox(height: 12),
                            Text(
                              widget.content!,
                              style: GoogleFonts.notoSans(
                                fontSize: 16,
                                color: AppColors2025.textSecondary,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          if (widget.contentWidget != null) 
                            widget.contentWidget!,
                        ],
                      ),
                    ),
                    
                    // 액션 영역
                    if (widget.actions != null && widget.actions!.isNotEmpty)
                      Container(
                        padding: widget.actionsPadding ?? 
                                 const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: _buildActions(config),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActions(AlertConfiguration config) {
    if (widget.actions!.length == 1) {
      return SizedBox(
        width: double.infinity,
        child: _buildActionButton(widget.actions!.first, config),
      );
    }

    if (widget.actions!.length == 2) {
      return Row(
        children: [
          Expanded(
            child: _buildActionButton(widget.actions!.first, config),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(widget.actions!.last, config),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: widget.actions!.map((action) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SizedBox(
            width: double.infinity,
            child: _buildActionButton(action, config),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButton(SherpaAlertAction action, AlertConfiguration config) {
    return ElevatedButton(
      onPressed: action.onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _getActionBackgroundColor(action, config),
        foregroundColor: _getActionTextColor(action, config),
        elevation: action.style == SherpaAlertActionStyle.filled ? 2 : 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          side: action.style == SherpaAlertActionStyle.outlined
              ? BorderSide(color: config.primaryColor, width: 1.5)
              : BorderSide.none,
        ),
      ),
      child: Text(
        action.text,
        style: GoogleFonts.notoSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getActionBackgroundColor(SherpaAlertAction action, AlertConfiguration config) {
    switch (action.style) {
      case SherpaAlertActionStyle.filled:
        return config.primaryColor;
      case SherpaAlertActionStyle.outlined:
        return Colors.transparent;
      case SherpaAlertActionStyle.text:
        return Colors.transparent;
      case SherpaAlertActionStyle.destructive:
        return AppColors2025.error;
    }
  }

  Color _getActionTextColor(SherpaAlertAction action, AlertConfiguration config) {
    switch (action.style) {
      case SherpaAlertActionStyle.filled:
        return AppColors2025.textOnPrimary;
      case SherpaAlertActionStyle.outlined:
        return config.primaryColor;
      case SherpaAlertActionStyle.text:
        return AppColors2025.textSecondary;
      case SherpaAlertActionStyle.destructive:
        return AppColors2025.textOnPrimary;
    }
  }

  AlertConfiguration _getAlertConfiguration() {
    final primaryColor = widget.customColor ??
        (widget.category != null
            ? AppColors2025.getCategoryColor2025(widget.category!)
            : _getTypeColor());

    return AlertConfiguration(
      primaryColor: primaryColor,
      iconColor: primaryColor,
    );
  }

  Color _getTypeColor() {
    switch (widget.type) {
      case SherpaAlertType.success:
        return AppColors2025.success;
      case SherpaAlertType.error:
        return AppColors2025.error;
      case SherpaAlertType.warning:
        return AppColors2025.warning;
      case SherpaAlertType.info:
        return AppColors2025.info;
    }
  }

  BoxDecoration _getDecoration(AlertConfiguration config) {
    switch (widget.variant) {
      case SherpaAlertVariant2025.glass:
        return GlassNeuStyle.glassMorphism(
          elevation: GlassNeuElevation.high,
          color: AppColors2025.surface,
          borderRadius: AppSizes.radiusXL,
          opacity: 0.95,
        );

      case SherpaAlertVariant2025.neu:
        return GlassNeuStyle.softNeumorphism(
          baseColor: AppColors2025.surface,
          borderRadius: AppSizes.radiusXL,
          intensity: 0.05,
        );

      case SherpaAlertVariant2025.floating:
        return GlassNeuStyle.floatingGlass(
          color: AppColors2025.surface,
          borderRadius: AppSizes.radiusXL,
          elevation: 24,
        );

      case SherpaAlertVariant2025.solid:
        return BoxDecoration(
          color: AppColors2025.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          boxShadow: [
            BoxShadow(
              color: AppColors2025.shadowDark,
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

// ==================== 모델 클래스들 ====================

class SherpaAlertAction {
  final String text;
  final VoidCallback? onPressed;
  final SherpaAlertActionStyle style;

  const SherpaAlertAction({
    required this.text,
    this.onPressed,
    this.style = SherpaAlertActionStyle.filled,
  });
}

class SherpaSelectOption<T> {
  final T value;
  final String title;
  final String? subtitle;
  final Widget? icon;

  const SherpaSelectOption({
    required this.value,
    required this.title,
    this.subtitle,
    this.icon,
  });
}

// ==================== 열거형 정의 ====================

enum SherpaAlertType {
  success,      // 성공 알림
  error,        // 오류 알림
  warning,      // 경고 알림
  info,         // 정보 알림
}

enum SherpaAlertVariant2025 {
  glass,        // 글래스모피즘
  neu,          // 뉴모피즘
  floating,     // 플로팅
  solid,        // 솔리드
}

enum SherpaAlertActionStyle {
  filled,       // 채워진 버튼
  outlined,     // 아웃라인 버튼
  text,         // 텍스트 버튼
  destructive,  // 위험 버튼
}

// ==================== 도우미 클래스들 ====================

class AlertConfiguration {
  final Color primaryColor;
  final Color iconColor;

  const AlertConfiguration({
    required this.primaryColor,
    required this.iconColor,
  });
}