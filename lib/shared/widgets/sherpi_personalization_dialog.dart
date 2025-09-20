import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/sherpi_emotions.dart';
import '../models/sherpi_relationship_model.dart';
import '../../features/sherpi/relationship/providers/relationship_provider.dart';

/// 🎨 셰르피 개인화 설정 다이얼로그
///
/// 프리미엄 디자인의 캐릭터 선택 인터페이스.
/// 최소한의 텍스트로 직관적인 성격 선택을 제공합니다.
class SherpiPersonalizationDialog extends ConsumerStatefulWidget {
  const SherpiPersonalizationDialog({super.key});

  @override
  ConsumerState<SherpiPersonalizationDialog> createState() =>
      _SherpiPersonalizationDialogState();
}

class _SherpiPersonalizationDialogState
    extends ConsumerState<SherpiPersonalizationDialog>
    with TickerProviderStateMixin {
  // 애니메이션 컨트롤러
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _particleController;

  // 임시 상태 관리 (저장 전까지 여기에 보관)
  late SherpiPersonalityType _tempPersonalityType;

  // UI 상태
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();

    // 애니메이션 초기화
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // 애니메이션 시작 (스태거드 효과)
    _slideController.forward();

    // 페이드 애니메이션은 약간 지연해서 시작 (스태거드 효과)
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _fadeController.forward();
      }
    });

    // 글로우 애니메이션 반복
    _startGlowAnimation();

    // 초기값 설정은 build에서 처리 (ref 접근 필요)
  }

  /// 글로우 애니메이션 시작 (주기적 반복)
  void _startGlowAnimation() {
    _glowController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            _glowController.reverse();
          }
        });
      } else if (status == AnimationStatus.dismissed) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _glowController.forward();
          }
        });
      }
    });

    // 첫 번째 글로우 시작
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _glowController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final relationship = ref.watch(relationshipProvider);

    // 초기값 설정 (한 번만)
    if (!_hasChanges) {
      _tempPersonalityType =
          relationship.personalizationSettings.personalityType;
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: FadeTransition(
        opacity: _fadeController,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _slideController,
            curve: Curves.easeOutCubic,
          )),
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 420,
              maxHeight: 650,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                // 메인 그림자 (오버레이용 더 강한 깊이감)
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                  spreadRadius: -4,
                ),
                // 상단 하이라이트 (3D 효과)
                BoxShadow(
                  color: Colors.white.withOpacity(0.95),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                  spreadRadius: 0,
                ),
                // 측면 그림자 (입체감)
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 32,
                  offset: const Offset(-12, 12),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 32,
                  offset: const Offset(12, 12),
                ),
                // 글로우 효과 (오버레이용 더 강한 효과)
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.12),
                  blurRadius: 60,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                children: [
                  // 배경 그라데이션 (산악 테마) + 애니메이션
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 200,
                    child: AnimatedBuilder(
                      animation: _glowController,
                      builder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment.topCenter,
                              radius: 1.2 + (_glowController.value * 0.3),
                              colors: [
                                AppColors.primary.withOpacity(
                                    0.08 + (_glowController.value * 0.04)),
                                Colors.purple.withOpacity(
                                    0.03 + (_glowController.value * 0.02)),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // 메인 컨텐츠
                  Column(
                    children: [
                      // 헤더
                      _buildHeader(),

                      // 컨텐츠 영역
                      Expanded(
                        child: _buildPersonalitySection(),
                      ),

                      // 하단 버튼
                      _buildBottomButtons(),
                    ],
                  ),

                  // 로딩 오버레이
                  if (_isLoading)
                    Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 헤더 빌드 - 미니멀하고 시각적인 디자인 (실시간 업데이트)
  Widget _buildHeader() {
    final relationship = ref.watch(relationshipProvider);
    final currentPersonality =
        relationship.personalizationSettings.personalityType;

    // 실시간 업데이트: 선택된 성격이 있으면 그것을 표시, 없으면 현재 성격 표시
    final displayPersonality =
        _hasChanges ? _tempPersonalityType : currentPersonality;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        children: [
          // 닫기 버튼을 우상단에 배치
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  onPressed: _handleClose,
                  icon: Icon(
                    Icons.close,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 셰르피 아바타 중앙 배치 - 무테두리 그림자 스타일
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _getPersonalityColor(displayPersonality).withOpacity(0.15),
                  _getPersonalityColor(displayPersonality).withOpacity(0.08),
                  Colors.white,
                ],
                stops: const [0.2, 0.6, 1.0],
              ),
              boxShadow: [
                // 메인 그림자
                BoxShadow(
                  color: _getPersonalityColor(displayPersonality)
                      .withOpacity(0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                  spreadRadius: -2,
                ),
                // 내부 하이라이트
                BoxShadow(
                  color: Colors.white.withOpacity(0.8),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                  spreadRadius: -1,
                ),
                // 외부 글로우
                BoxShadow(
                  color: _getPersonalityColor(displayPersonality)
                      .withOpacity(0.08),
                  blurRadius: 32,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: ClipOval(
                  key: ValueKey(displayPersonality),
                  child: Image.asset(
                    _getPersonalityImagePath(displayPersonality),
                    width: 105,
                    height: 105,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // 이미지 로드 실패 시 fallback 이모티콘 표시
                      return Container(
                        width: 105,
                        height: 105,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getPersonalityColor(displayPersonality)
                              .withOpacity(0.1),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 32,
                          color: _getPersonalityColor(displayPersonality),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 성격별 타이틀 (실시간 업데이트)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _getPersonalityTitle(displayPersonality),
              key: ValueKey('title_$displayPersonality'),
              style: GoogleFonts.notoSans(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.8,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 성격 설명 (실시간 업데이트) - 무테두리 그림자 스타일
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey('desc_$displayPersonality'),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color:
                    _getPersonalityColor(displayPersonality).withOpacity(0.04),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  // 내부 그림자 효과
                  BoxShadow(
                    color: _getPersonalityColor(displayPersonality)
                        .withOpacity(0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                    spreadRadius: -2,
                  ),
                  // 상단 하이라이트
                  BoxShadow(
                    color: Colors.white.withOpacity(0.6),
                    blurRadius: 2,
                    offset: const Offset(0, -1),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Text(
                _getPersonalityDescription(displayPersonality),
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color:
                      _getPersonalityColor(displayPersonality).withOpacity(0.8),
                  letterSpacing: -0.3,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 성격 유형 섹션 빌드 - 원형 그리드 디자인
  Widget _buildPersonalitySection() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          children: [
            // 성격 선택 그리드
            Expanded(
              child: Center(
                child: _buildPersonalityGrid(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 성격 선택 원형 그리드 빌드
  Widget _buildPersonalityGrid() {
    final personalities = SherpiPersonalityType.values;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 20,
      runSpacing: 24,
      children: personalities.asMap().entries.map((entry) {
        final index = entry.key;
        final type = entry.value;
        final isSelected = _tempPersonalityType == type;

        // 스태거드 엔트런스 애니메이션
        return AnimatedBuilder(
          animation: _fadeController,
          builder: (context, child) {
            final delay = index * 0.1; // 각 버튼마다 0.1초씩 지연
            final staggeredValue =
                (_fadeController.value - delay).clamp(0.0, 1.0);
            final scaleValue = Curves.elasticOut.transform(staggeredValue);

            return Transform.scale(
              scale: scaleValue,
              child: Opacity(
                opacity: staggeredValue,
                child: _buildPersonalityCircle(
                  type,
                  isSelected,
                  index,
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  /// 성격 원형 버튼 빌드 - 프리미엄 디자인
  Widget _buildPersonalityCircle(
    SherpiPersonalityType type,
    bool isSelected,
    int index,
  ) {
    final color = _getPersonalityColor(type);
    final imagePath = _getPersonalityImagePath(type);
    final gradient = _getPersonalityGradient(type);

    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) => _scaleController.reverse(),
      onTapCancel: () => _scaleController.reverse(),
      onTap: () {
        setState(() {
          _tempPersonalityType = type;
          _hasChanges = true;
        });
        HapticFeedback.mediumImpact();

        // 선택 시 글로우 애니메이션
        if (isSelected) {
          _glowController.forward().then((_) {
            _glowController.reverse();
          });
        }
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleController, _glowController]),
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            transform: Matrix4.identity()
              ..scale(1.0 + (_scaleController.value * 0.1))
              ..rotateZ(_scaleController.value * 0.05),
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isSelected ? gradient : null,
                color: isSelected ? null : Colors.white,
                boxShadow: isSelected
                    ? [
                        // 선택된 상태 - 강한 그림자와 글로우
                        BoxShadow(
                          color: color.withOpacity(0.25),
                          blurRadius: 20 + (_glowController.value * 10),
                          offset: const Offset(0, 8),
                          spreadRadius: -2,
                        ),
                        BoxShadow(
                          color: color.withOpacity(
                              0.15 + (_glowController.value * 0.1)),
                          blurRadius: 32 + (_glowController.value * 16),
                          offset: const Offset(0, 4),
                        ),
                        // 상단 하이라이트
                        BoxShadow(
                          color: Colors.white.withOpacity(0.8),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                          spreadRadius: -1,
                        ),
                      ]
                    : [
                        // 선택되지 않은 상태 - 부드러운 그림자
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                          spreadRadius: -2,
                        ),
                        // 상단 하이라이트 (버튼 느낌)
                        BoxShadow(
                          color: Colors.white.withOpacity(0.9),
                          blurRadius: 3,
                          offset: const Offset(0, -1),
                          spreadRadius: 0,
                        ),
                        // 측면 그림자 (입체감)
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(2, 2),
                        ),
                      ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 메인 셰르피 이미지
                  ClipOval(
                    child: Image.asset(
                      imagePath,
                      width: 95,
                      height: 95,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // 이미지 로드 실패 시 fallback 아이콘
                        return Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color.withOpacity(0.2),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: color,
                          ),
                        );
                      },
                    ),
                  ),

                  // 선택 시 체크마크 - 그림자 기반 스타일
                  if (isSelected)
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.check,
                          size: 14,
                          color: color,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 프리미엄 하단 버튼 빌드
  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          // 취소 버튼 - 최소화된 디자인
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: _handleClose,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    // 취소 버튼 그림자
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                      spreadRadius: -1,
                    ),
                    // 상단 하이라이트
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 2,
                      offset: const Offset(0, -1),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '취소',
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 20),

          // 저장 버튼 - 프리미엄 글로우 효과
          Expanded(
            flex: 3,
            child: AnimatedBuilder(
              animation:
                  Listenable.merge([_glowController, _particleController]),
              builder: (context, child) {
                return GestureDetector(
                  onTap: _hasChanges ? _handleSave : null,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: _hasChanges
                          ? LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withOpacity(0.8),
                                Colors.purple.shade400,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              stops: const [0.0, 0.7, 1.0],
                            )
                          : LinearGradient(
                              colors: [
                                Colors.grey.shade300,
                                Colors.grey.shade200,
                              ],
                            ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _hasChanges
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(
                                    0.4 + (_glowController.value * 0.2)),
                                blurRadius: 16 + (_glowController.value * 8),
                                offset: const Offset(0, 6),
                              ),
                              BoxShadow(
                                color: Colors.purple.withOpacity(
                                    0.2 + (_glowController.value * 0.1)),
                                blurRadius: 24 + (_glowController.value * 12),
                                offset: const Offset(0, 8),
                              ),
                              if (_particleController.value > 0)
                                BoxShadow(
                                  color: Colors.amber.withOpacity(
                                      _particleController.value * 0.6),
                                  blurRadius: 32,
                                  offset: const Offset(0, 0),
                                ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 메인 텍스트
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: GoogleFonts.notoSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: _hasChanges
                                ? Colors.white
                                : Colors.grey.shade500,
                            letterSpacing: -0.4,
                            height: 1.0,
                          ),
                          child: _isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          _hasChanges
                                              ? Colors.white
                                              : Colors.grey.shade400,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text('저장 중...'),
                                  ],
                                )
                              : const Text('저장하기'),
                        ),

                        // 파티클 효과
                        if (_particleController.value > 0)
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                children: List.generate(8, (index) {
                                  final angle = (index * 45) * (3.14159 / 180);
                                  final distance =
                                      30 * _particleController.value;
                                  final x =
                                      28 + (distance * (index.isEven ? 1 : -1));
                                  final y =
                                      28 + (distance * (index > 3 ? 1 : -1));

                                  return Positioned(
                                    left: x,
                                    top: y,
                                    child: Transform.scale(
                                      scale: _particleController.value,
                                      child: Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(
                                            _particleController.value * 0.8,
                                          ),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.amber.withOpacity(
                                                _particleController.value * 0.6,
                                              ),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 닫기 처리
  void _handleClose() {
    if (_hasChanges) {
      // 변경사항이 있으면 프리미엄 확인 다이얼로그 표시
      showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.6),
        builder: (context) => _buildExitConfirmationDialog(context),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  /// 🚪 프리미엄 나가기 확인 다이얼로그
  Widget _buildExitConfirmationDialog(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 340,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            // 메인 그림자 (강한 임팩트)
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 40,
              offset: const Offset(0, 20),
              spreadRadius: -4,
            ),
            // 상단 하이라이트
            BoxShadow(
              color: Colors.white.withOpacity(0.9),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
            // 경고 글로우 (주황/빨강 계열)
            BoxShadow(
              color: Colors.orange.withOpacity(0.15),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 경고 아이콘
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.orange.shade100,
                    Colors.orange.shade50,
                    Colors.white,
                  ],
                  stops: const [0.3, 0.7, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.warning_rounded,
                size: 32,
                color: Colors.orange.shade600,
              ),
            ),

            const SizedBox(height: 20),

            // 제목
            Text(
              '변경사항이 있습니다',
              style: GoogleFonts.notoSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // 설명
            Text(
              '저장하지 않은 설정이 사라집니다.\n정말로 나가시겠습니까?',
              style: GoogleFonts.notoSans(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                letterSpacing: -0.2,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 28),

            // 버튼들
            Row(
              children: [
                // 취소 버튼
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.8),
                            blurRadius: 2,
                            offset: const Offset(0, -1),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '계속 편집',
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // 나가기 버튼 (위험한 액션)
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(); // 확인 다이얼로그 닫기
                      Navigator.of(context).pop(); // 설정 다이얼로그 닫기
                    },
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.red.shade500,
                            Colors.red.shade600,
                            Colors.red.shade700,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                          BoxShadow(
                            color: Colors.red.withOpacity(0.2),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.exit_to_app_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '나가기',
                              style: GoogleFonts.notoSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 성격별 메인 색상 반환
  Color _getPersonalityColor(SherpiPersonalityType type) {
    switch (type) {
      case SherpiPersonalityType.energetic:
        return Colors.orange.shade600;
      case SherpiPersonalityType.calm:
        return Colors.blue.shade600;
      case SherpiPersonalityType.humorous:
        return Colors.amber.shade600;
      case SherpiPersonalityType.serious:
        return Colors.indigo.shade600;
      case SherpiPersonalityType.balanced:
        return Colors.purple.shade600;
    }
  }

  /// 성격별 셰르피 이미지 경로 반환
  String _getPersonalityImagePath(SherpiPersonalityType type) {
    switch (type) {
      case SherpiPersonalityType.energetic:
        return SherpiEmotion.cheering.imagePath;
      case SherpiPersonalityType.calm:
        return SherpiEmotion.thinking.imagePath;
      case SherpiPersonalityType.humorous:
        return SherpiEmotion.talking.imagePath;
      case SherpiPersonalityType.serious:
        return SherpiEmotion.smile.imagePath;
      case SherpiPersonalityType.balanced:
        return SherpiEmotion.guiding.imagePath;
    }
  }

  /// 성격별 그라데이션 반환
  Gradient _getPersonalityGradient(SherpiPersonalityType type) {
    switch (type) {
      case SherpiPersonalityType.energetic:
        return LinearGradient(
          colors: [
            Colors.orange.shade400,
            Colors.deepOrange.shade500,
            Colors.red.shade400,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case SherpiPersonalityType.calm:
        return LinearGradient(
          colors: [
            Colors.blue.shade400,
            Colors.lightBlue.shade500,
            Colors.cyan.shade400,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case SherpiPersonalityType.humorous:
        return LinearGradient(
          colors: [
            Colors.amber.shade400,
            Colors.yellow.shade500,
            Colors.lime.shade400,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case SherpiPersonalityType.serious:
        return LinearGradient(
          colors: [
            Colors.indigo.shade400,
            Colors.blue.shade600,
            Colors.purple.shade500,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case SherpiPersonalityType.balanced:
        return LinearGradient(
          colors: [
            Colors.purple.shade400,
            Colors.deepPurple.shade500,
            Colors.indigo.shade500,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  /// 성격별 제목 반환
  String _getPersonalityTitle(SherpiPersonalityType type) {
    switch (type) {
      case SherpiPersonalityType.energetic:
        return '활발한 셰르피';
      case SherpiPersonalityType.calm:
        return '차분한 셰르피';
      case SherpiPersonalityType.humorous:
        return '재미있는 셰르피';
      case SherpiPersonalityType.serious:
        return '진지한 셰르피';
      case SherpiPersonalityType.balanced:
        return '균형잡힌 셰르피';
    }
  }

  /// 성격별 설명 반환
  String _getPersonalityDescription(SherpiPersonalityType type) {
    switch (type) {
      case SherpiPersonalityType.energetic:
        return '항상 의욕적이고 에너지가 넘치는 응원';
      case SherpiPersonalityType.calm:
        return '차분하고 안정적인 위로와 격려';
      case SherpiPersonalityType.humorous:
        return '유머러스하고 재치있는 밝은 대화';
      case SherpiPersonalityType.serious:
        return '진중하고 신중한 조언과 격려';
      case SherpiPersonalityType.balanced:
        return '상황에 맞는 적절한 반응과 소통';
    }
  }

  /// 저장 처리
  Future<void> _handleSave() async {
    setState(() {
      _isLoading = true;
    });

    // 진동 피드백
    HapticFeedback.mediumImpact();

    // 파티클 애니메이션 시작
    _particleController.forward();

    // 저장 애니메이션을 위한 지연
    await Future.delayed(const Duration(milliseconds: 800));

    // 실제 저장 로직
    final relationship = ref.read(relationshipProvider);
    final updatedSettings = relationship.personalizationSettings.copyWith(
      personalityType: _tempPersonalityType,
    );
    final updatedRelationship = relationship.copyWith(
      personalizationSettings: updatedSettings,
    );

    // Provider 업데이트
    ref
        .read(relationshipProvider.notifier)
        .updateRelationship(updatedRelationship);

    setState(() {
      _isLoading = false;
    });

    // 성공 시 글로우 애니메이션
    _glowController.forward().then((_) {
      _glowController.reverse();
    });

    // 성공 메시지
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                '설정이 저장되었습니다',
                style: GoogleFonts.notoSans(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );

      // 다이얼로그 닫기
      Navigator.of(context).pop();
    }
  }
}
