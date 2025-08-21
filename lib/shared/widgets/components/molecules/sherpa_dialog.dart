import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../atoms/sherpa_avatar.dart';

enum SherpaDialogType {
  alert,       // 알림 다이얼로그
  confirm,     // 확인 다이얼로그
  form,        // 폼 다이얼로그
  success,     // 성공 다이얼로그
  warning,     // 경고 다이얼로그
  error,       // 오류 다이얼로그
}

class SherpaDialog extends StatelessWidget {
  final SherpaDialogType type;
  final String? title;
  final String? message;
  final Widget? content;
  final Widget? icon;
  final List<Widget>? actions;
  final bool barrierDismissible;
  final EdgeInsets? padding;
  final double? width;
  final bool showCloseButton;

  const SherpaDialog({
    Key? key,
    this.type = SherpaDialogType.alert,
    this.title,
    this.message,
    this.content,
    this.icon,
    this.actions,
    this.barrierDismissible = true,
    this.padding,
    this.width,
    this.showCloseButton = true,
  }) : super(key: key);

  // 편의 팩토리 생성자들
  static Future<bool?> showAlert({
    required BuildContext context,
    String? title,
    required String message,
    String confirmText = '확인',
    VoidCallback? onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => SherpaDialog(
        type: SherpaDialogType.alert,
        title: title,
        message: message,
        actions: [
          SherpaDialogAction.primary(
            text: confirmText,
            onPressed: () {
              Navigator.of(context).pop(true);
              onConfirm?.call();
            },
          ),
        ],
      ),
    );
  }

  static Future<bool?> showConfirm({
    required BuildContext context,
    String? title,
    required String message,
    String confirmText = '확인',
    String cancelText = '취소',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => SherpaDialog(
        type: SherpaDialogType.confirm,
        title: title,
        message: message,
        actions: [
          SherpaDialogAction.secondary(
            text: cancelText,
            onPressed: () {
              Navigator.of(context).pop(false);
              onCancel?.call();
            },
          ),
          SherpaDialogAction.primary(
            text: confirmText,
            onPressed: () {
              Navigator.of(context).pop(true);
              onConfirm?.call();
            },
          ),
        ],
      ),
    );
  }

  static Future<T?> showSuccess<T>({
    required BuildContext context,
    String? title,
    required String message,
    String confirmText = '확인',
    VoidCallback? onConfirm,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => SherpaDialog(
        type: SherpaDialogType.success,
        title: title ?? '성공',
        message: message,
        actions: [
          SherpaDialogAction.primary(
            text: confirmText,
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm?.call();
            },
          ),
        ],
      ),
    );
  }

  static Future<T?> showError<T>({
    required BuildContext context,
    String? title,
    required String message,
    String confirmText = '확인',
    VoidCallback? onConfirm,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => SherpaDialog(
        type: SherpaDialogType.error,
        title: title ?? '오류',
        message: message,
        actions: [
          SherpaDialogAction.primary(
            text: confirmText,
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm?.call();
            },
          ),
        ],
      ),
    );
  }

  static Future<T?> showCustom<T>({
    required BuildContext context,
    String? title,
    required Widget content,
    List<Widget>? actions,
    bool barrierDismissible = true,
    bool showCloseButton = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => SherpaDialog(
        type: SherpaDialogType.form,
        title: title,
        content: content,
        actions: actions,
        barrierDismissible: barrierDismissible,
        showCloseButton: showCloseButton,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: width,
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withOpacity(0.1),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
            BoxShadow(
              color: AppColors.textPrimary.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            _buildContent(),
            if (actions != null && actions!.isNotEmpty) _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    if (title == null && !showCloseButton) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Row(
        children: [
          // 타입별 아이콘
          if (_getTypeIcon() != null) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getTypeColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
              child: _getTypeIcon(),
            ),
            const SizedBox(width: AppSizes.paddingM),
          ],
          
          // 제목
          if (title != null)
            Expanded(
              child: Text(
                title!,
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          
          // 닫기 버튼
          if (showCloseButton)
            IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
              icon: Icon(
                Icons.close,
                color: AppColors.textLight,
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Flexible(
      child: Container(
        width: double.infinity,
        padding: padding ?? EdgeInsets.symmetric(
          horizontal: AppSizes.paddingL,
          vertical: title != null ? 0 : AppSizes.paddingL,
        ),
        child: content ?? (message != null ? Text(
          message!,
          style: GoogleFonts.notoSans(
            fontSize: 15,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ) : null),
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          for (int i = 0; i < actions!.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSizes.paddingS),
            actions![i],
          ],
        ],
      ),
    );
  }

  Widget? _getTypeIcon() {
    switch (type) {
      case SherpaDialogType.success:
        return Icon(Icons.check_circle, color: _getTypeColor(), size: 24);
      case SherpaDialogType.warning:
        return Icon(Icons.warning, color: _getTypeColor(), size: 24);
      case SherpaDialogType.error:
        return Icon(Icons.error, color: _getTypeColor(), size: 24);
      case SherpaDialogType.confirm:
        return Icon(Icons.help, color: _getTypeColor(), size: 24);
      default:
        return icon;
    }
  }

  Color _getTypeColor() {
    switch (type) {
      case SherpaDialogType.success:
        return AppColors.success;
      case SherpaDialogType.warning:
        return AppColors.warning;
      case SherpaDialogType.error:
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }
}

// 다이얼로그 액션 버튼
class SherpaDialogAction extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool isDestructive;
  final bool isLoading;
  final Widget? icon;

  const SherpaDialogAction({
    Key? key,
    required this.text,
    this.onPressed,
    this.isPrimary = false,
    this.isDestructive = false,
    this.isLoading = false,
    this.icon,
  }) : super(key: key);

  factory SherpaDialogAction.primary({
    required String text,
    VoidCallback? onPressed,
    bool isLoading = false,
    Widget? icon,
  }) {
    return SherpaDialogAction(
      text: text,
      onPressed: onPressed,
      isPrimary: true,
      isLoading: isLoading,
      icon: icon,
    );
  }

  factory SherpaDialogAction.secondary({
    required String text,
    VoidCallback? onPressed,
    Widget? icon,
  }) {
    return SherpaDialogAction(
      text: text,
      onPressed: onPressed,
      isPrimary: false,
      icon: icon,
    );
  }

  factory SherpaDialogAction.destructive({
    required String text,
    VoidCallback? onPressed,
    Widget? icon,
  }) {
    return SherpaDialogAction(
      text: text,
      onPressed: onPressed,
      isDestructive: true,
      icon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = isDestructive 
        ? AppColors.error 
        : (isPrimary ? AppColors.primary : Colors.transparent);
    
    final Color textColor = isDestructive || isPrimary 
        ? Colors.white 
        : AppColors.textSecondary;

    return Container(
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: isPrimary ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
            side: !isPrimary && !isDestructive 
                ? BorderSide(color: AppColors.border) 
                : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingM,
            vertical: AppSizes.paddingS,
          ),
        ),
        child: isLoading 
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 6),
                  ],
                  Text(
                    text,
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// 특수 다이얼로그들
class SherpaLoadingDialog extends StatelessWidget {
  final String? message;

  const SherpaLoadingDialog({
    Key? key,
    this.message,
  }) : super(key: key);

  static void show(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SherpaLoadingDialog(message: message),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            if (message != null) ...[
              const SizedBox(height: AppSizes.paddingM),
              Text(
                message!,
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SherpaUserDialog extends StatelessWidget {
  final String userName;
  final String? userImage;
  final String? title;
  final String? message;
  final List<Widget>? actions;

  const SherpaUserDialog({
    Key? key,
    required this.userName,
    this.userImage,
    this.title,
    this.message,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SherpaDialog(
      showCloseButton: false,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SherpaAvatar.user(
            name: userName,
            imageUrl: userImage,
            size: SherpaAvatarSize.large,
          ),
          const SizedBox(height: AppSizes.paddingM),
          if (title != null)
            Text(
              title!,
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          if (message != null) ...[
            const SizedBox(height: AppSizes.paddingS),
            Text(
              message!,
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
      actions: actions,
    );
  }
}