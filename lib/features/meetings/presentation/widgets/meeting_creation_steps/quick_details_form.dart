// lib/features/meetings/presentation/widgets/meeting_creation_steps/quick_details_form.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../models/available_meeting_model.dart';
import '../../../providers/meeting_creation_provider.dart';

/// 📝 빠른 모임 정보 입력 - Step 2
/// 필수 정보만 간단하게 입력하는 심플한 폼
class QuickDetailsForm extends ConsumerStatefulWidget {
  final MeetingCreationData data;
  final VoidCallback onComplete;

  const QuickDetailsForm({
    super.key,
    required this.data,
    required this.onComplete,
  });

  @override
  ConsumerState<QuickDetailsForm> createState() => _QuickDetailsFormState();
}

class _QuickDetailsFormState extends ConsumerState<QuickDetailsForm> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  
  bool _isOnline = true;
  int _minParticipants = 2;
  int _maxParticipants = 10;
  MeetingType _meetingType = MeetingType.free;
  double _price = 5000;
  MeetingScope _selectedScope = MeetingScope.public;
  
  // 태그와 준비물
  final List<String> _tags = [];
  final List<String> _preparationItems = [];
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _preparationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    // 기존 데이터 로드
    _titleController.text = widget.data.title;
    _descriptionController.text = widget.data.description;
    _locationController.text = widget.data.locationName ?? '';
    _isOnline = widget.data.isOnline;
    _minParticipants = widget.data.minParticipants;
    _maxParticipants = widget.data.maxParticipants;
    _meetingType = widget.data.meetingType;
    _price = widget.data.price ?? 5000;
    _selectedScope = widget.data.scope;
    _tags.addAll(widget.data.tags);
    _preparationItems.addAll(widget.data.preparationItems);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _tagController.dispose();
    _preparationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(meetingCreationProvider.notifier);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🌍 공개범위 선택
          _buildScopeSection(notifier)
            .animate()
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.1, end: 0, duration: 200.ms),
          
          const SizedBox(height: 20),
          
          // 📝 제목
          _buildTextField(
            label: '모임 제목',
            controller: _titleController,
            hint: '예: 주말 한강 러닝 모임',
            maxLength: 30,
            onChanged: (value) => notifier.setTitle(value),
          ).animate()
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.1, end: 0, duration: 200.ms),
          
          const SizedBox(height: 20),
          
          // 📄 설명
          _buildTextField(
            label: '모임 설명',
            controller: _descriptionController,
            hint: '모임에 대한 간단한 소개를 작성해주세요',
            maxLines: 3,
            maxLength: 200,
            onChanged: (value) => notifier.setDescription(value),
          ).animate()
            .fadeIn(delay: 100.ms, duration: 300.ms)
            .slideY(begin: 0.1, end: 0, duration: 200.ms),
          
          const SizedBox(height: 24),
          
          // 📍 장소 선택
          _buildLocationSection(notifier)
            .animate()
            .fadeIn(delay: 200.ms, duration: 300.ms)
            .slideY(begin: 0.1, end: 0, duration: 200.ms),
          
          const SizedBox(height: 24),
          
          // 👥 참가 인원
          _buildParticipantsSection(notifier)
            .animate()
            .fadeIn(delay: 300.ms, duration: 300.ms)
            .slideY(begin: 0.1, end: 0, duration: 200.ms),
          
          const SizedBox(height: 24),
          
          // 💰 참가비
          _buildPriceSection(notifier)
            .animate()
            .fadeIn(delay: 400.ms, duration: 300.ms)
            .slideY(begin: 0.1, end: 0, duration: 200.ms),
          
          const SizedBox(height: 24),
          
          // 🏷️ 태그 (선택)
          _buildTagsSection(notifier)
            .animate()
            .fadeIn(delay: 500.ms, duration: 300.ms)
            .slideY(begin: 0.1, end: 0, duration: 200.ms),
          
          const SizedBox(height: 24),
          
          // 🎒 준비물 (선택)
          _buildPreparationSection(notifier)
            .animate()
            .fadeIn(delay: 600.ms, duration: 300.ms)
            .slideY(begin: 0.1, end: 0, duration: 200.ms),
        ],
      ),
    );
  }

  /// 📝 텍스트 필드
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    int? maxLength,
    required Function(String) onChanged,
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
        TextField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          onChanged: onChanged,
          style: GoogleFonts.notoSans(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.notoSans(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
            counterStyle: GoogleFonts.notoSans(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  /// 🌍 공개범위 섹션
  Widget _buildScopeSection(MeetingCreationNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '공개 범위',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        
        // 전체공개/학교공개 선택
        Row(
          children: [
            _buildScopeOption(
              label: '전체 공개',
              description: '누구나 참여 가능',
              icon: Icons.public_rounded,
              isSelected: _selectedScope == MeetingScope.public,
              onTap: () {
                setState(() => _selectedScope = MeetingScope.public);
                notifier.setScope(MeetingScope.public);
              },
            ),
            const SizedBox(width: 12),
            _buildScopeOption(
              label: '학교 공개',
              description: '같은 학교만',
              icon: Icons.school_rounded,
              isSelected: _selectedScope == MeetingScope.university,
              onTap: () {
                setState(() => _selectedScope = MeetingScope.university);
                notifier.setScope(MeetingScope.university);
              },
            ),
          ],
        ),
      ],
    );
  }

  /// 📍 장소 섹션
  Widget _buildLocationSection(MeetingCreationNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '모임 장소',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        
        // 온라인/오프라인 토글
        Row(
          children: [
            _buildToggleButton(
              label: '온라인',
              icon: Icons.videocam_rounded,
              isSelected: _isOnline,
              onTap: () {
                setState(() => _isOnline = true);
                notifier.setOnlineStatus(true);
              },
            ),
            const SizedBox(width: 12),
            _buildToggleButton(
              label: '오프라인',
              icon: Icons.location_on_rounded,
              isSelected: !_isOnline,
              onTap: () {
                setState(() => _isOnline = false);
                notifier.setOnlineStatus(false);
              },
            ),
          ],
        ),
        
        // 오프라인 장소 입력
        if (!_isOnline) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _locationController,
            onChanged: (value) {
              // 간단한 장소 입력만 받음
              notifier.setLocation(
                const LatLng(37.5665, 126.9780), // 서울 기본 좌표
                value,
              );
            },
            style: GoogleFonts.notoSans(fontSize: 14),
            decoration: InputDecoration(
              hintText: '예: 강남역 스타벅스',
              hintStyle: GoogleFonts.notoSans(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ],
    );
  }

  /// 👥 참가 인원 섹션
  Widget _buildParticipantsSection(MeetingCreationNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '참가 인원 설정',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        
        // 최소 참가 인원
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '최소 참가 인원',
              style: GoogleFonts.notoSans(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$_minParticipants명',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // 최소 인원 슬라이더
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.primary.withOpacity(0.2),
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withOpacity(0.1),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 8,
            ),
          ),
          child: Slider(
            value: _minParticipants.toDouble(),
            min: 2,
            max: _maxParticipants.toDouble() - 1,
            divisions: _maxParticipants - 3,
            onChanged: (value) {
              setState(() => _minParticipants = value.toInt());
              notifier.setParticipants(value.toInt(), _maxParticipants);
              HapticFeedback.lightImpact();
            },
          ),
        ),
        
        const SizedBox(height: 20),
        
        // 최대 참가 인원
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '최대 참가 인원',
              style: GoogleFonts.notoSans(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$_maxParticipants명',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // 최대 인원 슬라이더
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.primary.withOpacity(0.2),
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withOpacity(0.1),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 8,
            ),
          ),
          child: Slider(
            value: _maxParticipants.toDouble(),
            min: _minParticipants.toDouble() + 1,
            max: 50,
            divisions: 50 - _minParticipants - 1,
            onChanged: (value) {
              setState(() => _maxParticipants = value.toInt());
              notifier.setParticipants(_minParticipants, value.toInt());
              HapticFeedback.lightImpact();
            },
          ),
        ),
        
        // 인원 안내
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: Colors.blue.shade700,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '최소 ${_minParticipants}명이 모이면 모임이 확정되고, 최대 ${_maxParticipants}명까지 참여할 수 있어요',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 💰 참가비 섹션
  Widget _buildPriceSection(MeetingCreationNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '참가비',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        
        // 무료/유료 선택
        Row(
          children: [
            _buildPriceOption(
              label: '무료',
              description: '참가 수수료 1,000P',
              isSelected: _meetingType == MeetingType.free,
              onTap: () {
                setState(() => _meetingType = MeetingType.free);
                notifier.setMeetingType(MeetingType.free);
              },
            ),
            const SizedBox(width: 12),
            _buildPriceOption(
              label: '유료',
              description: '직접 설정',
              isSelected: _meetingType == MeetingType.paid,
              onTap: () {
                setState(() => _meetingType = MeetingType.paid);
                notifier.setMeetingType(MeetingType.paid, _price);
              },
            ),
          ],
        ),
        
        // 유료 가격 설정
        if (_meetingType == MeetingType.paid) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '참가비 금액',
                style: GoogleFonts.notoSans(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_price.toInt().toString().replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  )}P',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // 가격 슬라이더
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.primary.withOpacity(0.2),
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.1),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 10,
              ),
            ),
            child: Slider(
              value: _price,
              min: 3000,
              max: 50000,
              divisions: 47,
              onChanged: (value) {
                setState(() => _price = value);
                notifier.setMeetingType(MeetingType.paid, value);
                HapticFeedback.lightImpact();
              },
            ),
          ),
          
          // 가격 안내
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '참가자는 설정한 금액 전체를 결제합니다',
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// 🔘 토글 버튼
  Widget _buildToggleButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                ? AppColors.primary 
                : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected 
                    ? Colors.white 
                    : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 💰 가격 옵션
  Widget _buildPriceOption({
    required String label,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected 
              ? AppColors.primary.withOpacity(0.1)
              : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                ? AppColors.primary 
                : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isSelected 
                    ? AppColors.primary 
                    : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  color: isSelected 
                    ? AppColors.primary 
                    : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 🌍 공개범위 옵션
  Widget _buildScopeOption({
    required String label,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected 
              ? AppColors.primary.withOpacity(0.1)
              : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                ? AppColors.primary 
                : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected 
                  ? AppColors.primary 
                  : AppColors.textSecondary,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.notoSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isSelected 
                    ? AppColors.primary 
                    : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  color: isSelected 
                    ? AppColors.primary 
                    : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// 🏷️ 태그 섹션
  Widget _buildTagsSection(MeetingCreationNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '태그 (선택)',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${_tags.length}/10',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // 태그 입력
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                onSubmitted: (value) => _addTag(value, notifier),
                style: GoogleFonts.notoSans(fontSize: 14),
                decoration: InputDecoration(
                  hintText: '태그를 입력하세요 (예: 초보환영, 주말)',
                  hintStyle: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _addTag(_tagController.text, notifier),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Text(
                '추가',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        
        // 태그 목록
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.map((tag) => Chip(
              label: Text(
                tag,
                style: GoogleFonts.notoSans(
                  fontSize: 13,
                  color: AppColors.primary,
                ),
              ),
              backgroundColor: AppColors.primary.withOpacity(0.1),
              deleteIcon: Icon(
                Icons.close_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              onDeleted: () => _removeTag(tag, notifier),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: AppColors.primary.withOpacity(0.2),
                ),
              ),
            )).toList(),
          ),
        ],
      ],
    );
  }
  
  /// 🎒 준비물 섹션
  Widget _buildPreparationSection(MeetingCreationNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '준비물 (선택)',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${_preparationItems.length}/10',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // 준비물 입력
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _preparationController,
                onSubmitted: (value) => _addPreparationItem(value, notifier),
                style: GoogleFonts.notoSans(fontSize: 14),
                decoration: InputDecoration(
                  hintText: '준비물을 입력하세요 (예: 운동화, 물병)',
                  hintStyle: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _addPreparationItem(_preparationController.text, notifier),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: Text(
                '추가',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        
        // 준비물 목록
        if (_preparationItems.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.orange.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.backpack_outlined,
                      size: 16,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '참가자가 준비해야 할 것들',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _preparationItems.map((item) => Chip(
                    label: Text(
                      item,
                      style: GoogleFonts.notoSans(
                        fontSize: 13,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    backgroundColor: Colors.white,
                    deleteIcon: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: Colors.orange.shade700,
                    ),
                    onDeleted: () => _removePreparationItem(item, notifier),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: Colors.orange.shade300,
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
  
  // 태그 추가
  void _addTag(String tag, MeetingCreationNotifier notifier) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isNotEmpty && _tags.length < 10 && !_tags.contains(trimmedTag)) {
      setState(() {
        _tags.add(trimmedTag);
        _tagController.clear();
      });
      notifier.addTag(trimmedTag);
      HapticFeedback.lightImpact();
    }
  }
  
  // 태그 제거
  void _removeTag(String tag, MeetingCreationNotifier notifier) {
    setState(() {
      _tags.remove(tag);
    });
    notifier.removeTag(tag);
    HapticFeedback.lightImpact();
  }
  
  // 준비물 추가
  void _addPreparationItem(String item, MeetingCreationNotifier notifier) {
    final trimmedItem = item.trim();
    if (trimmedItem.isNotEmpty && _preparationItems.length < 10 && !_preparationItems.contains(trimmedItem)) {
      setState(() {
        _preparationItems.add(trimmedItem);
        _preparationController.clear();
      });
      notifier.addPreparationItem(trimmedItem);
      HapticFeedback.lightImpact();
    }
  }
  
  // 준비물 제거
  void _removePreparationItem(String item, MeetingCreationNotifier notifier) {
    setState(() {
      _preparationItems.remove(item);
    });
    notifier.removePreparationItem(item);
    HapticFeedback.lightImpact();
  }
}