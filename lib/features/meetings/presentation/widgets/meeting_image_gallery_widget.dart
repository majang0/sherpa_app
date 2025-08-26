// lib/features/meetings/presentation/widgets/meeting_image_gallery_widget.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/modern_colors.dart';
import '../../utils/meeting_image_utils.dart';
import '../../utils/meeting_animations.dart';

/// 🖼️ 모임 이미지 갤러리 위젯
/// 
/// 저장된 모임 이미지들을 로딩해서 갤러리 형태로 표시
/// 이미지 개수에 따라 자동으로 레이아웃 조정
class MeetingImageGalleryWidget extends StatefulWidget {
  final List<String> imageFileNames;
  final double? height;
  final BorderRadius? borderRadius;
  final bool showImageCount;
  final int maxDisplayCount; // 최대 표시 개수 (나머지는 +N으로 표시)

  const MeetingImageGalleryWidget({
    super.key,
    required this.imageFileNames,
    this.height = 200,
    this.borderRadius,
    this.showImageCount = true,
    this.maxDisplayCount = 4,
  });

  @override
  State<MeetingImageGalleryWidget> createState() => _MeetingImageGalleryWidgetState();
}

class _MeetingImageGalleryWidgetState extends State<MeetingImageGalleryWidget>
    with TickerProviderStateMixin, MeetingAnimationMixin {
  
  List<dynamic> _loadedImages = []; // File 또는 String(asset path) 저장
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  /// 📂 저장된 이미지들을 비동기로 로딩
  Future<void> _loadImages() async {
    if (widget.imageFileNames.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final loadedImages = <dynamic>[];
      
      for (final fileName in widget.imageFileNames) {
        // asset: 플래그로 시작하면 assets 폴더 경로 저장
        if (fileName.startsWith('asset:')) {
          final assetPath = 'assets/images/meeting/${fileName.substring(6)}';
          loadedImages.add(assetPath); // String으로 저장
        } else {
          // 일반 이미지 파일은 MeetingImageUtils 사용
          final imageFile = await MeetingImageUtils.getMeetingImageFile(fileName);
          if (imageFile != null) {
            loadedImages.add(imageFile); // File로 저장
          }
        }
      }

      if (mounted) {
        setState(() {
          _loadedImages = loadedImages;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading meeting images: $e');
      if (mounted) {
        setState(() {
          _errorMessage = '이미지 로딩 중 오류가 발생했습니다';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 이미지가 없는 경우
    if (widget.imageFileNames.isEmpty) {
      return _buildNoImagesPlaceholder();
    }

    // 로딩 중인 경우
    if (_isLoading) {
      return _buildLoadingState();
    }

    // 에러가 발생한 경우
    if (_errorMessage != null) {
      return _buildErrorState();
    }

    // 실제로 로딩된 이미지가 없는 경우
    if (_loadedImages.isEmpty) {
      return _buildNoImagesPlaceholder();
    }

    return AnimatedMeetingCard(
      fadeAnimation: fadeAnimation,
      slideAnimation: slideAnimation,
      child: _buildImageGallery(_loadedImages),
    );
  }

  /// 🖼️ 이미지 갤러리 빌드
  Widget _buildImageGallery(List<dynamic> images) {
    final displayCount = (images.length > widget.maxDisplayCount) 
        ? widget.maxDisplayCount 
        : images.length;
    
    final remainingCount = images.length - displayCount;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
        color: ModernColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
        child: Stack(
          children: [
            // 메인 이미지 그리드
            _buildImageGrid(images.take(displayCount).toList()),
            
            // 추가 이미지 개수 오버레이
            if (remainingCount > 0)
              _buildRemainingCountOverlay(remainingCount),
            
            // 이미지 개수 배지
            if (widget.showImageCount)
              _buildImageCountBadge(images.length),
          ],
        ),
      ),
    );
  }

  /// 📐 이미지 그리드 레이아웃
  Widget _buildImageGrid(List<dynamic> images) {
    switch (images.length) {
      case 1:
        return _buildSingleImage(images.first);
      case 2:
        return _buildTwoImages(images);
      case 3:
        return _buildThreeImages(images);
      case 4:
        return _buildFourImages(images);
      default:
        return _buildFourImages(images.take(4).toList());
    }
  }

  /// 이미지 위젯 생성 (File 또는 Asset)
  Widget _createImageWidget(dynamic imageData) {
    if (imageData is File) {
      return Image.file(
        imageData,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else if (imageData is String) {
      return Image.asset(
        imageData,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: ModernColors.surface,
            child: Icon(
              Icons.broken_image,
              color: ModernColors.textTertiary,
              size: 48,
            ),
          );
        },
      );
    }
    return Container();
  }

  /// 단일 이미지 레이아웃
  Widget _buildSingleImage(dynamic image) {
    return GestureDetector(
      onTap: () => _showImageViewer([image], 0),
      child: _createImageWidget(image),
    );
  }

  /// 2개 이미지 레이아웃 (세로 분할)
  Widget _buildTwoImages(List<dynamic> images) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _showImageViewer(images, 0),
            child: _createImageWidget(images[0]),
          ),
        ),
        const SizedBox(width: 2),
        Expanded(
          child: GestureDetector(
            onTap: () => _showImageViewer(images, 1),
            child: _createImageWidget(images[1]),
          ),
        ),
      ],
    );
  }

  /// 3개 이미지 레이아웃 (1:2 비율)
  Widget _buildThreeImages(List<dynamic> images) {
    return Row(
      children: [
        // 왼쪽 큰 이미지
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () => _showImageViewer(images, 0),
            child: _createImageWidget(images[0]),
          ),
        ),
        const SizedBox(width: 2),
        // 오른쪽 2개 작은 이미지
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showImageViewer(images, 1),
                  child: _createImageWidget(images[1]),
                ),
              ),
              const SizedBox(height: 2),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showImageViewer(images, 2),
                  child: _createImageWidget(images[2]),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 4개 이미지 레이아웃 (2x2 그리드)
  Widget _buildFourImages(List<dynamic> images) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showImageViewer(images, 0),
                  child: _createImageWidget(images[0]),
                ),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showImageViewer(images, 1),
                  child: _createImageWidget(images[1]),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _showImageViewer(images, 2),
                  child: _createImageWidget(images[2]),
                ),
              ),
              const SizedBox(width: 2),
              if (images.length > 3)
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showImageViewer(_loadedImages, 3),
                    child: _createImageWidget(images[3]),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// 추가 이미지 개수 오버레이
  Widget _buildRemainingCountOverlay(int remainingCount) {
    return Positioned(
      bottom: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '+$remainingCount',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// 이미지 개수 배지
  Widget _buildImageCountBadge(int count) {
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: ModernColors.primary.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  /// 이미지가 없는 경우 플레이스홀더
  Widget _buildNoImagesPlaceholder() {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
        color: ModernColors.surface,
        border: Border.all(
          color: ModernColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 48,
            color: ModernColors.textTertiary,
          ),
          const SizedBox(height: 8),
          Text(
            '등록된 이미지가 없습니다',
            style: TextStyle(
              color: ModernColors.textTertiary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 로딩 상태
  Widget _buildLoadingState() {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
        color: ModernColors.surface,
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ModernColors.primary),
        ),
      ),
    );
  }

  /// 에러 상태
  Widget _buildErrorState() {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
        color: ModernColors.surface,
        border: Border.all(
          color: ModernColors.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: ModernColors.error,
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? '이미지 로딩 실패',
            style: TextStyle(
              color: ModernColors.error,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 이미지 뷰어 표시 (전체화면)
  void _showImageViewer(List<dynamic> images, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _FullScreenImageViewer(
          images: images,
          initialIndex: initialIndex,
        ),
        fullscreenDialog: true,
      ),
    );
  }
}

/// 🔍 전체화면 이미지 뷰어
class _FullScreenImageViewer extends StatelessWidget {
  final List<dynamic> images;
  final int initialIndex;

  const _FullScreenImageViewer({
    required this.images,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${initialIndex + 1} / ${images.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: images.length,
        itemBuilder: (context, index) {
          final imageData = images[index];
          Widget imageWidget;
          
          if (imageData is File) {
            imageWidget = Image.file(
              imageData,
              fit: BoxFit.contain,
            );
          } else if (imageData is String) {
            imageWidget = Image.asset(
              imageData,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.white54,
                    size: 64,
                  ),
                );
              },
            );
          } else {
            imageWidget = Container();
          }
          
          return InteractiveViewer(
            child: Center(
              child: imageWidget,
            ),
          );
        },
      ),
    );
  }
}