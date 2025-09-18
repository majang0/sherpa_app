import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/modern_colors.dart';
import '../../../../shared/widgets/sherpa_clean_app_bar.dart';
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_point_provider.dart';
import '../../models/available_meeting_model.dart';
import '../../utils/meeting_animations.dart';
import '../../utils/meeting_image_utils.dart';

/// 🏔️ 모임 세부사항 화면
/// RPG 퀘스트 상세 정보 페이지 컨셉으로 설계
class AvailableMeetingDetailScreen extends ConsumerStatefulWidget {
  final AvailableMeeting meeting;

  const AvailableMeetingDetailScreen({
    super.key,
    required this.meeting,
  });

  @override
  ConsumerState<AvailableMeetingDetailScreen> createState() =>
      _AvailableMeetingDetailScreenState();
}

class _MeetingImageFullScreenViewer extends StatelessWidget {
  final List<dynamic> images;
  final int initialIndex;

  const _MeetingImageFullScreenViewer({
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
                return const Center(
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.white54,
                    size: 64,
                  ),
                );
              },
            );
          } else {
            imageWidget = const SizedBox.shrink();
          }

          return InteractiveViewer(
            child: Center(child: imageWidget),
          );
        },
      ),
    );
  }
}

class _AvailableMeetingDetailScreenState
    extends ConsumerState<AvailableMeetingDetailScreen>
    with TickerProviderStateMixin, MeetingAnimationMixin {
  late Future<List<dynamic>> _galleryImagesFuture;

  // 🚀 성능 최적화된 애니메이션 지속시간 오버라이드
  @override
  Duration get animationDuration => MeetingAnimations.slowDuration;

  @override
  void initState() {
    super.initState();
    _galleryImagesFuture = _loadMeetingImages(widget.meeting.imageFileNames);
  }

  @override
  void didUpdateWidget(covariant AvailableMeetingDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.meeting.id != widget.meeting.id) {
      _galleryImagesFuture = _loadMeetingImages(widget.meeting.imageFileNames);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPoints = ref.watch(globalTotalPointsProvider);

    return Scaffold(
      backgroundColor: ModernColors.background,
      appBar: SherpaCleanAppBar(
        title: '모험 세부사항',
      ),
      body: AnimatedMeetingCard(
        fadeAnimation: fadeAnimation,
        slideAnimation: slideAnimation,
        child: CustomScrollView(
          slivers: [
            // 🎨 메인 헤더 (그라데이션 배경)
            _buildMainHeader(),

            // 📝 상세 정보 섹션들
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🖼️ 모임 이미지 갤러리 (이미지가 있는 경우만 표시)
                    if (widget.meeting.hasImages) ...[
                      _buildMeetingImageGallerySection(),
                      const SizedBox(height: 20),
                    ],

                    // 기본 정보 카드
                    _buildMeetingInfoCard(),

                    const SizedBox(height: 20),

                    // 호스트 및 참가자 정보
                    _buildMeetingParticipantsCard(),

                    const SizedBox(height: 20),

                    // 참여 조건 및 준비물
                    _buildMeetingRequirementsCard(),

                    const SizedBox(height: 20),

                    // 위치 및 교통 정보
                    _buildLocationInfo(),

                    const SizedBox(height: 20),

                    // 포인트 안내
                    _buildPointInfo(currentPoints),

                    const SizedBox(height: 100), // 하단 버튼 공간
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // 🎯 하단 고정 액션 버튼
      bottomNavigationBar: _buildBottomActionBar(currentPoints),
    );
  }

  Widget _buildMeetingImageGallerySection() {
    const galleryHeight = 220.0;
    final borderRadius = BorderRadius.circular(16);

    return FutureBuilder<List<dynamic>>(
      future: _galleryImagesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildGalleryLoadingState(galleryHeight, borderRadius);
        }

        if (snapshot.hasError) {
          return _buildGalleryErrorState(
            height: galleryHeight,
            borderRadius: borderRadius,
            message: snapshot.error?.toString() ?? '이미지를 불러오지 못했습니다',
          );
        }

        final images = snapshot.data ?? const [];
        if (images.isEmpty) {
          return _buildGalleryPlaceholder(galleryHeight, borderRadius);
        }

        final displayCount = images.length > 4 ? 4 : images.length;
        final displayImages = images.take(displayCount).toList();

        return Container(
          height: galleryHeight,
          decoration: BoxDecoration(
            borderRadius: borderRadius,
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
            borderRadius: borderRadius,
            child: Stack(
              children: [
                _buildImageGrid(displayImages, images),
                if (images.length > displayCount)
                  _buildRemainingCountOverlay(images.length - displayCount),
                _buildImageCountBadge(images.length),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageGrid(
      List<dynamic> displayImages, List<dynamic> fullImages) {
    switch (displayImages.length) {
      case 1:
        return _buildSingleImage(displayImages.first, fullImages, 0);
      case 2:
        return _buildTwoImages(displayImages, fullImages);
      case 3:
        return _buildThreeImages(displayImages, fullImages);
      case 4:
        return _buildFourImages(displayImages, fullImages);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSingleImage(dynamic image, List<dynamic> fullImages, int index) {
    return _buildTappableImage(image, fullImages, index);
  }

  Widget _buildTwoImages(List<dynamic> images, List<dynamic> fullImages) {
    return Row(
      children: [
        Expanded(child: _buildTappableImage(images[0], fullImages, 0)),
        const SizedBox(width: 2),
        Expanded(child: _buildTappableImage(images[1], fullImages, 1)),
      ],
    );
  }

  Widget _buildThreeImages(List<dynamic> images, List<dynamic> fullImages) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildTappableImage(images[0], fullImages, 0),
        ),
        const SizedBox(width: 2),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Expanded(child: _buildTappableImage(images[1], fullImages, 1)),
              const SizedBox(height: 2),
              Expanded(child: _buildTappableImage(images[2], fullImages, 2)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFourImages(List<dynamic> images, List<dynamic> fullImages) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildTappableImage(images[0], fullImages, 0)),
              const SizedBox(width: 2),
              Expanded(child: _buildTappableImage(images[1], fullImages, 1)),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildTappableImage(images[2], fullImages, 2)),
              const SizedBox(width: 2),
              Expanded(child: _buildTappableImage(images[3], fullImages, 3)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTappableImage(
    dynamic image,
    List<dynamic> fullImages,
    int index,
  ) {
    return GestureDetector(
      onTap: () => _showImageViewer(fullImages, index),
      child: _createImageWidget(image),
    );
  }

  Widget _createImageWidget(dynamic imageData) {
    if (imageData is File) {
      return Image.file(
        imageData,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    if (imageData is String) {
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

    return Container(color: ModernColors.surface);
  }

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

  Widget _buildGalleryPlaceholder(double height, BorderRadius borderRadius) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
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

  Widget _buildGalleryLoadingState(
    double height,
    BorderRadius borderRadius,
  ) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: ModernColors.surface,
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ModernColors.primary),
        ),
      ),
    );
  }

  Widget _buildGalleryErrorState({
    required double height,
    required BorderRadius borderRadius,
    required String message,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
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
            message,
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

  Future<List<dynamic>> _loadMeetingImages(List<String> fileNames) async {
    if (fileNames.isEmpty) {
      return const [];
    }

    final results = <dynamic>[];
    for (final fileName in fileNames) {
      if (fileName.startsWith('asset:')) {
        results.add('assets/images/meeting/${fileName.substring(6)}');
      } else {
        final imageFile = await MeetingImageUtils.getMeetingImageFile(fileName);
        if (imageFile != null) {
          results.add(imageFile);
        }
      }
    }
    return results;
  }

  void _showImageViewer(List<dynamic> images, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _MeetingImageFullScreenViewer(
          images: images,
          initialIndex: initialIndex,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  Widget _buildMeetingInfoCard() {
    final meeting = widget.meeting;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📋 모임 정보',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: ModernColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.event_rounded,
            label: '일시',
            value: meeting.formattedDate,
            color: ModernColors.primary,
          ),
          const SizedBox(height: 12),
          if (meeting.isRecurring) ...[
            _buildInfoRow(
              icon: Icons.repeat_rounded,
              label: '반복',
              value: '정기 모임',
              color: ModernColors.accent,
            ),
            const SizedBox(height: 12),
          ],
          _buildInfoRow(
            icon: meeting.type == MeetingType.free
                ? Icons.monetization_on_outlined
                : Icons.attach_money_rounded,
            label: '유형',
            value: meeting.type.displayName,
            color: meeting.type == MeetingType.free
                ? ModernColors.success
                : ModernColors.warning,
          ),
          const SizedBox(height: 12),
          if (meeting.type == MeetingType.paid && meeting.price != null) ...[
            _buildInfoRow(
              icon: Icons.payments_rounded,
              label: '참가비',
              value: '${meeting.price!.toStringAsFixed(0)}원',
              color: ModernColors.warning,
            ),
            const SizedBox(height: 12),
          ],
          _buildInfoRow(
            icon: Icons.people_rounded,
            label: '참가자',
            value: '${meeting.currentParticipants}/${meeting.maxParticipants}명',
            color: meeting.participationRate >= 0.8
                ? ModernColors.warning
                : ModernColors.success,
          ),
          if (meeting.tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              '🏷️ 태그',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ModernColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: meeting.tags
                  .map((tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: meeting.category.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '#$tag',
                          style: GoogleFonts.notoSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: meeting.category.color,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  color: ModernColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMeetingParticipantsCard() {
    final meeting = widget.meeting;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '👥 참가자 정보',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: ModernColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildHostInfo(meeting),
          const SizedBox(height: 20),
          _buildParticipantStatus(meeting),
          const SizedBox(height: 16),
          _buildParticipantAvatars(meeting),
        ],
      ),
    );
  }

  Widget _buildHostInfo(AvailableMeeting meeting) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            meeting.category.color.withValues(alpha: 0.1),
            meeting.category.color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: meeting.category.color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  meeting.category.color.withValues(alpha: 0.8),
                  meeting.category.color.withValues(alpha: 0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(
                meeting.hostName.isNotEmpty ? meeting.hostName[0] : 'H',
                style: GoogleFonts.notoSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: meeting.category.color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '👑 호스트',
                    style: GoogleFonts.notoSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  meeting.hostName,
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ModernColors.textPrimary,
                  ),
                ),
                Text(
                  '모임 주최자',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: ModernColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${meeting.hostName} 프로필 보기 (구현 예정)'),
                  backgroundColor: ModernColors.primary,
                ),
              );
            },
            icon: const Icon(Icons.arrow_forward_ios_rounded),
            iconSize: 16,
            color: ModernColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantStatus(AvailableMeeting meeting) {
    final ratio = meeting.participationRate;
    final statusText = ratio >= 0.8
        ? '🔥 인기 모임! 마감 임박'
        : ratio >= 0.5
            ? '✨ 적당한 인원 모집 중'
            : '🌟 여유롭게 참가 가능';

    final statusColor =
        ratio >= 0.8 ? ModernColors.warning : ModernColors.success;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '참가 현황',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ModernColors.textPrimary,
              ),
            ),
            Text(
              '${meeting.currentParticipants}/${meeting.maxParticipants}',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: statusColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: ratio.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: ratio >= 0.8
                      ? [
                          ModernColors.warning,
                          ModernColors.warning.withValues(alpha: 0.7),
                        ]
                      : [
                          ModernColors.success,
                          ModernColors.success.withValues(alpha: 0.7),
                        ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          statusText,
          style: GoogleFonts.notoSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: statusColor,
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantAvatars(AvailableMeeting meeting) {
    final mockParticipants = List.generate(
      meeting.currentParticipants.clamp(0, 6),
      (index) => 'User${index + 1}',
    );

    if (mockParticipants.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Row(
          children: [
            Icon(
              Icons.people_outline_rounded,
              color: Colors.grey.shade400,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '아직 참가자가 없어요. 첫 번째 참가자가 되어보세요!',
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '참가자 목록',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ModernColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...mockParticipants
                .asMap()
                .entries
                .map((entry) => _buildParticipantAvatar(entry.value)),
            if (meeting.currentParticipants > 6)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: Center(
                  child: Text(
                    '+${meeting.currentParticipants - 6}',
                    style: GoogleFonts.notoSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: ModernColors.textSecondary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildParticipantAvatar(String name) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withValues(alpha: 0.7),
            Colors.purple.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0] : 'U',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildMeetingRequirementsCard() {
    final meeting = widget.meeting;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📝 참여 안내',
            style: GoogleFonts.notoSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: ModernColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildRequirementsSection(meeting),
          const SizedBox(height: 20),
          _buildConditionsSection(meeting),
          const SizedBox(height: 20),
          _buildNoticesSection(meeting),
        ],
      ),
    );
  }

  Widget _buildRequirementsSection(AvailableMeeting meeting) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: ModernColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.backpack_rounded,
                size: 16,
                color: ModernColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '준비물',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: ModernColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (meeting.requirements.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: ModernColors.success,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '특별한 준비물이 필요하지 않아요',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: ModernColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          )
        else
          ...meeting.requirements.map(
            (requirement) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: ModernColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      requirement,
                      style: GoogleFonts.notoSans(
                        fontSize: 13,
                        color: ModernColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildConditionsSection(AvailableMeeting meeting) {
    final conditions = _getConditions(meeting);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: ModernColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.rule_rounded,
                size: 16,
                color: ModernColors.accent,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '참여 조건',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: ModernColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...conditions.map(
          (condition) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_rounded,
                  color: ModernColors.success,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    condition,
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      color: ModernColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoticesSection(AvailableMeeting meeting) {
    final notices = _getNotices(meeting);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: ModernColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: ModernColors.warning,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '주의사항',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: ModernColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...notices.map(
          (notice) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: ModernColors.warning,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    notice,
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      color: ModernColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<String> _getConditions(AvailableMeeting meeting) {
    final conditions = <String>[
      '모임 시간 10분 전까지 도착',
      '다른 참가자들과 친근하게 대화',
    ];

    switch (meeting.category) {
      case MeetingCategory.exercise:
        conditions.addAll(['운동 가능한 복장 착용', '본인의 체력 수준 고려']);
        break;
      case MeetingCategory.study:
        conditions.addAll(['적극적인 토론 참여', '필기도구 지참']);
        break;
      case MeetingCategory.reading:
        conditions.addAll(['해당 책 미리 읽고 참석', '토론 주제 1개 이상 준비']);
        break;
      case MeetingCategory.networking:
        conditions.addAll(['명함 또는 자기소개 준비', '적극적인 네트워킹 참여']);
        break;
      case MeetingCategory.culture:
        conditions.addAll(['시간 엄수', '관람 예절 준수']);
        break;
      case MeetingCategory.outdoor:
        conditions.addAll(['날씨에 맞는 복장', '안전 수칙 준수']);
        break;
      case MeetingCategory.all:
        conditions.add('모임 주제에 관심과 열정');
        break;
    }

    if (meeting.type == MeetingType.paid) {
      conditions.add('별도 참가비 현장 결제');
    }

    return conditions;
  }

  List<String> _getNotices(AvailableMeeting meeting) {
    final notices = <String>[
      '모임 시간 변경이나 취소 시 24시간 전 공지',
      '무단 불참 시 향후 모임 참여에 제한이 있을 수 있음',
      '모임 중 촬영된 사진은 홍보용으로 사용될 수 있음',
    ];

    switch (meeting.category) {
      case MeetingCategory.exercise:
        notices.addAll(['운동 중 부상 발생 시 개인 책임', '컨디션이 좋지 않을 때는 무리하지 말 것']);
        break;
      case MeetingCategory.study:
        notices.add('시끄럽게 하거나 다른 사람에게 방해되는 행동 금지');
        break;
      case MeetingCategory.reading:
        notices.add('해당 책을 미리 읽지 않으면 토론 참여 불가');
        break;
      case MeetingCategory.networking:
        notices.add('과도한 영업이나 홍보 활동 자제');
        break;
      case MeetingCategory.culture:
        notices.addAll(['공연 중 휴대폰 무음 필수', '중간 퇴장 금지']);
        break;
      case MeetingCategory.outdoor:
        notices.addAll(['날씨 악화 시 일정 변경 가능', '안전사고 발생 시 개인 책임']);
        break;
      case MeetingCategory.all:
        break;
    }

    if (meeting.scope == MeetingScope.university) {
      notices.addAll(['같은 학교 학생만 참여 가능', '학생증 지참 필수']);
    }

    return notices;
  }

  /// 🎨 메인 헤더 (히어로 섹션)
  Widget _buildMainHeader() {
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: false,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.meeting.category.color.withValues(alpha: 0.8),
                widget.meeting.category.color.withValues(alpha: 0.6),
                widget.meeting.category.color.withValues(alpha: 0.4),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 카테고리 및 상태 태그
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(widget.meeting.category.emoji,
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            widget.meeting.category.displayName,
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color:
                            widget.meeting.statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              widget.meeting.statusColor.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        widget.meeting.status,
                        style: GoogleFonts.notoSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 제목
                Text(
                  widget.meeting.title,
                  style: GoogleFonts.notoSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 12),

                // 설명
                Text(
                  widget.meeting.description,
                  style: GoogleFonts.notoSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const Spacer(),

                // 기본 정보 요약
                Row(
                  children: [
                    _buildQuickInfo(
                      icon: Icons.schedule_rounded,
                      text: widget.meeting.formattedDate,
                    ),
                    const SizedBox(width: 20),
                    _buildQuickInfo(
                      icon: Icons.people_rounded,
                      text:
                          '${widget.meeting.currentParticipants}/${widget.meeting.maxParticipants}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 📍 빠른 정보 아이템
  Widget _buildQuickInfo({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.9)),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.notoSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  /// 🗺️ 위치 정보 카드
  Widget _buildLocationInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: ModernColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '만날 장소',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            widget.meeting.location,
            style: GoogleFonts.notoSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: ModernColors.textPrimary,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            widget.meeting.detailedLocation,
            style: GoogleFonts.notoSans(
              fontSize: 13,
              color: ModernColors.textSecondary,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 16),

          // 길찾기 버튼
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: 지도 앱 연동
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('지도 앱으로 길찾기 (구현 예정)'),
                    backgroundColor: ModernColors.primary,
                  ),
                );
              },
              icon: const Icon(Icons.directions_rounded),
              label: Text(
                '길찾기',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: ModernColors.primary,
                side: BorderSide(color: ModernColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 💰 포인트 안내 카드
  Widget _buildPointInfo(int currentPoints) {
    final fee = widget.meeting.participationFee;
    final hasEnoughPoints = currentPoints >= fee;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasEnoughPoints
              ? [
                  ModernColors.success.withValues(alpha: 0.1),
                  ModernColors.success.withValues(alpha: 0.05)
                ]
              : [
                  ModernColors.warning.withValues(alpha: 0.1),
                  ModernColors.warning.withValues(alpha: 0.05)
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasEnoughPoints
              ? ModernColors.success.withValues(alpha: 0.2)
              : ModernColors.warning.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                color: hasEnoughPoints
                    ? ModernColors.success
                    : ModernColors.warning,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '참여 비용',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '참여 수수료',
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      color: ModernColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${fee.toString()} P',
                    style: GoogleFonts.notoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: hasEnoughPoints
                          ? ModernColors.success
                          : ModernColors.warning,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '보유 포인트',
                    style: GoogleFonts.notoSans(
                      fontSize: 13,
                      color: ModernColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${currentPoints.toString()} P',
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ModernColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (!hasEnoughPoints) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ModernColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: ModernColors.warning,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '포인트가 부족합니다. 퀘스트나 일일 목표를 완료해보세요!',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: ModernColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
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

  /// 🎯 하단 액션 바
  Widget _buildBottomActionBar(int currentPoints) {
    final canJoin = widget.meeting.canJoin;
    final hasEnoughPoints = currentPoints >= widget.meeting.participationFee;
    final shouldEnable = canJoin && hasEnoughPoints;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: shouldEnable ? _handleJoinMeeting : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: shouldEnable
                  ? widget.meeting.category.color
                  : Colors.grey.shade300,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              disabledBackgroundColor: Colors.grey.shade300,
              disabledForegroundColor: Colors.grey.shade500,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (shouldEnable) ...[
                  const Icon(Icons.add_rounded, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    '모험에 참여하기',
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ] else ...[
                  const Icon(Icons.block_rounded, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    !canJoin ? widget.meeting.status : '포인트 부족',
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🎯 모임 참여 처리
  void _handleJoinMeeting() {
    Navigator.pushNamed(
      context,
      '/meeting_application',
      arguments: {'meetingId': widget.meeting.id},
    );
  }
}
