import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// ✅ 글로벌 데이터 시스템 Import
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_user_title_provider.dart';
import '../../../../shared/models/global_user_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/sherpa_card.dart';
import '../widgets/profile_avatar_widget.dart';

class MyInfoScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ 글로벌 데이터 시스템에서 사용자 데이터 가져오기
    final user = ref.watch(globalUserProvider);
    final userTitle = ref.watch(globalUserTitleProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '내 정보',
          style: GoogleFonts.notoSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 프로필 헤더
            SherpaCard(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    ProfileAvatarWidget(
                      user: user, // ✅ GlobalUser 사용
                      size: 100,
                      showLevelBadge: true,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.name, // ✅ GlobalUser.name 사용
                      style: GoogleFonts.notoSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userTitle.title, // ✅ 실제 칭호 데이터 사용
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    // ✅ 사용자 통계 표시
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildUserStat('레벨', '${user.level}', AppColors.primary),
                        _buildUserStat('XP', '${user.experience.toInt()}', AppColors.warning),
                        _buildUserStat('뱃지', '${user.ownedBadgeIds.length}', AppColors.success),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 설정 메뉴들
            SherpaCard(
              child: Column(
                children: [
                  _buildMenuItem(
                    context,
                    Icons.edit,
                    '프로필 편집',
                    '닉네임, 프로필 사진 변경',
                        () {
                      // 프로필 편집 화면으로 이동
                      _showEditProfileDialog(context, ref, user);
                    },
                  ),
                  _buildMenuItem(
                    context,
                    Icons.notifications,
                    '알림 설정',
                    '푸시 알림, 이메일 알림 설정',
                        () {
                      // 알림 설정 화면으로 이동
                    },
                  ),
                  _buildMenuItem(
                    context,
                    Icons.security,
                    '개인정보 보호',
                    '계정 보안, 개인정보 설정',
                        () {
                      // 개인정보 설정 화면으로 이동
                    },
                  ),
                  _buildMenuItem(
                    context,
                    Icons.help,
                    '도움말',
                    '자주 묻는 질문, 고객 지원',
                        () {
                      // 도움말 화면으로 이동
                    },
                  ),
                  _buildMenuItem(
                    context,
                    Icons.info,
                    '앱 정보',
                    '버전 정보, 이용약관',
                        () {
                      // 앱 정보 화면으로 이동
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
      BuildContext context,
      IconData icon,
      String title,
      String subtitle,
      VoidCallback onTap,
      ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.notoSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.notoSans(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.textLight,
      ),
      onTap: onTap,
    );
  }

  // ✅ 프로필 편집 다이얼로그 (글로벌 시스템 연동)
  void _showEditProfileDialog(BuildContext context, WidgetRef ref, GlobalUser user) {
    final nameController = TextEditingController(text: user.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '프로필 편집',
          style: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: '이름',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '프로필 사진 변경은 추후 지원 예정입니다.',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: GoogleFonts.notoSans(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: 글로벌 Provider에 이름 업데이트 기능 추가 필요
              // ref.read(globalUserProvider.notifier).updateName(nameController.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('프로필 업데이트 기능은 추후 구현 예정입니다.'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: Text(
              '저장',
              style: GoogleFonts.notoSans(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
