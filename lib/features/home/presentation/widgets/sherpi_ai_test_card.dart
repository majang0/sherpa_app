import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// Core
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/sherpi_dialogues.dart';
import '../../../../core/utils/sherpi_system_checker.dart';

// Shared
import '../../../../shared/widgets/sherpa_card.dart';
import '../../../../shared/providers/global_sherpi_provider.dart';

/// 🤖 셰르피 AI 테스트 카드 위젯
/// 
/// 홈화면에서 쉽게 스마트 AI 시스템을 테스트할 수 있는 카드 위젯
/// - 90% 정적 메시지 (즉시 응답)
/// - 10% AI 메시지 (캐시된 경우 즉시, 실시간은 2-4초)
class SherpiAiTestCard extends ConsumerStatefulWidget {
  const SherpiAiTestCard({super.key});
  
  @override
  ConsumerState<SherpiAiTestCard> createState() => _SherpiAiTestCardState();
}

class _SherpiAiTestCardState extends ConsumerState<SherpiAiTestCard> {
  bool _isLoading = false;
  String? _lastResponse;
  DateTime? _lastTestTime;
  String? _lastResponseSource;

  /// 🧪 스마트 AI 시스템 테스트 실행
  Future<void> _testAI(SherpiContext sherpiContext, String description) async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _lastResponse = null;
      _lastResponseSource = null;
    });

    final startTime = DateTime.now();

    try {
      // 테스트용 컨텍스트 데이터
      final userContext = {
        '사용자명': '테스트 사용자',
        '레벨': '5',
        '연속 접속일': '3일',
        '현재 시간': _getTimeDescription(),
      };
      
      final gameContext = {
        '현재 산': '설악산',
        '등반 성공률': '78%',
        '최근 활동': '오늘 앱 접속, 스마트 AI 테스트 중',
      };
      
      // 🚀 스마트 시스템을 통한 메시지 생성
      await ref.read(sherpiProvider.notifier).showMessage(
        context: sherpiContext,
        userContext: userContext,
        gameContext: gameContext,
        duration: const Duration(seconds: 6),
        forceShow: true, // 🧪 테스트 버튼은 강제 표시 (개발자 도구용)
      );
      
      // 응답 정보 가져오기
      final sherpiState = ref.read(sherpiProvider);
      final responseTime = DateTime.now().difference(startTime);
      
      setState(() {
        _lastResponse = sherpiState.dialogue;
        _lastTestTime = DateTime.now();
        _lastResponseSource = sherpiState.metadata?['response_source'] ?? 'unknown';
      });
      
      // 성능에 따른 성공 메시지
      final isSlowResponse = responseTime.inMilliseconds > 1000;
      final sourceEmoji = _getSourceEmoji(_lastResponseSource);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ $description 테스트 성공! $sourceEmoji (${responseTime.inMilliseconds}ms)'
            ),
            backgroundColor: isSlowResponse ? Colors.orange : Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ 테스트 실패: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 응답 소스에 따른 이모지 반환
  String _getSourceEmoji(String? source) {
    switch (source) {
      case 'static': return '⚡'; // 정적 메시지 (즉시)
      case 'aiCached': return '🚀'; // AI 캐시 (즉시)
      case 'aiRealtime': return '🤖'; // AI 실시간 (2-4초)
      default: return '❓';
    }
  }

  /// 응답 소스에 따른 라벨 반환
  String _getSourceLabel(String? source) {
    switch (source) {
      case 'static': return '즉시';
      case 'aiCached': return '캐시';
      case 'aiRealtime': return 'AI';
      default: return '?';
    }
  }

  /// 응답 소스에 따른 색상 반환
  Color _getSourceColor(String? source) {
    switch (source) {
      case 'static': return Colors.green; // 즉시 응답
      case 'aiCached': return Colors.blue; // 캐시된 AI
      case 'aiRealtime': return Colors.purple; // 실시간 AI
      default: return Colors.grey;
    }
  }

  /// 현재 시간에 따른 설명 반환
  String _getTimeDescription() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '오전';
    if (hour < 18) return '오후';
    return '저녁';
  }

  /// 시간 포맷팅
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // 🚨 DEBUG 모드에서만 표시 (Production에서는 숨김)
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }
    
    return SherpaCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.purple.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚡ 울트라 고속 셰르피',
                      style: GoogleFonts.notoSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '95% 즉시응답 • 5% 스마트AI • 0ms 지연',
                      style: GoogleFonts.notoSans(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 테스트 버튼들
          Row(
            children: [
              Expanded(
                child: _buildTestButton(
                  context: SherpiContext.welcome,
                  title: '환영 인사',
                  icon: Icons.waving_hand,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTestButton(
                  context: SherpiContext.levelUp,
                  title: '레벨업 축하',
                  icon: Icons.celebration,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildTestButton(
                  context: SherpiContext.encouragement,
                  title: '격려 메시지',
                  icon: Icons.favorite,
                  color: Colors.pink,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTestButton(
                  context: SherpiContext.climbingSuccess,
                  title: '등반 성공',
                  icon: Icons.terrain,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          
          
          // 마지막 응답 표시
          if (_lastResponse != null) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '최근 응답 ${_getSourceEmoji(_lastResponseSource)} ${_lastTestTime != null ? _formatTime(_lastTestTime!) : ''}',
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (_lastResponseSource != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getSourceColor(_lastResponseSource),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getSourceLabel(_lastResponseSource),
                            style: GoogleFonts.notoSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _lastResponse!,
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // 로딩 상태
          if (_isLoading) ...[
            const SizedBox(height: 16),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '스마트 시스템 처리 중...',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Phase 1 검증 버튼
          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: _showSystemStatus,
              icon: const Icon(Icons.verified_outlined, size: 16),
              label: Text(
                'Phase 1 단순화 검증',
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 시스템 상태 확인 다이얼로그 (Phase 1 단순화 검증 포함)
  Future<void> _showSystemStatus() async {
    // 로딩 다이얼로그 표시
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Phase 1 단순화 시스템 검증 중...'),
            ],
          ),
        ),
      );
    }
    
    try {
      // 🔍 Phase 1 단순화 검증 실행
      final results = await SherpiSystemChecker.checkSystemIntegration(ref);
      final summary = SherpiSystemChecker.summarizeSystemStatus(results);
      
      if (mounted) {
        // 로딩 다이얼로그 닫기
        Navigator.of(context).pop();
        
        // 결과 다이얼로그 표시
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  results['overall_status'] == 'SUCCESS' ? Icons.check_circle : Icons.error,
                  color: results['overall_status'] == 'SUCCESS' ? Colors.green : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Phase 1 단순화 검증',
                    style: GoogleFonts.notoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 전체 상태
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: results['overall_status'] == 'SUCCESS' 
                          ? Colors.green.shade50 
                          : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: results['overall_status'] == 'SUCCESS' 
                            ? Colors.green.shade300 
                            : Colors.red.shade300,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            results['overall_status'] == 'SUCCESS' 
                              ? '✅ 모든 시스템 정상 작동' 
                              : '❌ 시스템 오류 감지',
                            style: GoogleFonts.notoSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: results['overall_status'] == 'SUCCESS' 
                                ? Colors.green.shade700 
                                : Colors.red.shade700,
                            ),
                          ),
                          if (results['overall_status'] == 'SUCCESS') ...[
                            const SizedBox(height: 4),
                            Text(
                              'Phase 1 단순화가 성공적으로 적용되었습니다',
                              style: GoogleFonts.notoSans(
                                fontSize: 12,
                                color: Colors.green.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // 상세 결과 (접을 수 있는 형태)
                    ExpansionTile(
                      title: Text(
                        '상세 검증 결과',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            summary,
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Phase 1 개선 사항 요약
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '📈 Phase 1 개선 사항',
                            style: GoogleFonts.notoSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• AI 시스템: 4단계 → 3단계 단순화\n'
                            '• 캐시 최적화: 7일 → 3일, LRU 정책\n'
                            '• 메모리 제한: 메트릭 50개, 템플릿 20개\n'
                            '• 응답 속도: 95%+ 즉시 응답 보장',
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              color: Colors.blue.shade600,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              if (results['overall_status'] != 'SUCCESS')
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('시스템 관리자에게 문의하세요: ${results['error_message']}'),
                        backgroundColor: Colors.orange,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  },
                  child: const Text('문제 신고'),
                ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // 로딩 다이얼로그가 열려있으면 닫기
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('시스템 검증 실패: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }



  Widget _buildTestButton({
    required SherpiContext context,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLoading ? null : () => _testAI(context, title),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}