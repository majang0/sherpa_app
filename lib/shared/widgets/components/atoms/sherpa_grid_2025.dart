// lib/shared/widgets/components/atoms/sherpa_grid_2025.dart

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../../../core/constants/app_colors_2025.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/glass_neu_style_system.dart';
import '../../../../core/animation/micro_interactions.dart';

/// 2025 디자인 트렌드를 반영한 현대적 그리드 컴포넌트
/// 반응형 레이아웃, 유연한 간격 조정, 다양한 배치 옵션을 지원
class SherpaGrid2025 extends StatelessWidget {
  final List<Widget> children;
  final SherpaGridVariant2025 variant;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final Axis scrollDirection;
  final bool reverse;
  final String? category;
  final Color? customColor;
  final bool enableMicroInteractions;
  final SherpaGridAlignment alignment;
  final double? itemWidth;
  final double? itemHeight;
  final int? maxCrossAxisExtent;
  final bool adaptive;
  final Map<SherpaBreakpoint, int>? responsiveColumns;

  const SherpaGrid2025({
    Key? key,
    required this.children,
    this.variant = SherpaGridVariant2025.standard,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 16,
    this.crossAxisSpacing = 16,
    this.childAspectRatio = 1.0,
    this.padding,
    this.margin,
    this.shrinkWrap = false,
    this.physics,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.category,
    this.customColor,
    this.enableMicroInteractions = true,
    this.alignment = SherpaGridAlignment.start,
    this.itemWidth,
    this.itemHeight,
    this.maxCrossAxisExtent,
    this.adaptive = true,
    this.responsiveColumns,
  }) : super(key: key);

  // ==================== 팩토리 생성자들 ====================

  /// 기본 그리드 (2열)
  factory SherpaGrid2025.basic({
    Key? key,
    required List<Widget> children,
    int crossAxisCount = 2,
    double spacing = 16,
    String? category,
  }) {
    return SherpaGrid2025(
      key: key,
      children: children,
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      category: category,
      variant: SherpaGridVariant2025.standard,
    );
  }

  /// 카드 그리드 (글래스 효과)
  factory SherpaGrid2025.cards({
    Key? key,
    required List<Widget> children,
    int crossAxisCount = 2,
    double spacing = 20,
    String? category,
    double childAspectRatio = 1.2,
  }) {
    return SherpaGrid2025(
      key: key,
      children: children,
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      childAspectRatio: childAspectRatio,
      category: category,
      variant: SherpaGridVariant2025.cards,
      padding: const EdgeInsets.all(16),
    );
  }

  /// 마소니 그리드 (Pinterest 스타일)
  factory SherpaGrid2025.masonry({
    Key? key,
    required List<Widget> children,
    double itemWidth = 160,
    double spacing = 12,
    String? category,
  }) {
    return SherpaGrid2025(
      key: key,
      children: children,
      itemWidth: itemWidth,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      category: category,
      variant: SherpaGridVariant2025.masonry,
      childAspectRatio: 0.7,
    );
  }

  /// 반응형 그리드 (화면 크기별 열 수 조정)
  factory SherpaGrid2025.responsive({
    Key? key,
    required List<Widget> children,
    Map<SherpaBreakpoint, int>? columns,
    double spacing = 16,
    String? category,
  }) {
    return SherpaGrid2025(
      key: key,
      children: children,
      responsiveColumns: columns ?? {
        SherpaBreakpoint.mobile: 1,
        SherpaBreakpoint.tablet: 2,
        SherpaBreakpoint.desktop: 3,
      },
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      category: category,
      variant: SherpaGridVariant2025.responsive,
      adaptive: true,
    );
  }

  /// 스태거드 그리드 (다양한 크기)
  factory SherpaGrid2025.staggered({
    Key? key,
    required List<Widget> children,
    int crossAxisCount = 2,
    double spacing = 12,
    String? category,
  }) {
    return SherpaGrid2025(
      key: key,
      children: children,
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      category: category,
      variant: SherpaGridVariant2025.staggered,
      childAspectRatio: 0.8,
    );
  }

  /// 리스트 그리드 (1열, 수평 스크롤)
  factory SherpaGrid2025.list({
    Key? key,
    required List<Widget> children,
    double itemWidth = 280,
    double spacing = 16,
    String? category,
    Axis scrollDirection = Axis.horizontal,
  }) {
    return SherpaGrid2025(
      key: key,
      children: children,
      crossAxisCount: 1,
      itemWidth: itemWidth,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      category: category,
      variant: SherpaGridVariant2025.list,
      scrollDirection: scrollDirection,
      shrinkWrap: true,
    );
  }

  /// 컴팩트 그리드 (작은 간격)
  factory SherpaGrid2025.compact({
    Key? key,
    required List<Widget> children,
    int crossAxisCount = 3,
    double spacing = 8,
    String? category,
  }) {
    return SherpaGrid2025(
      key: key,
      children: children,
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      category: category,
      variant: SherpaGridVariant2025.compact,
      childAspectRatio: 1.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = _getGridConfiguration(context);
    
    Widget grid = Container(
      margin: margin,
      child: _buildGrid(config),
    );

    // 마이크로 인터랙션 적용
    if (enableMicroInteractions) {
      grid = MicroInteractions.slideInFade(
        child: grid,
        direction: SlideDirection.bottom,
        duration: MicroInteractions.slow,
      );
    }

    return grid;
  }

  Widget _buildGrid(GridConfiguration config) {
    switch (variant) {
      case SherpaGridVariant2025.masonry:
        return _buildMasonryGrid(config);
      case SherpaGridVariant2025.staggered:
        return _buildStaggeredGrid(config);
      case SherpaGridVariant2025.list:
        return _buildListGrid(config);
      case SherpaGridVariant2025.responsive:
        return _buildResponsiveGrid(config);
      default:
        return _buildStandardGrid(config);
    }
  }

  Widget _buildStandardGrid(GridConfiguration config) {
    if (scrollDirection == Axis.horizontal) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: physics,
        padding: padding,
        reverse: reverse,
        child: _buildGridView(config),
      );
    }

    return GridView.builder(
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      scrollDirection: scrollDirection,
      reverse: reverse,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: config.crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => _wrapChild(children[index], config),
    );
  }

  Widget _buildMasonryGrid(GridConfiguration config) {
    return _MasonryGridView(
      children: children.map((child) => _wrapChild(child, config)).toList(),
      crossAxisCount: config.crossAxisCount,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      padding: padding,
    );
  }

  Widget _buildStaggeredGrid(GridConfiguration config) {
    return _StaggeredGridView(
      children: children.map((child) => _wrapChild(child, config)).toList(),
      crossAxisCount: config.crossAxisCount,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      padding: padding,
    );
  }

  Widget _buildListGrid(GridConfiguration config) {
    if (scrollDirection == Axis.horizontal) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: physics,
        padding: padding,
        child: Row(
          children: children.asMap().entries.map((entry) {
            final index = entry.key;
            final child = entry.value;
            return Container(
              width: itemWidth ?? 280,
              margin: EdgeInsets.only(
                left: index == 0 ? 0 : crossAxisSpacing,
              ),
              child: _wrapChild(child, config),
            );
          }).toList(),
        ),
      );
    }

    return ListView.separated(
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      reverse: reverse,
      itemCount: children.length,
      separatorBuilder: (context, index) => SizedBox(height: mainAxisSpacing),
      itemBuilder: (context, index) => _wrapChild(children[index], config),
    );
  }

  Widget _buildResponsiveGrid(GridConfiguration config) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final breakpoint = _getBreakpoint(screenWidth);
        final responsiveCrossAxisCount = responsiveColumns?[breakpoint] ?? config.crossAxisCount;

        return GridView.builder(
          padding: padding,
          shrinkWrap: shrinkWrap,
          physics: physics,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: responsiveCrossAxisCount,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => _wrapChild(children[index], config),
        );
      },
    );
  }

  Widget _buildGridView(GridConfiguration config) {
    return SizedBox(
      height: itemHeight ?? 200,
      child: Row(
        children: children.asMap().entries.map((entry) {
          final index = entry.key;
          final child = entry.value;
          return Container(
            width: itemWidth ?? 160,
            margin: EdgeInsets.only(
              left: index == 0 ? 0 : crossAxisSpacing,
            ),
            child: _wrapChild(child, config),
          );
        }).toList(),
      ),
    );
  }

  Widget _wrapChild(Widget child, GridConfiguration config) {
    if (variant == SherpaGridVariant2025.cards) {
      return Container(
        decoration: GlassNeuStyle.glassMorphism(
          elevation: GlassNeuElevation.medium,
          color: config.color,
          borderRadius: AppSizes.radiusM,
          opacity: 0.15,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          child: child,
        ),
      );
    }

    if (enableMicroInteractions) {
      return MicroInteractions.hoverEffect(
        scaleUpTo: 1.02,
        elevationIncrease: 2,
        child: child,
      );
    }

    return child;
  }

  GridConfiguration _getGridConfiguration(BuildContext context) {
    final color = customColor ??
        (category != null
            ? AppColors2025.getCategoryColor2025(category!)
            : AppColors2025.primary);

    int responsiveCrossAxisCount = crossAxisCount;
    
    if (adaptive) {
      final screenWidth = MediaQuery.of(context).size.width;
      final breakpoint = _getBreakpoint(screenWidth);
      responsiveCrossAxisCount = responsiveColumns?[breakpoint] ?? 
          _getDefaultCrossAxisCount(breakpoint);
    }

    return GridConfiguration(
      crossAxisCount: responsiveCrossAxisCount,
      color: color,
    );
  }

  SherpaBreakpoint _getBreakpoint(double screenWidth) {
    if (screenWidth < 600) return SherpaBreakpoint.mobile;
    if (screenWidth < 1200) return SherpaBreakpoint.tablet;
    return SherpaBreakpoint.desktop;
  }

  int _getDefaultCrossAxisCount(SherpaBreakpoint breakpoint) {
    switch (breakpoint) {
      case SherpaBreakpoint.mobile:
        return variant == SherpaGridVariant2025.compact ? 2 : 1;
      case SherpaBreakpoint.tablet:
        return variant == SherpaGridVariant2025.compact ? 4 : 2;
      case SherpaBreakpoint.desktop:
        return variant == SherpaGridVariant2025.compact ? 6 : 3;
    }
  }
}

// ==================== 커스텀 그리드 위젯들 ====================

class _MasonryGridView extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final EdgeInsetsGeometry? padding;

  const _MasonryGridView({
    required this.children,
    required this.crossAxisCount,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(crossAxisCount, (columnIndex) {
          return Expanded(
            child: Column(
              children: _getColumnChildren(columnIndex),
            ),
          );
        }),
      ),
    );
  }

  List<Widget> _getColumnChildren(int columnIndex) {
    List<Widget> columnChildren = [];
    for (int i = columnIndex; i < children.length; i += crossAxisCount) {
      columnChildren.add(
        Container(
          margin: EdgeInsets.only(
            bottom: mainAxisSpacing,
            left: columnIndex == 0 ? 0 : crossAxisSpacing / 2,
            right: columnIndex == crossAxisCount - 1 ? 0 : crossAxisSpacing / 2,
          ),
          child: children[i],
        ),
      );
    }
    return columnChildren;
  }
}

class _StaggeredGridView extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final EdgeInsetsGeometry? padding;

  const _StaggeredGridView({
    required this.children,
    required this.crossAxisCount,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.custom(
      padding: padding,
      gridDelegate: SliverQuiltedGridDelegate(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        pattern: _generateStaggeredPattern(),
      ),
      childrenDelegate: SliverChildBuilderDelegate(
        (context, index) => children[index],
        childCount: children.length,
      ),
    );
  }

  List<QuiltedGridTile> _generateStaggeredPattern() {
    return List.generate(children.length, (index) {
      // 다양한 크기의 타일 패턴 생성
      if (index % 7 == 0) {
        return const QuiltedGridTile(2, 2); // 큰 타일
      } else if (index % 4 == 0) {
        return const QuiltedGridTile(2, 1); // 세로 긴 타일
      } else if (index % 3 == 0) {
        return const QuiltedGridTile(1, 2); // 가로 긴 타일
      } else {
        return const QuiltedGridTile(1, 1); // 기본 타일
      }
    });
  }
}

// Quilted Grid 관련 클래스들 (간단한 구현)
class SliverQuiltedGridDelegate extends SliverGridDelegate {
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final List<QuiltedGridTile> pattern;

  const SliverQuiltedGridDelegate({
    required this.crossAxisCount,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    required this.pattern,
  });

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final double tileWidth = (constraints.crossAxisExtent - 
        (crossAxisCount - 1) * crossAxisSpacing) / crossAxisCount;
    
    return SliverGridRegularTileLayout(
      crossAxisCount: crossAxisCount,
      mainAxisStride: tileWidth + crossAxisSpacing,
      crossAxisStride: tileWidth + crossAxisSpacing,
      childMainAxisExtent: tileWidth,
      childCrossAxisExtent: tileWidth,
      reverseCrossAxis: false,
    );
  }

  @override
  bool shouldRelayout(SliverQuiltedGridDelegate oldDelegate) {
    return crossAxisCount != oldDelegate.crossAxisCount ||
           mainAxisSpacing != oldDelegate.mainAxisSpacing ||
           crossAxisSpacing != oldDelegate.crossAxisSpacing;
  }
}

class QuiltedGridTile {
  final int crossAxisCellCount;
  final int mainAxisCellCount;

  const QuiltedGridTile(this.mainAxisCellCount, this.crossAxisCellCount);
}

// ==================== 열거형 정의 ====================

enum SherpaGridVariant2025 {
  standard,     // 표준 그리드
  cards,        // 카드형 그리드 (글래스 효과)
  masonry,      // 마소니 그리드 (Pinterest 스타일)
  staggered,    // 스태거드 그리드 (다양한 크기)
  list,         // 리스트형 그리드
  compact,      // 컴팩트 그리드 (작은 간격)
  responsive,   // 반응형 그리드
}

enum SherpaGridAlignment {
  start,        // 시작점 정렬
  center,       // 중앙 정렬
  end,          // 끝점 정렬
  spaceBetween, // 균등 배치
  spaceAround,  // 주변 여백 균등
  spaceEvenly,  // 완전 균등 배치
}

enum SherpaBreakpoint {
  mobile,       // < 600px
  tablet,       // 600px - 1200px
  desktop,      // > 1200px
}

// ==================== 도우미 클래스들 ====================

class GridConfiguration {
  final int crossAxisCount;
  final Color color;

  const GridConfiguration({
    required this.crossAxisCount,
    required this.color,
  });
}