import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// ✅ 글로벌 데이터 시스템 Import
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_user_title_provider.dart';
import '../../../../shared/models/global_user_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/modern_colors.dart';
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

  // ✅ 프로필 편집 다이얼로그 (Modern 디자인 & 완전한 기능 구현)
  void _showEditProfileDialog(BuildContext context, WidgetRef ref, GlobalUser user) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ProfileEditDialog(user: user),
    );
  }
}

// 프로필 편집 다이얼로그 위젯 (StatefulWidget)
class _ProfileEditDialog extends ConsumerStatefulWidget {
  final GlobalUser user;
  
  const _ProfileEditDialog({required this.user});
  
  @override
  ConsumerState<_ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends ConsumerState<_ProfileEditDialog> {
  late TextEditingController _nameController;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
  
  // 이미지 선택 메소드
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지를 선택할 수 없습니다: $e'),
            backgroundColor: ModernColors.error,
          ),
        );
      }
    }
  }
  
  // 이미지 선택 옵션 표시
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: ModernColors.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ModernColors.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '프로필 사진 선택',
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ModernColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageOption(
                  icon: Icons.camera_alt,
                  label: '카메라',
                  color: ModernColors.primary,
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildImageOption(
                  icon: Icons.photo_library,
                  label: '갤러리',
                  color: ModernColors.accent,
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_selectedImage != null || widget.user.profileImageUrl != null)
                  _buildImageOption(
                    icon: Icons.delete,
                    label: '삭제',
                    color: ModernColors.error,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 12,
              color: ModernColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: ModernColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ModernColors.primary,
                    ModernColors.primaryLight,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '프로필 편집',
                    style: GoogleFonts.notoSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // 컨텐츠
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // 프로필 이미지 (현재 화면과 동일한 디자인)
                  Stack(
                    children: [
                      // 메인 아바타 (ProfileAvatarWidget과 동일한 스타일)
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              ModernColors.primary,
                              ModernColors.primary.withValues(alpha: 0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: ModernColors.primary.withValues(alpha: 0.3),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ModernColors.primary.withValues(alpha: 0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _selectedImage != null
                              ? Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                )
                              : widget.user.profileImageUrl != null
                                  ? Image.network(
                                      widget.user.profileImageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          _buildProfileAvatar(),
                                    )
                                  : _buildProfileAvatar(),
                        ),
                      ),
                      
                      // 레벨 배지 (현재 화면처럼 표시)
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                ModernColors.primary,
                                ModernColors.primaryLight,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: ModernColors.primary.withValues(alpha: 0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${widget.user.level}',
                              style: GoogleFonts.notoSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // 카메라 버튼 (편집 버튼)
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _showImagePickerOptions();
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: ModernColors.accent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: ModernColors.accent.withValues(alpha: 0.4),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 닉네임 입력 필드
                  Container(
                    decoration: BoxDecoration(
                      color: ModernColors.gray50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ModernColors.gray200,
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _nameController,
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        color: ModernColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        labelText: '닉네임',
                        labelStyle: GoogleFonts.notoSans(
                          color: ModernColors.textSecondary,
                        ),
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: ModernColors.primary,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        hintText: '새로운 닉네임을 입력하세요',
                        hintStyle: GoogleFonts.notoSans(
                          color: ModernColors.textTertiary,
                        ),
                      ),
                      maxLength: 20,
                      buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12, top: 4),
                          child: Text(
                            '$currentLength/$maxLength',
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              color: currentLength == maxLength
                                  ? ModernColors.error
                                  : ModernColors.textTertiary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 정보 텍스트
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ModernColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: ModernColors.primary.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: ModernColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '프로필 사진과 닉네임은 다른 사용자에게 보여집니다.',
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              color: ModernColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 액션 버튼
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: _isLoading ? null : () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: ModernColors.gray300,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Text(
                            '취소',
                            style: GoogleFonts.notoSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: ModernColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ModernColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  '저장',
                                  style: GoogleFonts.notoSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfileAvatar() {
    // ProfileAvatarWidget과 동일한 스타일의 기본 아바타
    return Center(
      child: Text(
        widget.user.name.isNotEmpty ? widget.user.name[0].toUpperCase() : '셰',
        style: GoogleFonts.notoSans(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
  
  Future<void> _saveProfile() async {
    final newName = _nameController.text.trim();
    
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('닉네임을 입력해주세요.'),
          backgroundColor: ModernColors.error,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // 닉네임 업데이트
      ref.read(globalUserProvider.notifier).updateUserName(newName);
      
      // 프로필 이미지 업데이트 (선택된 경우)
      if (_selectedImage != null) {
        // 실제 구현에서는 이미지를 서버에 업로드하고 URL을 받아와야 함
        // 현재는 로컬 파일 경로를 저장 (임시)
        ref.read(globalUserProvider.notifier).updateProfileImage(_selectedImage!.path);
      }
      
      // 성공 메시지
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('프로필이 성공적으로 업데이트되었습니다!'),
              ],
            ),
            backgroundColor: ModernColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('프로필 업데이트 중 오류가 발생했습니다: $e'),
            backgroundColor: ModernColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
