import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/available_meeting_model.dart';

/// 📱 모임 카드 위젯 - 한국형 모임앱 스타일
/// 깔끔하고 직관적인 모임 정보 표시에 집중한 카드 UI
class MeetingCardWidget extends StatelessWidget {
  final AvailableMeeting meeting;
  final VoidCallback onTap;

  const MeetingCardWidget({
    super.key,
    required this.meeting,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🖼️ 상단: 썸네일 이미지 영역 (한국앱 패턴: 큰 썸네일)
              _buildThumbnailSection(),
              
              // 📝 중앙: 모임 정보 영역
              _buildContentSection(),
              
              // 📊 하단: 참여 정보 및 액션 영역
              _buildActionSection(),
            ],
          ),
        ),
      ),
    );
  }

  /// 🖼️ 썸네일 섹션 (1:1 비율 이미지 디자인)
  Widget _buildThumbnailSection() {
    return AspectRatio(
      aspectRatio: 1.0, // 1:1 비율 강제 적용
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: meeting.category.color,
        ),
        child: Stack(
          children: [
            // 🖼️ 1:1 배경 이미지 (샘플 이미지 패턴)
            Positioned.fill(
              child: _build1to1Image(),
            ),
            
            // 🌈 그라데이션 오버레이
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
              ),
            ),
            
            // 상단 태그들
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  _buildCategoryTag(),
                  const Spacer(),
                  _buildStatusBadge(),
                ],
              ),
            ),
            
            // 중앙 카테고리 아이콘 (1:1 비율에 맞게 조정)
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    meeting.category.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
            ),
            
            // 하단 대학교 태그 (있는 경우)
            if (meeting.scope == MeetingScope.university && 
                meeting.universityName != null)
              Positioned(
                bottom: 12,
                left: 12,
                child: _buildUniversityTag(),
              ),
          ],
        ),
      ),
    );
  }

  /// 🖼️ 1:1 비율 배경 이미지 (카테고리별 샘플 패턴)
  Widget _build1to1Image() {
    // 카테고리별 샘플 이미지 패턴 생성
    String backgroundPattern = _getCategoryImagePattern();
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            meeting.category.color.withOpacity(0.7),
            meeting.category.color,
            meeting.category.color.withOpacity(0.9),
          ],
        ),
      ),
      child: Stack(
        children: [
          // 📐 기하학적 패턴 (1:1 비율에 최적화)
          Positioned.fill(
            child: CustomPaint(
              painter: GeometricPatternPainter(
                color: Colors.white.withOpacity(0.1),
                category: meeting.category,
              ),
            ),
          ),
          
          // 🎭 카테고리별 텍스처 효과
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.3, -0.3),
                  radius: 1.2,
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.transparent,
                    meeting.category.color.withOpacity(0.3),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🎨 카테고리별 이미지 패턴 결정
  String _getCategoryImagePattern() {
    switch (meeting.category) {
      case MeetingCategory.exercise:
      case MeetingCategory.outdoor:
        return 'sports_pattern'; // 운동/아웃도어 패턴
      case MeetingCategory.study:
      case MeetingCategory.reading:
        return 'study_pattern'; // 스터디/독서 패턴
      case MeetingCategory.networking:
      case MeetingCategory.culture:
        return 'social_pattern'; // 네트워킹/문화 패턴
      case MeetingCategory.all:
      default:
        return 'general_pattern'; // 일반 패턴
    }
  }

  /// 📝 컨텐츠 섹션
  Widget _buildContentSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 (큰 폰트, 볼드)
          Text(
            meeting.title,
            style: GoogleFonts.notoSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 6),
          
          // 설명 (간결하게)
          Text(
            meeting.description,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 12),
          
          // 정보 아이템들 (아이콘 + 텍스트 조합)
          _buildInfoRow(),
        ],
      ),
    );
  }

  /// 📊 액션 섹션
  Widget _buildActionSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          // 참가자 정보 바
          _buildParticipantBar(),
          
          const SizedBox(height: 12),
          
          // 참여 버튼
          _buildJoinButton(),
        ],
      ),
    );
  }

  /// 🏷️ 카테고리 태그
  Widget _buildCategoryTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            meeting.category.emoji,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 4),
          Text(
            meeting.category.displayName,
            style: GoogleFonts.notoSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: meeting.category.color,
            ),
          ),
        ],
      ),
    );
  }

  /// 🏫 대학교 태그
  Widget _buildUniversityTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🏫', style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 4),
          Text(
            meeting.universityName!,
            style: GoogleFonts.notoSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  /// 🏷️ 상태 배지
  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: meeting.statusColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        meeting.status,
        style: GoogleFonts.notoSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  /// 📍 정보 행
  Widget _buildInfoRow() {
    return Row(
      children: [
        // 위치
        Expanded(
          child: _buildInfoItem(
            icon: Icons.location_on_rounded,
            text: meeting.location,
            color: AppColors.primary,
          ),
        ),
        
        const SizedBox(width: 12),
        
        // 날짜/시간
        Expanded(
          child: _buildInfoItem(
            icon: Icons.schedule_rounded,
            text: meeting.formattedDate,
            color: AppColors.accent,
          ),
        ),
      ],
    );
  }

  /// 📍 개별 정보 아이템
  Widget _buildInfoItem({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// 👥 참가자 정보 바
  Widget _buildParticipantBar() {
    final ratio = meeting.participationRate;
    final remainingSpots = meeting.maxParticipants - meeting.currentParticipants;
    
    return Row(
      children: [
        // 참가자 아이콘
        Icon(
          Icons.people_rounded,
          size: 16,
          color: ratio >= 0.8 ? AppColors.warning : AppColors.success,
        ),
        
        const SizedBox(width: 6),
        
        // 참가자 수 텍스트
        Text(
          '${meeting.currentParticipants}명 참여',
          style: GoogleFonts.notoSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        
        const SizedBox(width: 8),
        
        // 참가자 진행 바
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: ratio,
              child: Container(
                decoration: BoxDecoration(
                  color: ratio >= 0.8 ? AppColors.warning : AppColors.success,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 8),
        
        // 남은 자리 텍스트
        Text(
          remainingSpots > 0 ? '$remainingSpots자리 남음' : '마감',
          style: GoogleFonts.notoSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: remainingSpots > 0 ? AppColors.textSecondary : AppColors.error,
          ),
        ),
      ],
    );
  }

  /// 🎯 참여 버튼 (한국앱 스타일)
  Widget _buildJoinButton() {
    final canJoin = meeting.canJoin;
    final actualPrice = meeting.price ?? 0;
    final isFree = meeting.type == MeetingType.free;
    
    return SizedBox(
      width: double.infinity,
      height: 44, // 한국앱 표준 버튼 높이
      child: ElevatedButton(
        onPressed: canJoin ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canJoin 
              ? meeting.category.color 
              : Colors.grey.shade300,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade500,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (canJoin) ...[
              Icon(
                isFree ? Icons.add_rounded : Icons.payments_rounded,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                isFree ? '무료 참여' : '${actualPrice.toStringAsFixed(0)} 포인트',
                style: GoogleFonts.notoSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ] else ...[
              Icon(Icons.block_rounded, size: 18),
              const SizedBox(width: 8),
              Text(
                meeting.status,
                style: GoogleFonts.notoSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 🎨 기하학적 패턴 페인터 (1:1 비율 최적화)
class GeometricPatternPainter extends CustomPainter {
  final Color color;
  final MeetingCategory category;

  GeometricPatternPainter({
    required this.color,
    required this.category,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // 1:1 정사각형 기준으로 패턴 생성
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final minSize = size.width < size.height ? size.width : size.height;

    switch (category) {
      case MeetingCategory.exercise:
      case MeetingCategory.outdoor:
        _drawSportsPattern(canvas, paint, centerX, centerY, minSize);
        break;
      case MeetingCategory.study:
      case MeetingCategory.reading:
        _drawStudyPattern(canvas, paint, centerX, centerY, minSize);
        break;
      case MeetingCategory.networking:
      case MeetingCategory.culture:
        _drawSocialPattern(canvas, paint, centerX, centerY, minSize);
        break;
      case MeetingCategory.all:
      default:
        _drawGeneralPattern(canvas, paint, centerX, centerY, minSize);
        break;
    }
  }

  /// 💪 액티브/스포츠 패턴
  void _drawSportsPattern(Canvas canvas, Paint paint, double centerX, double centerY, double size) {
    // 다이아몬드 그리드 패턴
    final gridSize = size / 8;
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        final x = (i * gridSize) + (gridSize / 2);
        final y = (j * gridSize) + (gridSize / 2);
        
        // 다이아몬드 모양
        final path = Path();
        path.moveTo(x, y - gridSize * 0.2);
        path.lineTo(x + gridSize * 0.2, y);
        path.lineTo(x, y + gridSize * 0.2);
        path.lineTo(x - gridSize * 0.2, y);
        path.close();
        
        canvas.drawPath(path, paint);
      }
    }
  }

  /// 📚 학습/스터디 패턴
  void _drawStudyPattern(Canvas canvas, Paint paint, double centerX, double centerY, double size) {
    // 책 페이지 형태의 선형 패턴
    final lineSpacing = size / 16;
    for (int i = 0; i < 16; i++) {
      final y = i * lineSpacing;
      final startX = (i % 2 == 0) ? 0.0 : size * 0.1;
      final endX = (i % 2 == 0) ? size * 0.9 : size;
      
      canvas.drawLine(
        Offset(startX, y),
        Offset(endX, y),
        paint,
      );
    }
    
    // 세로 구분선
    canvas.drawLine(
      Offset(size * 0.15, 0),
      Offset(size * 0.15, size),
      paint,
    );
  }

  /// 🤝 소셜/네트워킹 패턴
  void _drawSocialPattern(Canvas canvas, Paint paint, double centerX, double centerY, double size) {
    // 연결된 원들의 네트워크 패턴
    final nodePositions = [
      Offset(size * 0.2, size * 0.2),
      Offset(size * 0.8, size * 0.3),
      Offset(size * 0.3, size * 0.7),
      Offset(size * 0.7, size * 0.8),
      Offset(size * 0.5, size * 0.5),
    ];
    
    // 연결선
    paint.strokeWidth = 1.0;
    for (int i = 0; i < nodePositions.length; i++) {
      for (int j = i + 1; j < nodePositions.length; j++) {
        canvas.drawLine(nodePositions[i], nodePositions[j], paint);
      }
    }
    
    // 노드 원들
    paint.style = PaintingStyle.fill;
    for (final pos in nodePositions) {
      canvas.drawCircle(pos, size * 0.025, paint);
    }
  }

  /// 🌟 일반 패턴
  void _drawGeneralPattern(Canvas canvas, Paint paint, double centerX, double centerY, double size) {
    // 동심원 패턴
    final circleCount = 5;
    paint.style = PaintingStyle.stroke;
    for (int i = 1; i <= circleCount; i++) {
      final radius = (size / 2) * (i / circleCount) * 0.8;
      canvas.drawCircle(Offset(centerX, centerY), radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}