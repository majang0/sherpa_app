import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../providers/meeting_creation_provider.dart';

/// 🎯 Step 4: 상세정보 입력 화면
/// 사진 등록, 제목, 내용, 날짜 등 모임의 세부 정보 입력
class Step4DetailsPhoto extends ConsumerStatefulWidget {
  @override
  ConsumerState<Step4DetailsPhoto> createState() => _Step4DetailsPhotoState();
}

class _Step4DetailsPhotoState extends ConsumerState<Step4DetailsPhoto> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _preparationController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    
    // 기존 데이터가 있다면 컨트롤러에 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final data = ref.read(meetingCreationProvider);
      if (data.title.isNotEmpty) {
        _titleController.text = data.title;
      }
      if (data.description.isNotEmpty) {
        _descriptionController.text = data.description;
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    _preparationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final data = ref.read(meetingCreationProvider);
    if (data.photos.length >= 5) {
      _showSnackBar('사진은 최대 5장까지 등록할 수 있습니다', isError: true);
      return;
    }

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        final notifier = ref.read(meetingCreationProvider.notifier);
        notifier.addPhoto(File(image.path));
        _showSnackBar('사진이 추가되었습니다');
      }
    } catch (e) {
      _showSnackBar('사진을 불러올 수 없습니다', isError: true);
    }
  }

  Future<void> _selectDateTime() async {
    final data = ref.read(meetingCreationProvider);
    final notifier = ref.read(meetingCreationProvider.notifier);
    
    final date = await showDatePicker(
      context: context,
      initialDate: data.dateTime ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ko', 'KR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          data.dateTime ?? DateTime.now().add(const Duration(hours: 1)),
        ),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.primary,
                onPrimary: Colors.white,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null && mounted) {
        final dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        notifier.setDateTime(dateTime);
      }
    }
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty) {
      final notifier = ref.read(meetingCreationProvider.notifier);
      notifier.addTag(tag);
      _tagController.clear();
    }
  }

  void _addPreparationItem() {
    final item = _preparationController.text.trim();
    if (item.isNotEmpty) {
      final notifier = ref.read(meetingCreationProvider.notifier);
      notifier.addPreparationItem(item);
      _preparationController.clear();
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final meetingData = ref.watch(meetingCreationProvider);
    final notifier = ref.read(meetingCreationProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 사진 등록 섹션
          _buildPhotoSection(meetingData, notifier),
          
          const SizedBox(height: 32),
          
          // 기본 정보 섹션
          _buildBasicInfoSection(meetingData, notifier),
          
          const SizedBox(height: 32),
          
          // 날짜/시간 섹션
          _buildDateTimeSection(meetingData),
          
          const SizedBox(height: 32),
          
          // 태그 섹션
          _buildTagSection(meetingData, notifier),
          
          const SizedBox(height: 32),
          
          // 준비물 섹션
          _buildPreparationSection(meetingData, notifier),
          
          const SizedBox(height: 100), // 하단 여백
        ],
      ),
    );
  }

  Widget _buildPhotoSection(MeetingCreationData data, MeetingCreationNotifier notifier) {
    return _buildSection(
      title: '모임 사진',
      icon: Icons.photo_camera_rounded,
      description: '모임을 소개할 수 있는 사진을 추가해주세요 (최대 5장)',
      child: Column(
        children: [
          // 사진 그리드
          if (data.photos.isNotEmpty) ...[
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: data.photos.length,
              itemBuilder: (context, index) {
                return _PhotoTile(
                  photo: data.photos[index],
                  onRemove: () => notifier.removePhoto(index),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
          
          // 사진 추가 버튼
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _pickImage,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.add_photo_alternate_rounded,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '사진 추가 (${data.photos.length}/5)',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '갤러리에서 선택',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection(MeetingCreationData data, MeetingCreationNotifier notifier) {
    return _buildSection(
      title: '모임 정보',
      icon: Icons.edit_rounded,
      description: '모임의 제목과 내용을 작성해주세요',
      child: Column(
        children: [
          // 제목 입력
          _buildInputField(
            label: '모임 제목',
            controller: _titleController,
            hint: '예: 함께 책 읽고 토론해요',
            maxLength: 50,
            onChanged: (value) => notifier.setTitle(value),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '모임 제목을 입력해주세요';
              }
              if (value.trim().length < 5) {
                return '모임 제목은 5글자 이상 입력해주세요';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 20),
          
          // 설명 입력
          _buildInputField(
            label: '모임 설명',
            controller: _descriptionController,
            hint: '모임에 대한 자세한 설명을 작성해주세요\n• 모임 목적과 진행 방식\n• 필요한 준비물이나 사전 지식\n• 모임 분위기와 참가 대상',
            maxLines: 6,
            maxLength: 500,
            onChanged: (value) => notifier.setDescription(value),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '모임 설명을 입력해주세요';
              }
              if (value.trim().length < 10) {
                return '모임 설명은 10글자 이상 입력해주세요';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeSection(MeetingCreationData data) {
    return _buildSection(
      title: '모임 일시',
      icon: Icons.event_rounded,
      description: '모임이 진행될 날짜와 시간을 설정해주세요',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _selectDateTime,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: data.dateTime != null 
                  ? AppColors.primary.withOpacity(0.05)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: data.dateTime != null 
                    ? AppColors.primary.withOpacity(0.3)
                    : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: data.dateTime != null 
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.calendar_today_rounded,
                    color: data.dateTime != null 
                        ? AppColors.primary 
                        : AppColors.textSecondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.dateTime != null 
                            ? '${data.dateTime!.year}년 ${data.dateTime!.month}월 ${data.dateTime!.day}일'
                            : '날짜를 선택해주세요',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: data.dateTime != null 
                              ? AppColors.textPrimary 
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.dateTime != null 
                            ? '${data.dateTime!.hour.toString().padLeft(2, '0')}:${data.dateTime!.minute.toString().padLeft(2, '0')}'
                            : '시간을 선택해주세요',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTagSection(MeetingCreationData data, MeetingCreationNotifier notifier) {
    return _buildSection(
      title: '태그 (선택사항)',
      icon: Icons.local_offer_rounded,
      description: '모임을 더 잘 설명할 수 있는 태그를 추가해주세요',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 태그 입력
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _tagController,
                  decoration: InputDecoration(
                    hintText: '예: 초보환영, 친목, 스터디',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onFieldSubmitted: (_) => _addTag(),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _addTag,
                    borderRadius: BorderRadius.circular(12),
                    child: const Center(
                      child: Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // 태그 목록
          if (data.tags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: data.tags.map((tag) {
                return _TagChip(
                  tag: tag,
                  onRemove: () => notifier.removeTag(tag),
                );
              }).toList(),
            ),
          ],
          
          const SizedBox(height: 12),
          
          // 태그 안내
          Row(
            children: [
              Icon(Icons.info_outline_rounded, 
                color: AppColors.textSecondary, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '태그는 최대 10개까지 추가할 수 있습니다',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreparationSection(MeetingCreationData data, MeetingCreationNotifier notifier) {
    return _buildSection(
      title: '준비물 (선택사항)',
      icon: Icons.inventory_2_rounded,
      description: '참가자들이 미리 준비해야 할 물품이나 준비사항을 알려주세요',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 준비물 입력
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _preparationController,
                  decoration: InputDecoration(
                    hintText: '예: 운동복, 수건, 필기구',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onFieldSubmitted: (_) => _addPreparationItem(),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _addPreparationItem,
                    borderRadius: BorderRadius.circular(12),
                    child: const Center(
                      child: Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // 준비물 목록
          if (data.preparationItems.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: data.preparationItems.map((item) {
                return _PreparationChip(
                  item: item,
                  onRemove: () => notifier.removePreparationItem(item),
                );
              }).toList(),
            ),
          ],
          
          const SizedBox(height: 12),
          
          // 준비물 안내
          Row(
            children: [
              Icon(Icons.info_outline_rounded, 
                color: AppColors.textSecondary, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '준비물은 최대 10개까지 추가할 수 있습니다',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required String description,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.notoSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.notoSans(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    int? maxLength,
    required ValueChanged<String> onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          onChanged: onChanged,
          validator: validator,
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.notoSans(
              fontSize: 14,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            counterStyle: GoogleFonts.notoSans(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

/// 사진 타일 위젯
class _PhotoTile extends StatelessWidget {
  final File photo;
  final VoidCallback onRemove;

  const _PhotoTile({
    required this.photo,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // 사진
            Image.file(
              photo,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            
            // 삭제 버튼
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onRemove,
                    borderRadius: BorderRadius.circular(12),
                    child: const Center(
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 태그 칩 위젯
class _TagChip extends StatelessWidget {
  final String tag;
  final VoidCallback onRemove;

  const _TagChip({
    required this.tag,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close_rounded,
              size: 16,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// 준비물 칩 위젯
class _PreparationChip extends StatelessWidget {
  final String item;
  final VoidCallback onRemove;

  const _PreparationChip({
    required this.item,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_rounded,
            size: 14,
            color: AppColors.accent,
          ),
          const SizedBox(width: 6),
          Text(
            item,
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close_rounded,
              size: 16,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}