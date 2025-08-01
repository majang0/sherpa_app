import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class SherpaBottomSheet extends StatelessWidget {
  final String? title;
  final Widget? header;
  final Widget child;
  final List<Widget>? actions;
  final bool showHandle;
  final bool isScrollable;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const SherpaBottomSheet({
    Key? key,
    this.title,
    this.header,
    required this.child,
    this.actions,
    this.showHandle = true,
    this.isScrollable = true,
    this.height,
    this.padding,
  }) : super(key: key);

  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    Widget? header,
    required Widget child,
    List<Widget>? actions,
    bool showHandle = true,
    bool isScrollable = true,
    double? height,
    EdgeInsetsGeometry? padding,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (context) => SherpaBottomSheet(
        title: title,
        header: header,
        child: child,
        actions: actions,
        showHandle: showHandle,
        isScrollable: isScrollable,
        height: height,
        padding: padding,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusL),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showHandle) _buildHandle(),
          if (title != null || header != null) _buildHeader(),
          Flexible(
            child: isScrollable 
                ? SingleChildScrollView(
                    padding: padding ?? const EdgeInsets.all(AppSizes.paddingL),
                    child: child,
                  )
                : Padding(
                    padding: padding ?? const EdgeInsets.all(AppSizes.paddingL),
                    child: child,
                  ),
          ),
          if (actions != null && actions!.isNotEmpty) _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingL,
        vertical: AppSizes.paddingM,
      ),
      child: header ?? (title != null ? Row(
        children: [
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
        ],
      ) : null),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Row(
        children: [
          for (int i = 0; i < actions!.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSizes.paddingS),
            Expanded(child: actions![i]),
          ],
        ],
      ),
    );
  }
}