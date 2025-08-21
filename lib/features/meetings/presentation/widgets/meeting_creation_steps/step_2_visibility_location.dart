import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../models/available_meeting_model.dart';
import '../../../providers/meeting_creation_provider.dart';

/// 🎯 Step 2: 공개범위 및 위치 설정 화면
/// 전체 공개/학교 공개 선택 및 온라인/오프라인 모임 설정
class Step2VisibilityLocation extends ConsumerStatefulWidget {
  @override
  ConsumerState<Step2VisibilityLocation> createState() => _Step2VisibilityLocationState();
}

class _Step2VisibilityLocationState extends ConsumerState<Step2VisibilityLocation> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _detailedAddressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    // 기존 데이터가 있다면 컨트롤러에 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final data = ref.read(meetingCreationProvider);
      if (data.locationName?.isNotEmpty == true) {
        _locationController.text = data.locationName!;
      }
      if (data.detailedAddress?.isNotEmpty == true) {
        _detailedAddressController.text = data.detailedAddress!;
      }
    });
  }

  @override
  void dispose() {
    _locationController.dispose();
    _detailedAddressController.dispose();
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
          // 공개범위 설정 섹션
          _buildVisibilitySection(meetingData, notifier),
          
          const SizedBox(height: 32),
          
          // 모임 장소 설정 섹션
          _buildLocationSection(meetingData, notifier),
          
          const SizedBox(height: 100), // 하단 여백
        ],
      ),
    );
  }

  Widget _buildVisibilitySection(MeetingCreationData data, MeetingCreationNotifier notifier) {
    return _buildSection(
      title: '모임 공개 범위',
      icon: Icons.visibility_rounded,
      description: '누가 이 모임을 볼 수 있는지 설정해주세요',
      child: Column(
        children: MeetingScope.values.map((scope) {
          final isSelected = data.scope == scope;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => notifier.setScope(scope),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? AppColors.primaryGradient
                        : null,
                    color: isSelected ? null : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected 
                          ? AppColors.primary 
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withOpacity(0.2)
                              : AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          scope == MeetingScope.public
                              ? Icons.public_rounded
                              : Icons.school_rounded,
                          color: isSelected ? Colors.white : AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              scope.displayName,
                              style: GoogleFonts.notoSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getScopeDescription(scope),
                              style: GoogleFonts.notoSans(
                                fontSize: 13,
                                color: isSelected 
                                    ? Colors.white.withOpacity(0.9)
                                    : AppColors.textSecondary,
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
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLocationSection(MeetingCreationData data, MeetingCreationNotifier notifier) {
    return _buildSection(
      title: '모임 장소',
      icon: Icons.place_rounded,
      description: '모임이 진행될 장소를 설정해주세요',
      child: Column(
        children: [
          // 온라인/오프라인 선택
          Row(
            children: [
              Expanded(
                child: _LocationTypeCard(
                  title: '온라인 모임',
                  subtitle: '온라인에서 만남',
                  icon: Icons.videocam_rounded,
                  isSelected: data.isOnline,
                  onTap: () => notifier.setOnlineStatus(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LocationTypeCard(
                  title: '오프라인 모임',
                  subtitle: '특정 장소에서 만남',
                  icon: Icons.location_on_rounded,
                  isSelected: !data.isOnline,
                  onTap: () => notifier.setOnlineStatus(false),
                ),
              ),
            ],
          ),
          
          // 오프라인 선택 시 위치 입력 필드들
          if (!data.isOnline) ...[
            const SizedBox(height: 24),
            _buildOfflineLocationInputs(data, notifier),
          ],
        ],
      ),
    );
  }

  Widget _buildOfflineLocationInputs(MeetingCreationData data, MeetingCreationNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 지역 선택
          Text(
            '모임 지역',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _locationController,
            onChanged: (value) {
              // 간단한 위치 설정 (실제 좌표는 임시로 서울시청 좌표 사용)
              if (value.isNotEmpty) {
                notifier.setLocation(
                  const LatLng(37.5665, 126.9780), // 서울시청 좌표
                  value,
                  _detailedAddressController.text.isNotEmpty 
                      ? _detailedAddressController.text 
                      : null,
                );
              }
            },
            decoration: InputDecoration(
              hintText: '예: 서울, 강남구, 홍대 등',
              prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary),
              filled: true,
              fillColor: Colors.white,
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
          
          const SizedBox(height: 16),
          
          // 상세 주소
          Text(
            '상세 주소 (선택사항)',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _detailedAddressController,
            onChanged: (value) {
              if (_locationController.text.isNotEmpty) {
                notifier.setLocation(
                  const LatLng(37.5665, 126.9780),
                  _locationController.text,
                  value.isNotEmpty ? value : null,
                );
              }
            },
            decoration: InputDecoration(
              hintText: '예: 강남구 테헤란로 123, 카페 이름',
              prefixIcon: Icon(Icons.location_city_rounded, color: AppColors.primary),
              filled: true,
              fillColor: Colors.white,
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
          
          const SizedBox(height: 16),
          
          // GPS 현재 위치 버튼 (추후 구현)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.my_location_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  '현재 위치 사용하기',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // 안내 텍스트
          Row(
            children: [
              Icon(Icons.info_outline_rounded, 
                color: AppColors.textSecondary, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '정확한 주소를 입력하면 참가자들이 쉽게 찾을 수 있어요',
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

  String _getScopeDescription(MeetingScope scope) {
    switch (scope) {
      case MeetingScope.public:
        return '모든 사용자가 모임을 볼 수 있어요';
      case MeetingScope.university:
        return '같은 학교 사용자만 모임을 볼 수 있어요';
    }
  }
}

/// 온라인/오프라인 선택 카드
class _LocationTypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _LocationTypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      AppColors.accent,
                      AppColors.accent.withOpacity(0.8),
                    ],
                  )
                : null,
            color: isSelected ? null : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.accent : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.accent,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
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
    );
  }
}