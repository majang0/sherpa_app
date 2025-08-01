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
  int _maxParticipants = 10;
  MeetingType _meetingType = MeetingType.free;
  double _price = 5000;

  @override
  void initState() {
    super.initState();
    
    // 기존 데이터 로드
    _titleController.text = widget.data.title;
    _descriptionController.text = widget.data.description;
    _locationController.text = widget.data.locationName ?? '';
    _isOnline = widget.data.isOnline;
    _maxParticipants = widget.data.maxParticipants;
    _meetingType = widget.data.meetingType;
    _price = widget.data.price ?? 5000;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '최대 참가 인원',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
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
                '$_maxParticipants명',
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
        
        // 슬라이더
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
            value: _maxParticipants.toDouble(),
            min: 2,
            max: 50,
            divisions: 48,
            onChanged: (value) {
              setState(() => _maxParticipants = value.toInt());
              notifier.setParticipants(2, value.toInt());
              HapticFeedback.lightImpact();
            },
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
}