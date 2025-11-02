import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

// ✅ 글로벌 데이터 시스템 Import
import '../../../../shared/models/global_user_model.dart';
import 'package:sherpa_app/shared/providers/level_1_user_data/global_user_title_provider.dart';
import '../../../../core/theme/modern_colors.dart';

class ProfileAvatarWidget extends ConsumerWidget {
  final GlobalUser user;
  final double size;
  final bool showLevelBadge;
  final VoidCallback? onTap;

  const ProfileAvatarWidget({
    super.key,
    required this.user,
    this.size = 60,
    this.showLevelBadge = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userTitle = ref.watch(globalUserTitleProvider);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // 메인 아바타 - sherpa_clean_app_bar와 동일한 방식
          CircleAvatar(
            radius: size / 2,
            backgroundColor: ModernColors.primary,
            backgroundImage: _getProfileImageProvider(),
            child: _getProfileImageProvider() == null
                ? _buildDefaultAvatar()
                : null,
          ),

          // 레벨 배지
          if (showLevelBadge)
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                width: size * 0.35,
                height: size * 0.35,
                padding: const EdgeInsets.all(2), // 흰색 테두리를 위한 패딩
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white, // 테두리 색상
                ),
                child: CircleAvatar(
                  radius: (size * 0.35 - 4) / 2,
                  backgroundColor: ModernColors.primary,
                  child: Text(
                    '${user.level}', // ✅ GlobalUser.level 사용
                    style: GoogleFonts.notoSans(
                      fontSize: size * 0.15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

          // 온라인 상태 표시 (선택사항)
          if (size > 40)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: size * 0.2,
                height: size * 0.2,
                padding: const EdgeInsets.all(1), // 흰색 테두리를 위한 패딩
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white, // 테두리 색상
                ),
                child: CircleAvatar(
                  radius: (size * 0.2 - 2) / 2,
                  backgroundColor: ModernColors.success,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 프로필 이미지 Provider 반환 (CircleAvatar용)
  ImageProvider? _getProfileImageProvider() {
    if (user.profileImageUrl == null || user.profileImageUrl!.isEmpty) {
      return null;
    }

    // 로컬 파일 경로인지 확인
    if (user.profileImageUrl!.startsWith('/') ||
        user.profileImageUrl!.contains(':\\') ||
        user.profileImageUrl!.startsWith('C:\\') ||
        !user.profileImageUrl!.startsWith('http')) {
      // 로컬 파일
      final file = File(user.profileImageUrl!);
      if (file.existsSync()) {
        return FileImage(file);
      }
      return null;
    } else {
      // 네트워크 이미지
      return NetworkImage(user.profileImageUrl!);
    }
  }

  // 프로필 이미지 또는 기본 아바타 빌드 (구버전 - 참고용으로 유지)
  Widget _buildAvatarContent() {
    // profileImageUrl이 있는 경우 이미지 표시
    if (user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty) {
      // 로컬 파일 경로인지 확인 (윈도우 경로 또는 Unix 경로)
      if (user.profileImageUrl!.startsWith('/') ||
          user.profileImageUrl!.contains(':\\') ||
          user.profileImageUrl!.startsWith('C:\\') ||
          !user.profileImageUrl!.startsWith('http')) {
        // 로컬 파일 이미지
        final file = File(user.profileImageUrl!);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: BoxFit.cover,
            width: size,
            height: size,
            errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
          );
        }
      } else {
        // 네트워크 이미지 (URL)
        return Image.network(
          user.profileImageUrl!,
          fit: BoxFit.cover,
          width: size,
          height: size,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                color: Colors.white,
                strokeWidth: 2,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
        );
      }
    }

    // 이미지가 없으면 기본 아바타 표시
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Text(
      user.name.isNotEmpty
          ? user.name[0].toUpperCase()
          : '셰', // ✅ GlobalUser.name 사용
      style: GoogleFonts.notoSans(
        fontSize: size * 0.4,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }
}
