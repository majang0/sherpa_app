// lib/shared/widgets/components/molecules/sherpa_app_bar_2025.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors_2025.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/glass_neu_style_system.dart';
import '../../../../core/animation/micro_interactions.dart';

/// 2025 디자인 트렌드를 반영한 현대적 앱바 컴포넌트
/// 글래스모피즘, 적응형 디자인, 다양한 레이아웃을 지원
class SherpaAppBar2025 extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? bottom;
  final SherpaAppBarVariant2025 variant;
  final SherpaAppBarStyle style;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  final double? titleSpacing;
  final double? toolbarHeight;
  final double? bottomHeight;
  final bool pinned;
  final bool floating;
  final bool snap;
  final String? category;
  final Color? customColor;
  final bool enableMicroInteractions;
  final bool enableHapticFeedback;
  final GlassNeuElevation glassElevation;
  final VoidCallback? onTitleTap;
  final ScrollController? scrollController;
  final bool hideOnScroll;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? appBarBottom;
  final ShapeBorder? shape;

  const SherpaAppBar2025({
    Key? key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.bottom,
    this.variant = SherpaAppBarVariant2025.glass,
    this.style = SherpaAppBarStyle.normal,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.automaticallyImplyLeading = true,
    this.centerTitle = true,
    this.titleSpacing,
    this.toolbarHeight,
    this.bottomHeight,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.category,
    this.customColor,
    this.enableMicroInteractions = true,
    this.enableHapticFeedback = true,
    this.glassElevation = GlassNeuElevation.medium,
    this.onTitleTap,
    this.scrollController,
    this.hideOnScroll = false,
    this.flexibleSpace,
    this.appBarBottom,
    this.shape,
  }) : super(key: key);

  // ==================== 팩토리 생성자들 ====================

  /// 기본 앱바 (글래스 스타일)
  factory SherpaAppBar2025.basic({
    Key? key,
    required String title,
    Widget? leading,
    List<Widget>? actions,
    String? category,
    VoidCallback? onTitleTap,
  }) {
    return SherpaAppBar2025(
      key: key,
      title: title,
      leading: leading,
      actions: actions,
      category: category,
      onTitleTap: onTitleTap,
      variant: SherpaAppBarVariant2025.glass,
      style: SherpaAppBarStyle.normal,
    );
  }

  /// 대형 앱바 (큰 제목)
  factory SherpaAppBar2025.large({
    Key? key,
    required String title,
    Widget? leading,
    List<Widget>? actions,
    String? category,
    Widget? flexibleSpace,
  }) {
    return SherpaAppBar2025(
      key: key,
      title: title,
      leading: leading,
      actions: actions,
      category: category,
      flexibleSpace: flexibleSpace,
      variant: SherpaAppBarVariant2025.hybrid,
      style: SherpaAppBarStyle.large,
      toolbarHeight: 120,
    );
  }

  /// 검색 앱바
  factory SherpaAppBar2025.search({
    Key? key,
    Widget? titleWidget,
    List<Widget>? actions,
    String? category,
  }) {
    return SherpaAppBar2025(
      key: key,
      titleWidget: titleWidget,
      actions: actions,
      category: category,
      variant: SherpaAppBarVariant2025.floating,
      style: SherpaAppBarStyle.compact,
      centerTitle: false,
      automaticallyImplyLeading: false,
    );
  }

  /// 투명 앱바 (오버레이)
  factory SherpaAppBar2025.transparent({
    Key? key,
    String? title,
    Widget? leading,
    List<Widget>? actions,
    Color? foregroundColor,
  }) {
    return SherpaAppBar2025(
      key: key,
      title: title,
      leading: leading,
      actions: actions,
      foregroundColor: foregroundColor ?? AppColors2025.textOnDark,
      variant: SherpaAppBarVariant2025.transparent,
      style: SherpaAppBarStyle.overlay,
      elevation: 0,
    );
  }

  /// 컴팩트 앱바 (작은 크기)
  factory SherpaAppBar2025.compact({
    Key? key,
    required String title,
    Widget? leading,
    List<Widget>? actions,
    String? category,
  }) {
    return SherpaAppBar2025(
      key: key,
      title: title,
      leading: leading,
      actions: actions,
      category: category,
      variant: SherpaAppBarVariant2025.neu,
      style: SherpaAppBarStyle.compact,
      toolbarHeight: 48,
    );
  }

  /// 슬리버 앱바 (스크롤 효과)
  factory SherpaAppBar2025.sliver({
    Key? key,
    required String title,
    Widget? leading,
    List<Widget>? actions,
    Widget? flexibleSpace,
    String? category,
    bool pinned = true,
    bool floating = false,
    bool snap = false,
  }) {
    return SherpaAppBar2025(
      key: key,
      title: title,
      leading: leading,
      actions: actions,
      flexibleSpace: flexibleSpace,
      category: category,
      variant: SherpaAppBarVariant2025.glass,
      style: SherpaAppBarStyle.sliver,
      pinned: pinned,
      floating: floating,
      snap: snap,
      toolbarHeight: 100,
    );
  }

  @override
  State<SherpaAppBar2025> createState() => _SherpaAppBar2025State();

  @override
  Size get preferredSize {
    final height = toolbarHeight ?? _getDefaultHeight();
    final bottomHeight = this.bottomHeight ?? (appBarBottom?.preferredSize.height ?? 0);
    return Size.fromHeight(height + bottomHeight);
  }

  double _getDefaultHeight() {
    switch (style) {
      case SherpaAppBarStyle.normal:
        return 56;
      case SherpaAppBarStyle.large:
        return 120;
      case SherpaAppBarStyle.compact:
        return 48;
      case SherpaAppBarStyle.overlay:
        return 56;
      case SherpaAppBarStyle.sliver:
        return 100;
    }
  }
}

class _SherpaAppBar2025State extends State<SherpaAppBar2025>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isVisible = true;
  double _scrollOffset = 0;

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
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: MicroInteractions.easeOutQuart,
    ));

    _animationController.forward();
    
    if (widget.scrollController != null && widget.hideOnScroll) {
      widget.scrollController!.addListener(_handleScroll);
    }
  }

  void _handleScroll() {
    if (widget.scrollController == null) return;
    
    final offset = widget.scrollController!.offset;
    final delta = offset - _scrollOffset;
    _scrollOffset = offset;
    
    if (delta > 10 && _isVisible) {
      setState(() => _isVisible = false);
      _animationController.reverse();
    } else if (delta < -10 && !_isVisible) {
      setState(() => _isVisible = true);
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getAppBarConfiguration();
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position: widget.hideOnScroll ? _slideAnimation : 
                   const AlwaysStoppedAnimation(Offset.zero),
          child: FadeTransition(
            opacity: widget.hideOnScroll ? _fadeAnimation : 
                    const AlwaysStoppedAnimation(1.0),
            child: _buildAppBar(config),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(AppBarConfiguration config) {
    return Container(
      height: widget.preferredSize.height,
      decoration: _getDecoration(config),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(child: _buildToolbar(config)),
            if (widget.appBarBottom != null)
              SizedBox(
                height: widget.appBarBottom!.preferredSize.height,
                child: widget.appBarBottom!,
              ),
            if (widget.bottom != null)
              SizedBox(
                height: widget.bottomHeight ?? 48,
                child: widget.bottom!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar(AppBarConfiguration config) {
    if (widget.flexibleSpace != null) {
      return widget.flexibleSpace!;
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.titleSpacing ?? 16,
        vertical: 8,
      ),
      child: Row(
        children: [
          _buildLeading(config),
          Expanded(child: _buildTitle(config)),
          _buildActions(config),
        ],
      ),
    );
  }

  Widget _buildLeading(AppBarConfiguration config) {
    if (widget.leading != null) {
      return widget.leading!;
    }

    if (widget.automaticallyImplyLeading) {
      final scaffoldHasDrawer = Scaffold.maybeOf(context)?.hasDrawer ?? false;
      final canPop = ModalRoute.of(context)?.canPop ?? false;

      if (scaffoldHasDrawer) {
        return _buildIconButton(
          icon: Icons.menu,
          onPressed: () => Scaffold.of(context).openDrawer(),
          config: config,
        );
      } else if (canPop) {
        return _buildIconButton(
          icon: Icons.arrow_back_ios,
          onPressed: () => Navigator.of(context).pop(),
          config: config,
        );
      }
    }

    return const SizedBox(width: 48);
  }

  Widget _buildTitle(AppBarConfiguration config) {
    if (widget.titleWidget != null) {
      return widget.centerTitle
          ? Center(child: widget.titleWidget!)
          : Align(alignment: Alignment.centerLeft, child: widget.titleWidget!);
    }

    if (widget.title != null) {
      Widget titleText = Text(
        widget.title!,
        style: GoogleFonts.notoSans(
          fontSize: config.titleSize,
          fontWeight: FontWeight.w700,
          color: widget.foregroundColor ?? config.foregroundColor,
          height: 1.2,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );

      if (widget.onTitleTap != null) {
        titleText = GestureDetector(
          onTap: () {
            widget.onTitleTap?.call();
            if (widget.enableHapticFeedback) {
              HapticFeedback.lightImpact();
            }
          },
          child: titleText,
        );
      }

      if (widget.enableMicroInteractions) {
        titleText = MicroInteractions.slideInFade(
          child: titleText,
          direction: SlideDirection.top,
        );
      }

      return widget.centerTitle
          ? Center(child: titleText)
          : Align(alignment: Alignment.centerLeft, child: titleText);
    }

    return const SizedBox.shrink();
  }

  Widget _buildActions(AppBarConfiguration config) {
    if (widget.actions == null || widget.actions!.isEmpty) {
      return const SizedBox(width: 48);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: widget.actions!.map((action) {
        if (widget.enableMicroInteractions) {
          return MicroInteractions.tapResponse(
            child: action,
          );
        }
        return action;
      }).toList(),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required AppBarConfiguration config,
  }) {
    Widget iconButton = IconButton(
      icon: Icon(
        icon,
        color: widget.foregroundColor ?? config.foregroundColor,
        size: 24,
      ),
      onPressed: () {
        onPressed();
        if (widget.enableHapticFeedback) {
          HapticFeedback.lightImpact();
        }
      },
      padding: const EdgeInsets.all(12),
    );

    if (widget.enableMicroInteractions) {
      iconButton = MicroInteractions.tapResponse(
        child: iconButton,
      );
    }

    return iconButton;
  }

  AppBarConfiguration _getAppBarConfiguration() {
    final color = widget.customColor ??
        (widget.category != null
            ? AppColors2025.getCategoryColor2025(widget.category!)
            : AppColors2025.primary);

    switch (widget.style) {
      case SherpaAppBarStyle.normal:
        return AppBarConfiguration(
          height: 56,
          titleSize: 20,
          backgroundColor: widget.backgroundColor ?? AppColors2025.surface,
          foregroundColor: AppColors2025.textPrimary,
          color: color,
        );
      case SherpaAppBarStyle.large:
        return AppBarConfiguration(
          height: 120,
          titleSize: 32,
          backgroundColor: widget.backgroundColor ?? AppColors2025.surface,
          foregroundColor: AppColors2025.textPrimary,
          color: color,
        );
      case SherpaAppBarStyle.compact:
        return AppBarConfiguration(
          height: 48,
          titleSize: 18,
          backgroundColor: widget.backgroundColor ?? AppColors2025.surface,
          foregroundColor: AppColors2025.textPrimary,
          color: color,
        );
      case SherpaAppBarStyle.overlay:
        return AppBarConfiguration(
          height: 56,
          titleSize: 20,
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors2025.textOnDark,
          color: color,
        );
      case SherpaAppBarStyle.sliver:
        return AppBarConfiguration(
          height: 100,
          titleSize: 24,
          backgroundColor: widget.backgroundColor ?? AppColors2025.surface,
          foregroundColor: AppColors2025.textPrimary,
          color: color,
        );
    }
  }

  BoxDecoration _getDecoration(AppBarConfiguration config) {
    if (widget.variant == SherpaAppBarVariant2025.transparent) {
      return BoxDecoration(
        color: Colors.transparent,
        shape: widget.shape != null ? BoxShape.rectangle : BoxShape.rectangle,
      );
    }

    switch (widget.variant) {
      case SherpaAppBarVariant2025.glass:
        return GlassNeuStyle.glassMorphism(
          elevation: widget.glassElevation,
          color: config.color,
          borderRadius: 0,
          opacity: 0.95,
        );

      case SherpaAppBarVariant2025.neu:
        return GlassNeuStyle.neumorphism(
          elevation: widget.glassElevation,
          baseColor: config.backgroundColor,
          borderRadius: 0,
        );

      case SherpaAppBarVariant2025.floating:
        return GlassNeuStyle.floatingGlass(
          color: config.color,
          borderRadius: 0,
          elevation: widget.elevation ?? 16,
        );

      case SherpaAppBarVariant2025.hybrid:
        return GlassNeuStyle.hybrid(
          elevation: widget.glassElevation,
          color: config.color,
          borderRadius: 0,
          glassOpacity: 0.15,
        );

      case SherpaAppBarVariant2025.solid:
        return BoxDecoration(
          color: config.backgroundColor,
          boxShadow: widget.elevation != null && widget.elevation! > 0
              ? [
                  BoxShadow(
                    color: AppColors2025.shadowLight,
                    blurRadius: widget.elevation! * 2,
                    offset: Offset(0, widget.elevation! / 2),
                  ),
                ]
              : null,
        );

      case SherpaAppBarVariant2025.transparent:
        return BoxDecoration(
          color: Colors.transparent,
        );
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_handleScroll);
    _animationController.dispose();
    super.dispose();
  }
}

// ==================== 열거형 정의 ====================

enum SherpaAppBarVariant2025 {
  glass,       // 글래스모피즘
  neu,         // 뉴모피즘
  floating,    // 플로팅 글래스
  hybrid,      // 하이브리드 (글래스 + 뉴모피즘)
  solid,       // 솔리드 (전통적)
  transparent, // 투명
}

enum SherpaAppBarStyle {
  normal,      // 기본 크기
  large,       // 큰 크기
  compact,     // 작은 크기
  overlay,     // 오버레이 (투명 배경)
  sliver,      // 슬리버 (스크롤 효과)
}

// ==================== 도우미 클래스들 ====================

class AppBarConfiguration {
  final double height;
  final double titleSize;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color color;

  const AppBarConfiguration({
    required this.height,
    required this.titleSize,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.color,
  });
}