// lib/shared/widgets/components/atoms/sherpa_modal_2025.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors_2025.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/glass_neu_style_system.dart';
import '../../../../core/animation/micro_interactions.dart';

/// 2025 디자인 트렌드를 반영한 현대적 모달 컴포넌트
/// 다양한 모달과 바텀시트 스타일을 지원하는 고급 오버레이 시스템
class SherpaModal2025 {
  // ==================== 기본 모달 메서드들 ====================

  /// 기본 모달 표시
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    SherpaModalVariant2025 variant = SherpaModalVariant2025.glass,
    bool barrierDismissible = true,
    bool enableDrag = false,
    bool showHandle = false,
    double? maxHeight,
    double? maxWidth,
    EdgeInsetsGeometry? padding,
    String? category,
    Color? customColor,
    bool enableHapticFeedback = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      barrierColor: AppColors2025.shadowDark.withOpacity(0.5),
      backgroundColor: Colors.transparent,
      enableDrag: enableDrag,
      isDismissible: barrierDismissible,
      builder: (context) => _SherpaModalContent(
        child: child,
        variant: variant,
        showHandle: showHandle,
        maxHeight: maxHeight,
        maxWidth: maxWidth,
        padding: padding,
        category: category,
        customColor: customColor,
        enableHapticFeedback: enableHapticFeedback,
      ),
    );
  }

  /// 바텀시트 모달
  static Future<T?> bottomSheet<T>(
    BuildContext context, {
    required Widget child,
    String? title,
    List<Widget>? actions,
    bool showHandle = true,
    bool enableDrag = true,
    double? maxHeight,
    EdgeInsetsGeometry? padding,
    String? category,
  }) {
    return show<T>(
      context,
      variant: SherpaModalVariant2025.bottomSheet,
      enableDrag: enableDrag,
      showHandle: showHandle,
      maxHeight: maxHeight,
      padding: padding,
      category: category,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || actions != null)
            _ModalHeader(
              title: title,
              actions: actions,
            ),
          Flexible(child: child),
        ],
      ),
    );
  }

  /// 중앙 모달
  static Future<T?> center<T>(
    BuildContext context, {
    required Widget child,
    String? title,
    List<Widget>? actions,
    double? maxWidth,
    EdgeInsetsGeometry? padding,
    String? category,
  }) {
    return showDialog<T>(
      context: context,
      barrierColor: AppColors2025.shadowDark.withOpacity(0.5),
      builder: (context) => _SherpaCenterModal(
        child: child,
        title: title,
        actions: actions,
        maxWidth: maxWidth,
        padding: padding,
        category: category,
      ),
    );
  }

  /// 사이드 모달 (드로어 스타일)
  static Future<T?> side<T>(
    BuildContext context, {
    required Widget child,
    String? title,
    List<Widget>? actions,
    SherpaModalSide side = SherpaModalSide.right,
    double? width,
    EdgeInsetsGeometry? padding,
    String? category,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Side Modal',
      barrierColor: AppColors2025.shadowDark.withOpacity(0.5),
      transitionDuration: MicroInteractions.normal,
      pageBuilder: (context, animation, secondaryAnimation) {
        return _SherpaSideModal(
          child: child,
          title: title,
          actions: actions,
          side: side,
          width: width,
          padding: padding,
          category: category,
          animation: animation,
        );
      },
    );
  }

  /// 전체화면 모달
  static Future<T?> fullscreen<T>(
    BuildContext context, {
    required Widget child,
    String? title,
    List<Widget>? actions,
    Widget? leading,
    EdgeInsetsGeometry? padding,
    String? category,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder<T>(
        fullscreenDialog: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return _SherpaFullscreenModal(
            child: child,
            title: title,
            actions: actions,
            leading: leading,
            padding: padding,
            category: category,
            animation: animation,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(0, 1), end: Offset.zero).chain(
                CurveTween(curve: MicroInteractions.easeOutQuart),
              ),
            ),
            child: child,
          );
        },
      ),
    );
  }

  /// 메뉴 모달
  static Future<T?> menu<T>(
    BuildContext context, {
    required List<SherpaMenuOption<T>> options,
    String? title,
    Widget? header,
    bool showHandle = true,
    String? category,
  }) {
    return bottomSheet<T>(
      context,
      title: title,
      showHandle: showHandle,
      category: category,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (header != null) ...[
            header,
            const Divider(),
          ],
          ...options.map((option) => _MenuOptionTile(option: option)),
        ],
      ),
    );
  }

  /// 확인 모달 (바텀시트 스타일)
  static Future<bool?> confirm<T>(
    BuildContext context, {
    required String title,
    String? content,
    Widget? contentWidget,
    Widget? icon,
    String confirmText = '확인',
    String cancelText = '취소',
    bool isDestructive = false,
    String? category,
  }) {
    return bottomSheet<bool>(
      context,
      category: category,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon,
              const SizedBox(height: 16),
            ],
            Text(
              title,
              style: GoogleFonts.notoSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors2025.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (content != null) ...[
              const SizedBox(height: 12),
              Text(
                content,
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  color: AppColors2025.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (contentWidget != null) ...[
              const SizedBox(height: 16),
              contentWidget,
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                    ),
                    child: Text(
                      cancelText,
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDestructive 
                          ? AppColors2025.error 
                          : (category != null
                              ? AppColors2025.getCategoryColor2025(category)
                              : AppColors2025.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                    ),
                    child: Text(
                      confirmText,
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors2025.textOnPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 모달 콘텐츠 위젯들 ====================

class _SherpaModalContent extends StatefulWidget {
  final Widget child;
  final SherpaModalVariant2025 variant;
  final bool showHandle;
  final double? maxHeight;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final String? category;
  final Color? customColor;
  final bool enableHapticFeedback;

  const _SherpaModalContent({
    required this.child,
    required this.variant,
    required this.showHandle,
    this.maxHeight,
    this.maxWidth,
    this.padding,
    this.category,
    this.customColor,
    required this.enableHapticFeedback,
  });

  @override
  State<_SherpaModalContent> createState() => _SherpaModalContentState();
}

class _SherpaModalContentState extends State<_SherpaModalContent>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: MicroInteractions.normal,
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: MicroInteractions.easeOutQuart,
    ));

    _animationController.forward();

    if (widget.enableHapticFeedback) {
      HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final config = _getModalConfiguration();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * mediaQuery.size.height * 0.3),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: widget.maxHeight ?? mediaQuery.size.height * 0.9,
              maxWidth: widget.maxWidth ?? double.infinity,
            ),
            margin: EdgeInsets.only(
              top: mediaQuery.size.height * 0.1,
              left: 16,
              right: 16,
            ),
            decoration: _getDecoration(config),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.showHandle) _buildHandle(),
                Flexible(
                  child: Padding(
                    padding: widget.padding ?? 
                             const EdgeInsets.fromLTRB(24, 24, 24, 32),
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors2025.textQuaternary,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  ModalConfiguration _getModalConfiguration() {
    final primaryColor = widget.customColor ??
        (widget.category != null
            ? AppColors2025.getCategoryColor2025(widget.category!)
            : AppColors2025.primary);

    return ModalConfiguration(
      primaryColor: primaryColor,
    );
  }

  BoxDecoration _getDecoration(ModalConfiguration config) {
    switch (widget.variant) {
      case SherpaModalVariant2025.glass:
        return GlassNeuStyle.glassMorphism(
          elevation: GlassNeuElevation.high,
          color: AppColors2025.surface,
          borderRadius: AppSizes.radiusXL,
          opacity: 0.95,
        );

      case SherpaModalVariant2025.neu:
        return GlassNeuStyle.softNeumorphism(
          baseColor: AppColors2025.surface,
          borderRadius: AppSizes.radiusXL,
          intensity: 0.05,
        );

      case SherpaModalVariant2025.floating:
        return GlassNeuStyle.floatingGlass(
          color: AppColors2025.surface,
          borderRadius: AppSizes.radiusXL,
          elevation: 24,
        );

      case SherpaModalVariant2025.bottomSheet:
        return BoxDecoration(
          color: AppColors2025.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppSizes.radiusXL),
            topRight: Radius.circular(AppSizes.radiusXL),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors2025.shadowDark,
              blurRadius: 20,
              offset: const Offset(0, -10),
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

class _ModalHeader extends StatelessWidget {
  final String? title;
  final List<Widget>? actions;

  const _ModalHeader({this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          if (title != null)
            Expanded(
              child: Text(
                title!,
                style: GoogleFonts.notoSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors2025.textPrimary,
                ),
              ),
            ),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}

class _SherpaCenterModal extends StatefulWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final String? category;

  const _SherpaCenterModal({
    required this.child,
    this.title,
    this.actions,
    this.maxWidth,
    this.padding,
    this.category,
  });

  @override
  State<_SherpaCenterModal> createState() => _SherpaCenterModalState();
}

class _SherpaCenterModalState extends State<_SherpaCenterModal>
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
  }

  @override
  Widget build(BuildContext context) {
    final config = _getModalConfiguration();

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: widget.maxWidth ?? 400,
                ),
                decoration: GlassNeuStyle.glassMorphism(
                  elevation: GlassNeuElevation.high,
                  color: AppColors2025.surface,
                  borderRadius: AppSizes.radiusXL,
                  opacity: 0.95,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.title != null || widget.actions != null)
                      _ModalHeader(
                        title: widget.title,
                        actions: widget.actions,
                      ),
                    Flexible(
                      child: Padding(
                        padding: widget.padding ?? 
                                 const EdgeInsets.fromLTRB(24, 16, 24, 24),
                        child: widget.child,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  ModalConfiguration _getModalConfiguration() {
    final primaryColor = widget.category != null
        ? AppColors2025.getCategoryColor2025(widget.category!)
        : AppColors2025.primary;

    return ModalConfiguration(
      primaryColor: primaryColor,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class _SherpaSideModal extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final SherpaModalSide side;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final String? category;
  final Animation<double> animation;

  const _SherpaSideModal({
    required this.child,
    this.title,
    this.actions,
    required this.side,
    this.width,
    this.padding,
    this.category,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    
    return SlideTransition(
      position: animation.drive(
        Tween(
          begin: Offset(side == SherpaModalSide.left ? -1 : 1, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: MicroInteractions.easeOutQuart)),
      ),
      child: Align(
        alignment: side == SherpaModalSide.left 
            ? Alignment.centerLeft 
            : Alignment.centerRight,
        child: Container(
          width: width ?? mediaQuery.size.width * 0.85,
          height: double.infinity,
          decoration: GlassNeuStyle.glassMorphism(
            elevation: GlassNeuElevation.high,
            color: AppColors2025.surface,
            borderRadius: side == SherpaModalSide.left ? AppSizes.radiusL : 0,
            opacity: 0.95,
          ),
          child: SafeArea(
            child: Column(
              children: [
                if (title != null || actions != null)
                  _ModalHeader(
                    title: title,
                    actions: actions,
                  ),
                Expanded(
                  child: Padding(
                    padding: padding ?? const EdgeInsets.all(24),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SherpaFullscreenModal extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final EdgeInsetsGeometry? padding;
  final String? category;
  final Animation<double> animation;

  const _SherpaFullscreenModal({
    required this.child,
    this.title,
    this.actions,
    this.leading,
    this.padding,
    this.category,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors2025.surface,
      appBar: AppBar(
        backgroundColor: AppColors2025.surface,
        elevation: 0,
        leading: leading ?? IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: title != null 
            ? Text(
                title!,
                style: GoogleFonts.notoSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors2025.textPrimary,
                ),
              )
            : null,
        actions: actions,
      ),
      body: Padding(
        padding: padding ?? const EdgeInsets.all(24),
        child: child,
      ),
    );
  }
}

class _MenuOptionTile extends StatelessWidget {
  final SherpaMenuOption option;

  const _MenuOptionTile({required this.option});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(option.value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            if (option.icon != null) ...[ 
              IconTheme(
                data: IconThemeData(
                  color: option.isDestructive 
                      ? AppColors2025.error 
                      : AppColors2025.textSecondary,
                  size: 24,
                ),
                child: option.icon!,
              ),
              const SizedBox(width: 16),
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
                      color: option.isDestructive 
                          ? AppColors2025.error 
                          : AppColors2025.textPrimary,
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
            if (option.trailing != null) option.trailing!,
          ],
        ),
      ),
    );
  }
}

// ==================== 모델 클래스들 ====================

class SherpaMenuOption<T> {
  final T value;
  final String title;
  final String? subtitle;
  final Widget? icon;
  final Widget? trailing;
  final bool isDestructive;

  const SherpaMenuOption({
    required this.value,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.isDestructive = false,
  });
}

// ==================== 열거형 정의 ====================

enum SherpaModalVariant2025 {
  glass,        // 글래스모피즘
  neu,          // 뉴모피즘
  floating,     // 플로팅
  bottomSheet,  // 바텀시트
}

enum SherpaModalSide {
  left,         // 왼쪽
  right,        // 오른쪽
}

// ==================== 도우미 클래스들 ====================

class ModalConfiguration {
  final Color primaryColor;

  const ModalConfiguration({
    required this.primaryColor,
  });
}