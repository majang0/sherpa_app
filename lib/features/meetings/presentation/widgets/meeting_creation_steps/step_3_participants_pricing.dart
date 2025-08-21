import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../models/available_meeting_model.dart';
import '../../../providers/meeting_creation_provider.dart';

/// 🎯 Step 3: 참여조건 설정 화면
/// 참가자 수, 참가비, 승인 방식 등 모임 참여 조건 설정
class Step3ParticipantsPricing extends ConsumerStatefulWidget {
  @override
  ConsumerState<Step3ParticipantsPricing> createState() => _Step3ParticipantsPricingState();
}

class _Step3ParticipantsPricingState extends ConsumerState<Step3ParticipantsPricing> {
  final TextEditingController _priceController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    
    // 기존 데이터가 있다면 컨트롤러에 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final data = ref.read(meetingCreationProvider);
      if (data.price != null) {
        _priceController.text = data.price!.toInt().toString();
      }
    });
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
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
          // 참가자 수 설정 섹션
          _buildParticipantsSection(meetingData, notifier),
          
          const SizedBox(height: 32),
          
          // 참가비 설정 섹션
          _buildPricingSection(meetingData, notifier),
          
          const SizedBox(height: 32),
          
          // 참가 방식 설정 섹션
          _buildRegistrationMethodSection(meetingData, notifier),
          
          const SizedBox(height: 100), // 하단 여백
        ],
      ),
    );
  }

  Widget _buildParticipantsSection(MeetingCreationData data, MeetingCreationNotifier notifier) {
    return _buildSection(
      title: '참가자 수',
      icon: Icons.people_rounded,
      description: '모임에 참여할 수 있는 인원을 설정해주세요',
      child: Column(
        children: [
          // 최소 참가자 수
          _ParticipantSlider(
            title: '최소 참가자 수',
            value: data.minParticipants.toDouble(),
            min: 2,
            max: 20,
            divisions: 18,
            onChanged: (value) {
              final minValue = value.toInt();
              final maxValue = data.maxParticipants < minValue 
                  ? minValue 
                  : data.maxParticipants;
              notifier.setParticipants(minValue, maxValue);
            },
          ),
          
          const SizedBox(height: 24),
          
          // 최대 참가자 수  
          _ParticipantSlider(
            title: '최대 참가자 수',
            value: data.maxParticipants.toDouble(),
            min: data.minParticipants.toDouble(),
            max: 50,
            divisions: (50 - data.minParticipants),
            onChanged: (value) {
              notifier.setParticipants(data.minParticipants, value.toInt());
            },
          ),
          
          const SizedBox(height: 16),
          
          // 참가자 수 요약
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, 
                  color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      children: [
                        const TextSpan(text: '모임 정원: '),
                        TextSpan(
                          text: '${data.minParticipants}명 ~ ${data.maxParticipants}명',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const TextSpan(text: ' (호스트 포함)'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection(MeetingCreationData data, MeetingCreationNotifier notifier) {
    return _buildSection(
      title: '참가비 설정',
      icon: Icons.payments_rounded,
      description: '모임 참가비를 설정해주세요',
      child: Column(
        children: [
          // 무료/유료 선택
          Row(
            children: MeetingType.values.map((type) {
              final isSelected = data.meetingType == type;
              
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: type == MeetingType.free ? 8 : 0,
                    left: type == MeetingType.paid ? 8 : 0,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        notifier.setMeetingType(type);
                        if (type == MeetingType.free) {
                          _priceController.clear();
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? LinearGradient(
                                  colors: [
                                    AppColors.success,
                                    AppColors.success.withOpacity(0.8),
                                  ],
                                )
                              : null,
                          color: isSelected ? null : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected 
                                ? AppColors.success 
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              type == MeetingType.free 
                                  ? Icons.free_breakfast_rounded
                                  : Icons.credit_card_rounded,
                              color: isSelected ? Colors.white : AppColors.success,
                              size: 28,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              type.displayName,
                              style: GoogleFonts.notoSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              type == MeetingType.free 
                                  ? '참가자 1000 포인트 소모'
                                  : '설정한 포인트 지불',
                              style: GoogleFonts.notoSans(
                                fontSize: 11,
                                color: isSelected 
                                    ? Colors.white.withOpacity(0.9)
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          // 유료 모임 선택 시 참가비 입력
          if (data.meetingType == MeetingType.paid) ...[
            const SizedBox(height: 24),
            _buildPriceInput(data, notifier),
          ],
          
          const SizedBox(height: 16),
          
          // 수수료 안내
          _buildFeeNotice(data),
        ],
      ),
    );
  }

  Widget _buildPriceInput(MeetingCreationData data, MeetingCreationNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '참가비 (최소 3,000P)',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (value) {
              final price = double.tryParse(value);
              if (price != null && price >= 3000) {
                notifier.setMeetingType(MeetingType.paid, price);
              }
            },
            decoration: InputDecoration(
              hintText: '3000',
              suffixText: 'P',
              suffixStyle: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeNotice(MeetingCreationData data) {
    final fee = data.meetingType == MeetingType.paid 
        ? (data.price ?? 1000) * 0.05 
        : 1000.0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_rounded, color: Colors.orange.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                '참가 포인트 안내',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (data.meetingType == MeetingType.free) ...[
            Text(
              '• 무료 모임: 참가자는 모임 참여 시 1,000 포인트를 소모합니다\n'
              '• 호스트는 모임 완료 후 참가자 수에 따라 보상을 받습니다',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                color: Colors.orange.shade700,
                height: 1.4,
              ),
            ),
          ] else ...[
            Text(
              '• 유료 모임: 참가자가 호스트 설정 포인트를 전액 지불합니다\n'
              '• 참가비 ${(data.price?.toInt() ?? 3000).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} 포인트 → 호스트가 전액 받습니다',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                color: Colors.orange.shade700,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRegistrationMethodSection(MeetingCreationData data, MeetingCreationNotifier notifier) {
    return _buildSection(
      title: '참가 방식',
      icon: Icons.how_to_reg_rounded,
      description: '모임 참가 신청 방식을 선택해주세요',
      child: Column(
        children: [
          // 선착순
          _RegistrationMethodCard(
            title: '선착순',
            subtitle: '신청 즉시 참가 확정',
            description: '빠르게 신청한 순서대로 자동 승인됩니다.\n별도의 승인 과정이 없어 간편해요.',
            icon: Icons.flash_on_rounded,
            isSelected: data.isFirstComeFirstServed,
            onTap: () => notifier.setRegistrationMethod(true),
            color: AppColors.primary,
          ),
          
          const SizedBox(height: 16),
          
          // 승인제
          _RegistrationMethodCard(
            title: '승인제',
            subtitle: '호스트가 직접 승인',
            description: '호스트가 참가 신청을 검토한 후 승인합니다.\n모임에 적합한 참가자를 선별할 수 있어요.',
            icon: Icons.verified_user_rounded,
            isSelected: !data.isFirstComeFirstServed,
            onTap: () => notifier.setRegistrationMethod(false),
            color: AppColors.accent,
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
}

/// 참가자 수 슬라이더 위젯
class _ParticipantSlider extends StatelessWidget {
  final String title;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _ParticipantSlider({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${value.toInt()}명',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.primary.withOpacity(0.2),
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withOpacity(0.2),
            valueIndicatorColor: AppColors.primary,
            valueIndicatorTextStyle: GoogleFonts.notoSans(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: '${value.toInt()}명',
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

/// 참가 방식 선택 카드
class _RegistrationMethodCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _RegistrationMethodCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [color, color.withOpacity(0.8)],
                  )
                : null,
            color: isSelected ? null : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          subtitle,
                          style: GoogleFonts.notoSans(
                            fontSize: 13,
                            color: isSelected 
                                ? Colors.white.withOpacity(0.8)
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: isSelected 
                            ? Colors.white.withOpacity(0.9)
                            : AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}