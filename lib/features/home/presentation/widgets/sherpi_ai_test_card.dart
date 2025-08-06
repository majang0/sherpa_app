import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// Core
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/sherpi_dialogues.dart';
import '../../../../core/ai/enhanced_gemini_dialogue_source.dart';

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
                      Icon(
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
          
          // 시스템 상태 버튼
          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: _showSystemStatus,
              icon: const Icon(Icons.analytics_outlined, size: 16),
              label: Text(
                '시스템 상태 확인',
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

  /// 시스템 상태 확인 다이얼로그
  Future<void> _showSystemStatus() async {
    try {
      final status = await ref.read(sherpiProvider.notifier).getSystemStatus();
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.analytics_outlined, size: 24),
                const SizedBox(width: 12),
                Text(
                  '스마트 AI 시스템 상태',
                  style: GoogleFonts.notoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusItem('📦 캐시 시스템', '${status['cache']?['valid'] ?? 0}개 유효 메시지'),
                _buildStatusItem('🧠 AI 사용 패턴', '${status['ai_usage_levels'] ?? 0}개 컨텍스트'),
                _buildStatusItem('⏰ 마지막 업데이트', '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '💡 90%는 즉시 응답, 10%는 AI가 생성합니다. 중요한 순간에는 AI 사용률이 증가합니다.',
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('상태 조회 실패: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildStatusItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
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