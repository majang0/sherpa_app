// lib/shared/widgets/components/atoms/sherpa_grid_2025_simple.dart

import 'package:flutter/material.dart';

/// 2025 디자인 트렌드를 반영한 간단한 그리드 컴포넌트
/// 반응형 레이아웃과 다양한 그리드 패턴을 지원하는 현대적 그리드 시스템
class SherpaGrid2025 extends StatelessWidget {
  final List<Widget> children;
  final SherpaGridVariant2025 variant;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  const SherpaGrid2025({
    Key? key,
    required this.children,
    this.variant = SherpaGridVariant2025.fixed,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 8.0,
    this.crossAxisSpacing = 8.0,
    this.childAspectRatio = 1.0,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
  }) : super(key: key);

  /// 고정 그리드 (일반적인 그리드)
  factory SherpaGrid2025.fixed({
    Key? key,
    required List<Widget> children,
    int crossAxisCount = 2,
    double mainAxisSpacing = 8.0,
    double crossAxisSpacing = 8.0,
    double childAspectRatio = 1.0,
    EdgeInsetsGeometry? padding,
  }) {
    return SherpaGrid2025(
      key: key,
      children: children,
      variant: SherpaGridVariant2025.fixed,
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      childAspectRatio: childAspectRatio,
      padding: padding,
    );
  }

  /// 반응형 그리드 (화면 크기에 따라 열 수 조정)
  factory SherpaGrid2025.responsive({
    Key? key,
    required List<Widget> children,
    double mainAxisSpacing = 8.0,
    double crossAxisSpacing = 8.0,
    double childAspectRatio = 1.0,
    EdgeInsetsGeometry? padding,
  }) {
    return SherpaGrid2025(
      key: key,
      children: children,
      variant: SherpaGridVariant2025.responsive,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      childAspectRatio: childAspectRatio,
      padding: padding,
    );
  }

  /// 어댑티브 그리드 (콘텐츠 크기에 맞춤)
  factory SherpaGrid2025.adaptive({
    Key? key,
    required List<Widget> children,
    double mainAxisSpacing = 8.0,
    double crossAxisSpacing = 8.0,
    EdgeInsetsGeometry? padding,
  }) {
    return SherpaGrid2025(
      key: key,
      children: children,
      variant: SherpaGridVariant2025.adaptive,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      padding: padding,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget grid;

    switch (variant) {
      case SherpaGridVariant2025.fixed:
        grid = _buildFixedGrid();
        break;
      case SherpaGridVariant2025.responsive:
        grid = _buildResponsiveGrid(context);
        break;
      case SherpaGridVariant2025.adaptive:
        grid = _buildAdaptiveGrid();
        break;
    }

    if (padding != null) {
      grid = Padding(padding: padding!, child: grid);
    }

    return grid;
  }

  Widget _buildFixedGrid() {
    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }

  Widget _buildResponsiveGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final responsiveCrossAxisCount = _getResponsiveCrossAxisCount(screenWidth);

    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: responsiveCrossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }

  Widget _buildAdaptiveGrid() {
    return Wrap(
      spacing: crossAxisSpacing,
      runSpacing: mainAxisSpacing,
      children: children,
    );
  }

  int _getResponsiveCrossAxisCount(double screenWidth) {
    if (screenWidth < 600) {
      return 1; // 모바일
    } else if (screenWidth < 900) {
      return 2; // 태블릿
    } else {
      return 3; // 데스크톱
    }
  }
}

// ==================== 열거형 정의 ====================

enum SherpaGridVariant2025 {
  fixed,      // 고정 그리드
  responsive, // 반응형 그리드
  adaptive,   // 어댑티브 그리드
}