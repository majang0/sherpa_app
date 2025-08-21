// lib/shared/widgets/components/molecules/participant_avatars_2025.dart

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors_2025.dart';

/// 모임 참가자 프로필을 겹친 원형으로 표시하는 2025 트렌드 위젯
class ParticipantAvatars2025 extends StatelessWidget {
  final int currentParticipants;
  final int maxParticipants;
  final List<String>? participantNames;
  final List<String>? participantImages;
  final double size;
  final double overlapFactor;
  final int maxVisible;
  
  const ParticipantAvatars2025({
    super.key,
    required this.currentParticipants,
    required this.maxParticipants,
    this.participantNames,
    this.participantImages,
    this.size = 32,
    this.overlapFactor = 0.7,
    this.maxVisible = 3,
  });

  @override
  Widget build(BuildContext context) {
    if (currentParticipants == 0) {
      return _buildEmptyState();
    }

    final visibleCount = currentParticipants > maxVisible ? maxVisible : currentParticipants;
    final remainingCount = currentParticipants > maxVisible ? currentParticipants - maxVisible : 0;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: _calculateTotalWidth(visibleCount, remainingCount > 0),
          height: size,
          child: Stack(
            children: [
              // 참가자 아바타들
              ...List.generate(visibleCount, (index) {
                return Positioned(
                  left: index * size * overlapFactor,
                  child: _buildAvatar(
                    index: index,
                    name: _getParticipantName(index),
                    imageUrl: _getParticipantImage(index),
                  ),
                );
              }),
              
              // 나머지 참가자 수 표시
              if (remainingCount > 0)
                Positioned(
                  left: visibleCount * size * overlapFactor,
                  child: _buildMoreIndicator(remainingCount),
                ),
            ],
          ),
        ),
        
        const SizedBox(width: 8),
        
        // 참가자 수 텍스트
        _buildParticipantText(),
      ],
    );
  }

  Widget _buildAvatar({
    required int index,
    required String name,
    String? imageUrl,
  }) {
    final isDark = false; // Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getAvatarColor(index),
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: imageUrl != null && imageUrl.isNotEmpty
        ? ClipRRect(
            borderRadius: BorderRadius.circular(size / 2),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildInitialAvatar(name, index);
              },
            ),
          )
        : _buildInitialAvatar(name, index),
    );
  }

  Widget _buildInitialAvatar(String name, int index) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildMoreIndicator(int count) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors2025.textSecondary,
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '+$count',
          style: TextStyle(
            fontSize: size * 0.3,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildParticipantText() {
    final isDark = false; // Theme.of(context).brightness == Brightness.dark;
    final isNearFull = currentParticipants / maxParticipants > 0.8;
    
    return Text(
      '$currentParticipants/$maxParticipants명',
      style: TextStyle(
        fontSize: size * 0.375, // 12px when size is 32
        fontWeight: FontWeight.w600,
        color: isNearFull 
          ? AppColors2025.warning 
          : (isDark ? Colors.white70 : AppColors2025.textSecondary),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors2025.border,
            borderRadius: BorderRadius.circular(size / 2),
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.person_outline,
            size: 16,
            color: AppColors2025.textTertiary,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '0/$maxParticipants명',
          style: TextStyle(
            fontSize: size * 0.375,
            fontWeight: FontWeight.w600,
            color: AppColors2025.textTertiary,
          ),
        ),
      ],
    );
  }

  double _calculateTotalWidth(int visibleCount, bool hasMore) {
    if (visibleCount == 0) return size;
    
    double width = size; // 첫 번째 아바타
    width += (visibleCount - 1) * size * overlapFactor; // 겹친 아바타들
    
    if (hasMore) {
      width += size * overlapFactor; // +N 표시
    }
    
    return width;
  }

  String _getParticipantName(int index) {
    if (participantNames != null && index < participantNames!.length) {
      return participantNames![index];
    }
    
    // 더미 이름들
    final dummyNames = [
      '김민수', '이영희', '박철수', '정미영', '최준호', 
      '송하나', '윤지수', '장태영', '임소라', '한동준'
    ];
    
    return index < dummyNames.length ? dummyNames[index] : '참가자${index + 1}';
  }

  String? _getParticipantImage(int index) {
    if (participantImages != null && index < participantImages!.length) {
      return participantImages![index];
    }
    return null;
  }

  Color _getAvatarColor(int index) {
    final colors = [
      AppColors2025.primary,
      AppColors2025.meeting2025,
      AppColors2025.exercise2025,
      AppColors2025.reading2025,
      AppColors2025.focus2025,
      AppColors2025.diary2025,
    ];
    
    return colors[index % colors.length];
  }
}

/// 간단한 참가자 수만 표시하는 컴팩트 버전
class ParticipantCount2025 extends StatelessWidget {
  final int currentParticipants;
  final int maxParticipants;
  final double fontSize;
  final Color? textColor;
  final IconData icon;
  
  const ParticipantCount2025({
    super.key,
    required this.currentParticipants,
    required this.maxParticipants,
    this.fontSize = 12,
    this.textColor,
    this.icon = Icons.people_outline,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNearFull = currentParticipants / maxParticipants > 0.8;
    final color = textColor ?? 
        (isNearFull 
          ? AppColors2025.warning 
          : (isDark ? Colors.white70 : AppColors2025.textSecondary));
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isNearFull ? Icons.people : icon,
          size: fontSize + 2,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          '$currentParticipants/$maxParticipants명',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}