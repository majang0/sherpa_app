import 'package:flutter/material.dart';
import 'package:sherpa_app/core/utils/logger_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// ✅ 글로벌 데이터 시스템 Import
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_user_title_provider.dart';
import '../../../../shared/providers/notification_provider.dart';
import '../../../../shared/models/global_user_model.dart';
import '../../../../shared/models/notification_model.dart';
import '../../../../core/theme/modern_colors.dart';
import '../../../../shared/widgets/sherpa_card.dart';
import '../widgets/profile_avatar_widget.dart';

class MyInfoScreen extends ConsumerWidget {
  const MyInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ 글로벌 데이터 시스템에서 사용자 데이터 가져오기
    final user = ref.watch(globalUserProvider);
    final userTitle = ref.watch(globalUserTitleProvider);

    return Scaffold(
      backgroundColor: ModernColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '내 정보',
          style: GoogleFonts.notoSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: ModernColors.textPrimary,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: ModernColors.textPrimary),
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
                    GestureDetector(
                      onTap: () {
                        if (user.profileImageUrl != null &&
                            user.profileImageUrl!.isNotEmpty) {
                          _showImageViewer(context, user.profileImageUrl!);
                        }
                      },
                      child: ProfileAvatarWidget(
                        user: user, // ✅ GlobalUser 사용
                        size: 100,
                        showLevelBadge: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.name, // ✅ GlobalUser.name 사용
                      style: GoogleFonts.notoSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: ModernColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userTitle.title, // ✅ 실제 칭호 데이터 사용
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        color: ModernColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    // ✅ 사용자 통계 표시
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildUserStat(
                            '레벨', '${user.level}', ModernColors.primary),
                        _buildUserStat('XP', '${user.experience.toInt()}',
                            ModernColors.warning),
                        _buildUserStat('뱃지', '${user.ownedBadgeIds.length}',
                            ModernColors.success),
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

  // ✅ 이미지 뷰어 다이얼로그 표시
  void _showImageViewer(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      builder: (context) => _ImageViewerDialog(imageUrl: imageUrl),
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
            color: ModernColors.textSecondary,
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
          color: ModernColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: ModernColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.notoSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: ModernColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.notoSans(
          fontSize: 12,
          color: ModernColors.textSecondary,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: ModernColors.textTertiary,
      ),
      onTap: onTap,
    );
  }

  // ✅ 프로필 편집 다이얼로그 (Modern 디자인 & 완전한 기능 구현)
  void _showEditProfileDialog(
      BuildContext context, WidgetRef ref, GlobalUser user) {
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
  bool _isImageDeleted = false; // 이미지 삭제 플래그

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

  // 프로필 이미지가 있는지 확인하는 헬퍼 메서드
  bool get _hasProfileImage {
    if (_selectedImage != null) return true;
    if (_isImageDeleted) return false;
    return widget.user.profileImageUrl != null &&
        widget.user.profileImageUrl!.isNotEmpty;
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
          _isImageDeleted = false; // 새 이미지 선택 시 삭제 플래그 리셋
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
        decoration: const BoxDecoration(
          color: ModernColors.surface,
          borderRadius: BorderRadius.only(
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
                if (_hasProfileImage)
                  _buildImageOption(
                    icon: Icons.delete,
                    label: '삭제',
                    color: ModernColors.error,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedImage = null;
                        _isImageDeleted = true; // 이미지 삭제 플래그 설정
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
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ModernColors.primary,
                    ModernColors.primaryLight,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
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
                  // 프로필 이미지 - CircleAvatar 방식으로 개선
                  Stack(
                    children: [
                      // 메인 아바타 - 단순한 CircleAvatar (클릭 시 확대)
                      GestureDetector(
                        onTap: () {
                          // 이미지가 있을 때만 뷰어 표시
                          if (_selectedImage != null) {
                            _showImageViewerForFile(context, _selectedImage!);
                          } else if (!_isImageDeleted &&
                              widget.user.profileImageUrl != null &&
                              widget.user.profileImageUrl!.isNotEmpty) {
                            _showImageViewerForUrl(
                                context, widget.user.profileImageUrl!);
                          }
                        },
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: ModernColors.primary,
                          backgroundImage: _getEditProfileImageProvider(),
                          child: _getEditProfileImageProvider() == null
                              ? _buildProfileAvatar()
                              : null,
                        ),
                      ),

                      // 레벨 배지 - CircleAvatar 방식
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: Container(
                          width: 42,
                          height: 42,
                          padding: const EdgeInsets.all(3), // 흰색 테두리를 위한 패딩
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white, // 테두리 색상
                          ),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: ModernColors.primary,
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
                                  color: ModernColors.accent
                                      .withValues(alpha: 0.4),
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

                  // 닉네임 입력 필드 - 깨끗한 디자인 (테두리 없음)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: ModernColors.primary.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
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
                          fontSize: 14,
                        ),
                        floatingLabelStyle: GoogleFonts.notoSans(
                          color: ModernColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        prefixIcon: Container(
                          margin: const EdgeInsets.only(left: 4),
                          child: const Icon(
                            Icons.person_outline,
                            color: ModernColors.primary,
                            size: 22,
                          ),
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
                      maxLength: 12,
                      buildCounter: (context,
                          {required currentLength,
                          required isFocused,
                          maxLength}) {
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

                  // 정보 텍스트 - 부드러운 배경 (테두리 없음)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ModernColors.primary.withValues(alpha: 0.04),
                          ModernColors.primaryLight.withValues(alpha: 0.02),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: ModernColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            size: 14,
                            color: ModernColors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '프로필은 다른 사용자에게 보여집니다',
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              color: ModernColors.textSecondary,
                              height: 1.4,
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
                          onPressed:
                              _isLoading ? null : () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
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
                              ? const SizedBox(
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

  // 프로필 편집 다이얼로그용 ImageProvider 반환
  ImageProvider? _getEditProfileImageProvider() {
    // 1. 새로 선택한 이미지가 있으면 표시
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    }

    // 2. 이미지가 삭제된 경우 null 반환
    if (_isImageDeleted) {
      return null;
    }

    // 3. 기존 프로필 이미지가 있으면 표시
    if (widget.user.profileImageUrl != null &&
        widget.user.profileImageUrl!.isNotEmpty) {
      // 로컬 파일 경로인지 확인
      if (widget.user.profileImageUrl!.startsWith('/') ||
          widget.user.profileImageUrl!.contains(':\\') ||
          !widget.user.profileImageUrl!.startsWith('http')) {
        // 로컬 파일 이미지
        final file = File(widget.user.profileImageUrl!);
        if (file.existsSync()) {
          return FileImage(file);
        }
      } else {
        // 네트워크 이미지
        return NetworkImage(widget.user.profileImageUrl!);
      }
    }

    return null;
  }

  // 프로필 편집 다이얼로그용 이미지 빌드 (구버전 - 제거 예정)
  Widget _buildEditProfileImage() {
    // 1. 새로 선택한 이미지가 있으면 표시
    if (_selectedImage != null) {
      return Image.file(
        _selectedImage!,
        fit: BoxFit.cover,
        width: 120,
        height: 120,
      );
    }

    // 2. 이미지가 삭제된 경우 기본 아바타 표시
    if (_isImageDeleted) {
      return _buildProfileAvatar();
    }

    // 3. 기존 프로필 이미지가 있으면 표시
    if (widget.user.profileImageUrl != null &&
        widget.user.profileImageUrl!.isNotEmpty) {
      // 로컬 파일 경로인지 확인
      if (widget.user.profileImageUrl!.startsWith('/') ||
          widget.user.profileImageUrl!.contains(':\\') ||
          !widget.user.profileImageUrl!.startsWith('http')) {
        // 로컬 파일 이미지
        final file = File(widget.user.profileImageUrl!);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: BoxFit.cover,
            width: 120,
            height: 120,
            errorBuilder: (context, error, stackTrace) => _buildProfileAvatar(),
          );
        }
      } else {
        // 네트워크 이미지
        return Image.network(
          widget.user.profileImageUrl!,
          fit: BoxFit.cover,
          width: 120,
          height: 120,
          errorBuilder: (context, error, stackTrace) => _buildProfileAvatar(),
        );
      }
    }

    // 3. 이미지가 없으면 기본 아바타
    return _buildProfileAvatar();
  }

  Widget _buildProfileAvatar() {
    // CircleAvatar의 child로 사용할 기본 텍스트
    return Text(
      widget.user.name.isNotEmpty ? widget.user.name[0].toUpperCase() : '셰',
      style: GoogleFonts.notoSans(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }

  Future<void> _saveProfile() async {
    final newName = _nameController.text.trim();

    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
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
      // 현재 사용자 데이터 가져오기 (비교용)
      final currentUser = ref.read(globalUserProvider);
      final oldName = currentUser.name;
      final oldProfileUrl = currentUser.profileImageUrl;

      // 닉네임 업데이트
      ref.read(globalUserProvider.notifier).updateUserName(newName);

      // 프로필 이미지 업데이트
      String? finalImageUrl = oldProfileUrl;
      if (_isImageDeleted) {
        // 이미지 삭제 요청 (null을 전달하면 빈 문자열로 저장됨)
        LoggerService.instance.d('프로필 이미지 삭제 요청');
        ref.read(globalUserProvider.notifier).updateProfileImage(null);
        finalImageUrl = null;
      } else if (_selectedImage != null) {
        // 새 이미지 선택된 경우
        // 실제 구현에서는 이미지를 서버에 업로드하고 URL을 받아와야 함
        // 현재는 로컬 파일 경로를 저장 (임시)
        LoggerService.instance.d('새 프로필 이미지 설정: ${_selectedImage!.path}');
        ref
            .read(globalUserProvider.notifier)
            .updateProfileImage(_selectedImage!.path);
        finalImageUrl = _selectedImage!.path;
      }

      // 알림 트리거
      final notifier = ref.read(notificationProvider.notifier);

      // 프로필 사진 변경 알림
      if (oldProfileUrl != finalImageUrl) {
        if (finalImageUrl == null &&
            oldProfileUrl != null &&
            oldProfileUrl.isNotEmpty) {
          // 사진 삭제
          notifier.notifyProfileUpdate(
            ProfileUpdateType.photo,
            oldValue: '이전 프로필 사진',
            newValue: '기본 프로필',
          );
        } else if (finalImageUrl != null &&
            (oldProfileUrl == null || oldProfileUrl.isEmpty)) {
          // 사진 추가
          notifier.notifyProfileUpdate(
            ProfileUpdateType.photo,
            oldValue: '기본 프로필',
            newValue: '새 프로필 사진',
          );
        } else if (finalImageUrl != oldProfileUrl) {
          // 사진 변경
          notifier.notifyProfileUpdate(
            ProfileUpdateType.photo,
            oldValue: '이전 프로필 사진',
            newValue: '새 프로필 사진',
          );
        }
      }

      // 닉네임 변경 알림
      if (oldName != newName) {
        notifier.notifyProfileUpdate(
          ProfileUpdateType.nickname,
          oldValue: oldName,
          newValue: newName,
        );
      }

      // 성공 메시지
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
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

  // ✅ 파일 이미지 뷰어 표시
  void _showImageViewerForFile(BuildContext context, File imageFile) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 배경 터치로 닫기
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                color: Colors.transparent,
                width: double.infinity,
                height: double.infinity,
              ),
            ),

            // 이미지 뷰어
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.file(
                imageFile,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    _buildViewerErrorWidget(),
              ),
            ),

            // 닫기 버튼
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ URL 이미지 뷰어 표시
  void _showImageViewerForUrl(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      builder: (context) => _ImageViewerDialog(imageUrl: imageUrl),
    );
  }

  Widget _buildViewerErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.white54,
          ),
          const SizedBox(height: 16),
          Text(
            '이미지를 불러올 수 없습니다',
            style: GoogleFonts.notoSans(
              color: Colors.white54,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ 이미지 뷰어 다이얼로그 위젯
class _ImageViewerDialog extends StatelessWidget {
  final String imageUrl;

  const _ImageViewerDialog({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 배경 터치로 닫기
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              color: Colors.transparent,
              width: double.infinity,
              height: double.infinity,
            ),
          ),

          // 이미지 뷰어
          InteractiveViewer(
            panEnabled: true, // 패닝 활성화
            minScale: 0.5, // 최소 스케일
            maxScale: 4.0, // 최대 스케일
            child: _buildImage(),
          ),

          // 닫기 버튼
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            right: 20,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    // 로컬 파일 경로인지 확인
    if (imageUrl.startsWith('/') ||
        imageUrl.contains(':\\') ||
        imageUrl.startsWith('C:\\') ||
        !imageUrl.startsWith('http')) {
      // 로컬 파일 이미지
      final file = File(imageUrl);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        );
      }
      return _buildErrorWidget();
    } else {
      // 네트워크 이미지
      return Image.network(
        imageUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: ModernColors.primary,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    }
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.white54,
          ),
          const SizedBox(height: 16),
          Text(
            '이미지를 불러올 수 없습니다',
            style: GoogleFonts.notoSans(
              color: Colors.white54,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
