import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/sherpi_relationship_growth_widget.dart';
import '../../features/sherpi_relationship/providers/relationship_provider.dart';
import '../../shared/models/sherpi_relationship_model.dart';
import '../../core/constants/sherpi_dialogues.dart';

/// Week 3: 관계 성장 시각화 사용 예시
/// 
/// 사용자와 셰르피의 관계 성장을 시각적으로 표현하고
/// 다양한 상호작용을 테스트할 수 있는 데모 화면입니다.
class RelationshipGrowthUsageExample extends ConsumerStatefulWidget {
  const RelationshipGrowthUsageExample({super.key});

  @override
  ConsumerState<RelationshipGrowthUsageExample> createState() => 
      _RelationshipGrowthUsageExampleState();
}

class _RelationshipGrowthUsageExampleState 
    extends ConsumerState<RelationshipGrowthUsageExample> {
  
  bool _showFullStats = false;
  
  @override
  Widget build(BuildContext context) {
    final relationship = ref.watch(relationshipProvider);
    final stats = ref.watch(relationshipStatsProvider);
    final specialMoments = ref.watch(specialMomentsProvider);
    final emotionalSyncTrend = ref.read(relationshipProvider.notifier)
        .getEmotionalSyncTrend();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Week 3: 관계 성장 시각화'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: Icon(_showFullStats ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                _showFullStats = !_showFullStats;
              });
            },
            tooltip: _showFullStats ? '간단히 보기' : '상세 보기',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 관계 성장 시각화 위젯
            SherpiRelationshipGrowthWidget(
              showFullStats: _showFullStats,
              onTap: () {
                setState(() {
                  _showFullStats = !_showFullStats;
                });
              },
            ),
            const SizedBox(height: 20),
            
            // 상호작용 시뮬레이션 섹션
            _buildInteractionSimulator(),
            const SizedBox(height: 20),
            
            // 감정 동기화 컨트롤
            _buildEmotionalSyncControl(relationship),
            const SizedBox(height: 20),
            
            // 관계 통계 카드
            _buildRelationshipStatsCard(stats),
            const SizedBox(height: 20),
            
            // 감정 동기화 트렌드
            _buildEmotionalSyncTrendCard(emotionalSyncTrend),
            const SizedBox(height: 20),
            
            // 특별한 순간들
            if (specialMoments.isNotEmpty)
              _buildSpecialMomentsSection(specialMoments),
            
            const SizedBox(height: 20),
            
            // 디버그 컨트롤
            _buildDebugControls(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInteractionSimulator() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.touch_app, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  '상호작용 시뮬레이션',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            const Text(
              '다양한 상호작용을 시뮬레이션하여 관계 성장을 테스트해보세요.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildInteractionButton(
                  '운동 완료',
                  'exercise_complete',
                  Colors.orange,
                  Icons.fitness_center,
                ),
                _buildInteractionButton(
                  '학습 완료',
                  'study_complete',
                  Colors.green,
                  Icons.menu_book,
                ),
                _buildInteractionButton(
                  '일기 작성',
                  'diary_written',
                  Colors.purple,
                  Icons.edit_note,
                ),
                _buildInteractionButton(
                  '퀘스트 완료',
                  'quest_complete',
                  Colors.blue,
                  Icons.flag,
                ),
                _buildInteractionButton(
                  '모임 참여',
                  'meeting_joined',
                  Colors.pink,
                  Icons.people,
                ),
                _buildInteractionButton(
                  '레벨업',
                  'level_up',
                  Colors.amber,
                  Icons.trending_up,
                ),
                _buildInteractionButton(
                  '대화',
                  'conversation',
                  Colors.teal,
                  Icons.chat,
                ),
                _buildInteractionButton(
                  '격려 응답',
                  'encouragement_response',
                  Colors.indigo,
                  Icons.favorite,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInteractionButton(
    String label,
    String interactionType,
    Color color,
    IconData icon,
  ) {
    return ElevatedButton.icon(
      onPressed: () {
        ref.read(relationshipProvider.notifier).recordInteraction(
          interactionType: interactionType,
          context: {
            'timestamp': DateTime.now().toIso8601String(),
            'source': 'test_simulation',
          },
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label 상호작용이 기록되었습니다'),
            duration: const Duration(seconds: 1),
            backgroundColor: color,
          ),
        );
      },
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
      ),
    );
  }
  
  Widget _buildEmotionalSyncControl(SherpiRelationship relationship) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.sync_alt, color: Colors.pink),
                const SizedBox(width: 8),
                const Text(
                  '감정 동기화 컨트롤',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: relationship.emotionalSync,
                    onChanged: (value) {
                      ref.read(relationshipProvider.notifier)
                          .updateEmotionalSync(value);
                    },
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: '${(relationship.emotionalSync * 100).toInt()}%',
                    activeColor: _getEmotionalSyncColor(relationship.emotionalSync),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getEmotionalSyncColor(relationship.emotionalSync)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getEmotionalSyncColor(relationship.emotionalSync),
                    ),
                  ),
                  child: Text(
                    '${(relationship.emotionalSync * 100).toInt()}%',
                    style: TextStyle(
                      color: _getEmotionalSyncColor(relationship.emotionalSync),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              relationship.emotionalSyncDescription,
              style: TextStyle(
                color: _getEmotionalSyncColor(relationship.emotionalSync),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRelationshipStatsCard(Map<String, dynamic> stats) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  '관계 통계',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildStatRow('함께한 시간', '${stats['daysTogether']}일'),
            _buildStatRow('총 상호작용', '${stats['totalInteractions']}회'),
            _buildStatRow('연속 대화', '${stats['consecutiveDays']}일'),
            _buildStatRow('평균 상호작용', '${stats['averageInteractionsPerDay']}/일'),
            if (stats['favoriteInteraction'] != null)
              _buildStatRow('주요 상호작용', stats['favoriteInteraction']),
            _buildStatRow('특별한 순간', '${stats['specialMomentsCount']}개'),
            _buildStatRow('성격 유형', stats['personalityType']),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmotionalSyncTrendCard(Map<String, dynamic> trend) {
    final trendText = _getTrendText(trend['trend']);
    final trendColor = _getTrendColor(trend['trend']);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: trendColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: trendColor),
                const SizedBox(width: 8),
                const Text(
                  '감정 동기화 트렌드',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('현재 트렌드'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: trendColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    trendText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildStatRow('개선 횟수', '${trend['improvements']}회'),
            _buildStatRow('평균 성장률', '${(trend['averageGrowth'] * 100).toStringAsFixed(1)}%'),
            _buildStatRow('현재 수준', trend['currentLevel'] ?? '알아가는 중'),
            if (trend['lastImprovement'] != null)
              _buildStatRow(
                '마지막 개선',
                _formatDateTime(DateTime.parse(trend['lastImprovement'])),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSpecialMomentsSection(List<SpecialMoment> moments) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 8),
                const Text(
                  '특별한 순간들',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${moments.length}개',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            ...moments.take(5).map((moment) => _buildMomentItem(moment)),
            if (moments.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '외 ${moments.length - 5}개 더...',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMomentItem(SpecialMoment moment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: _getMomentColor(moment.type),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  moment.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  moment.description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDateTime(moment.timestamp),
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDebugControls() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bug_report, color: Colors.red),
                const SizedBox(width: 8),
                const Text(
                  '디버그 컨트롤',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // 특별한 순간 추가
                      ref.read(relationshipProvider.notifier).addSpecialMoment(
                        type: 'test_moment',
                        title: '테스트 특별한 순간',
                        description: '디버그로 추가된 특별한 순간입니다',
                        metadata: {'debug': true},
                      );
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('특별한 순간이 추가되었습니다'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('특별한 순간 추가'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref.read(relationshipProvider.notifier).resetRelationship();
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('관계가 초기화되었습니다'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('관계 초기화'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                // 빠른 레벨업 시뮬레이션
                for (int i = 0; i < 50; i++) {
                  ref.read(relationshipProvider.notifier).recordInteraction(
                    interactionType: 'rapid_test',
                    context: {'index': i},
                  );
                }
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('50회 상호작용이 추가되었습니다'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
              icon: const Icon(Icons.fast_forward, size: 16),
              label: const Text('빠른 레벨업 (50회 상호작용)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getEmotionalSyncColor(double sync) {
    if (sync >= 0.8) return Colors.red;
    if (sync >= 0.6) return Colors.pink;
    if (sync >= 0.4) return Colors.orange;
    if (sync >= 0.2) return Colors.amber;
    return Colors.grey;
  }
  
  Color _getMomentColor(String type) {
    switch (type) {
      case 'intimacy_levelup':
        return Colors.purple;
      case 'emotional_sync_improvement':
        return Colors.pink;
      case 'first_climb':
        return Colors.green;
      case 'streak_achievement':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
  
  String _getTrendText(String trend) {
    switch (trend) {
      case 'rapidly_improving':
        return '급속 성장중';
      case 'improving':
        return '성장중';
      case 'stable':
        return '안정적';
      case 'declining':
        return '하락중';
      default:
        return '분석중';
    }
  }
  
  Color _getTrendColor(String trend) {
    switch (trend) {
      case 'rapidly_improving':
        return Colors.green;
      case 'improving':
        return Colors.lightGreen;
      case 'stable':
        return Colors.blue;
      case 'declining':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
  
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${dateTime.month}월 ${dateTime.day}일';
    }
  }
}

// 사용 예시를 위한 메인 화면
class RelationshipGrowthDemoScreen extends StatelessWidget {
  const RelationshipGrowthDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phase 2 - Week 3 Demo'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RelationshipGrowthUsageExample(),
              ),
            );
          },
          child: const Text('관계 성장 시각화 테스트'),
        ),
      ),
    );
  }
}