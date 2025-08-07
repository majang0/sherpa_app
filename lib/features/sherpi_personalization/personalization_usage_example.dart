/// 🎨 개인화 설정 시스템 사용 예시 (Phase 2 - Week 1)
/// 
/// 이 파일은 새로 구현된 개인화 설정 시스템의 사용법을 보여주는 예시입니다.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/global_sherpi_provider.dart';
import '../../shared/models/sherpi_relationship_model.dart';
import '../../core/constants/sherpi_emotions.dart';
import '../../core/constants/sherpi_dialogues.dart';

class PersonalizationExample extends ConsumerWidget {
  const PersonalizationExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎨 셰르피 개인화 설정'),
        backgroundColor: Colors.blue.shade100,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 현재 설정 표시
            _buildCurrentSettings(ref),
            const SizedBox(height: 24),
            
            // 성격 유형 선택
            _buildPersonalityTypeSelector(ref),
            const SizedBox(height: 24),
            
            // 닉네임 설정
            _buildNicknameSettings(ref),
            const SizedBox(height: 24),
            
            // 메시지 빈도 설정
            _buildMessageFrequencySettings(ref),
            const SizedBox(height: 24),
            
            // 테스트 메시지 버튼
            _buildTestButtons(ref),
          ],
        ),
      ),
    );
  }

  /// 현재 설정 표시
  Widget _buildCurrentSettings(WidgetRef ref) {
    final settings = ref.getSherpiPersonalizationSettings();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '현재 셰르피 설정',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
          const SizedBox(height: 12),
          _settingRow('성격 유형', settings.personalityType.displayName),
          _settingRow('별명', settings.nickname),
          _settingRow('사용자 호칭', settings.userPreferredName),
          _settingRow('메시지 빈도', settings.messageFrequency.displayName),
          _settingRow('이모지 사용', settings.useEmojisInMessages ? '사용함' : '사용안함'),
        ],
      ),
    );
  }

  /// 설정 행 위젯
  Widget _settingRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 성격 유형 선택기
  Widget _buildPersonalityTypeSelector(WidgetRef ref) {
    final currentSettings = ref.getSherpiPersonalizationSettings();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎭 셰르피 성격 유형 선택',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 12),
          ...SherpiPersonalityType.values.map((type) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Radio<SherpiPersonalityType>(
                    value: type,
                    groupValue: currentSettings.personalityType,
                    onChanged: (selected) {
                      if (selected != null) {
                        _updatePersonalityType(ref, selected);
                      }
                    },
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type.displayName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          type.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  /// 닉네임 설정
  Widget _buildNicknameSettings(WidgetRef ref) {
    final currentSettings = ref.getSherpiPersonalizationSettings();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📝 이름 설정',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade800,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              labelText: '셰르피 별명',
              hintText: '셰르피를 뭐라고 부를까요?',
              border: OutlineInputBorder(),
            ),
            controller: TextEditingController(text: currentSettings.nickname),
            onSubmitted: (value) => _updateNickname(ref, value),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              labelText: '당신을 부르는 이름',
              hintText: '셰르피가 당신을 뭐라고 부를까요?',
              border: OutlineInputBorder(),
            ),
            controller: TextEditingController(text: currentSettings.userPreferredName),
            onSubmitted: (value) => _updateUserName(ref, value),
          ),
        ],
      ),
    );
  }

  /// 메시지 빈도 설정
  Widget _buildMessageFrequencySettings(WidgetRef ref) {
    final currentSettings = ref.getSherpiPersonalizationSettings();
    
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
          Text(
            '📊 메시지 빈도 설정',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade800,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButton<MessageFrequency>(
            value: currentSettings.messageFrequency,
            isExpanded: true,
            items: MessageFrequency.values.map((frequency) {
              return DropdownMenuItem(
                value: frequency,
                child: Row(
                  children: [
                    Text(frequency.displayName),
                    const SizedBox(width: 8),
                    Text(
                      '- ${frequency.description}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (selected) {
              if (selected != null) {
                _updateMessageFrequency(ref, selected);
              }
            },
          ),
        ],
      ),
    );
  }

  /// 테스트 버튼들
  Widget _buildTestButtons(WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🧪 테스트 메시지',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: () => _testWelcomeMessage(ref),
                child: const Text('환영 메시지'),
              ),
              ElevatedButton(
                onPressed: () => _testEncouragementMessage(ref),
                child: const Text('격려 메시지'),
              ),
              ElevatedButton(
                onPressed: () => _testLevelUpMessage(ref),
                child: const Text('레벨업 메시지'),
              ),
              ElevatedButton(
                onPressed: () => _testExerciseCompleteMessage(ref),
                child: const Text('운동 완료'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 성격 유형 업데이트
  void _updatePersonalityType(WidgetRef ref, SherpiPersonalityType newType) {
    final currentSettings = ref.getSherpiPersonalizationSettings();
    final updatedSettings = currentSettings.copyWith(personalityType: newType);
    
    ref.updateSherpiPersonalization(updatedSettings);
  }

  /// 닉네임 업데이트
  void _updateNickname(WidgetRef ref, String newNickname) {
    if (newNickname.trim().isEmpty) return;
    
    final currentSettings = ref.getSherpiPersonalizationSettings();
    final updatedSettings = currentSettings.copyWith(nickname: newNickname.trim());
    
    ref.updateSherpiPersonalization(updatedSettings);
  }

  /// 사용자 이름 업데이트
  void _updateUserName(WidgetRef ref, String newUserName) {
    if (newUserName.trim().isEmpty) return;
    
    final currentSettings = ref.getSherpiPersonalizationSettings();
    final updatedSettings = currentSettings.copyWith(userPreferredName: newUserName.trim());
    
    ref.updateSherpiPersonalization(updatedSettings);
  }

  /// 메시지 빈도 업데이트
  void _updateMessageFrequency(WidgetRef ref, MessageFrequency newFrequency) {
    final currentSettings = ref.getSherpiPersonalizationSettings();
    final updatedSettings = currentSettings.copyWith(messageFrequency: newFrequency);
    
    ref.updateSherpiPersonalization(updatedSettings);
  }

  /// 환영 메시지 테스트
  void _testWelcomeMessage(WidgetRef ref) {
    ref.showSherpi(SherpiContext.welcome, emotion: SherpiEmotion.cheering);
  }

  /// 격려 메시지 테스트
  void _testEncouragementMessage(WidgetRef ref) {
    ref.showSherpi(SherpiContext.encouragement, emotion: SherpiEmotion.happy);
  }

  /// 레벨업 메시지 테스트
  void _testLevelUpMessage(WidgetRef ref) {
    ref.showSherpi(SherpiContext.levelUp, emotion: SherpiEmotion.special);
  }

  /// 운동 완료 메시지 테스트
  void _testExerciseCompleteMessage(WidgetRef ref) {
    ref.showSherpiWithContext(
      SherpiContext.exerciseComplete,
      {
        'exerciseType': '런닝',
        'duration': '30분',
        'calories': '250kcal',
      },
      emotion: SherpiEmotion.cheering,
    );
  }
}

/// 🎯 개인화 설정 빠른 프리셋
class PersonalizationPresets {
  /// 활발한 운동러를 위한 설정
  static PersonalizationSettings getEnergeticAthlete(String userName) {
    return PersonalizationSettings(
      personalityType: SherpiPersonalityType.energetic,
      nickname: '운동 파트너',
      userPreferredName: userName,
      messageFrequency: MessageFrequency.high,
      useEmojisInMessages: true,
      enablePersonalizedTone: true,
    );
  }

  /// 차분한 독서가를 위한 설정
  static PersonalizationSettings getCalmReader(String userName) {
    return PersonalizationSettings(
      personalityType: SherpiPersonalityType.calm,
      nickname: '독서 동반자',
      userPreferredName: userName,
      messageFrequency: MessageFrequency.low,
      useEmojisInMessages: false,
      enablePersonalizedTone: true,
    );
  }

  /// 재미있는 친구를 위한 설정
  static PersonalizationSettings getHumorousFriend(String userName) {
    return PersonalizationSettings(
      personalityType: SherpiPersonalityType.humorous,
      nickname: '웃음 친구',
      userPreferredName: userName,
      messageFrequency: MessageFrequency.normal,
      useEmojisInMessages: true,
      enablePersonalizedTone: true,
    );
  }

  /// 체계적인 목표 달성자를 위한 설정
  static PersonalizationSettings getSeriousAchiever(String userName) {
    return PersonalizationSettings(
      personalityType: SherpiPersonalityType.serious,
      nickname: '목표 달성 파트너',
      userPreferredName: userName,
      messageFrequency: MessageFrequency.normal,
      useEmojisInMessages: false,
      enablePersonalizedTone: true,
    );
  }
}

/*

📋 사용 방법 예시:

1. 기본 사용법:
```dart
// 개인화 설정 가져오기
final settings = ref.getSherpiPersonalizationSettings();

// 성격 유형 변경
final newSettings = settings.copyWith(personalityType: SherpiPersonalityType.energetic);
ref.updateSherpiPersonalization(newSettings);
```

2. 프리셋 적용:
```dart
// 활발한 운동러 설정 적용
final preset = PersonalizationPresets.getEnergeticAthlete('홍길동');
ref.updateSherpiPersonalization(preset);
```

3. 개별 설정 업데이트:
```dart
// 닉네임만 변경
final currentSettings = ref.getSherpiPersonalizationSettings();
final updated = currentSettings.copyWith(nickname: '새로운 별명');
ref.updateSherpiPersonalization(updated);
```

4. 메시지 테스트:
```dart
// 개인화된 메시지 테스트
ref.showSherpi(SherpiContext.welcome);
ref.showSherpi(SherpiContext.encouragement);
```

*/