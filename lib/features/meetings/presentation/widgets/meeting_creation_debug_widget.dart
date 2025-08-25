// lib/features/meetings/presentation/widgets/meeting_creation_debug_widget.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/providers/global_user_provider.dart';
import '../../../../shared/providers/global_meeting_provider.dart';
import '../../models/available_meeting_model.dart';
import '../../providers/meeting_creation_provider.dart';

/// 🔧 모임 개설 기능 디버그용 테스트 위젯
/// 
/// 모임 개설 플로우의 각 단계를 개별적으로 테스트하고
/// 문제가 발생하는 정확한 위치를 파악하기 위한 개발자 도구
class MeetingCreationDebugWidget extends ConsumerStatefulWidget {
  const MeetingCreationDebugWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<MeetingCreationDebugWidget> createState() => _MeetingCreationDebugWidgetState();
}

class _MeetingCreationDebugWidgetState extends ConsumerState<MeetingCreationDebugWidget> {
  final _titleController = TextEditingController(text: "테스트 모임 ${DateTime.now().hour}:${DateTime.now().minute}");
  final _descriptionController = TextEditingController(text: "디버그용 테스트 모임입니다.");
  final _locationController = TextEditingController(text: "테스트 장소");
  
  final List<String> _debugLogs = [];
  bool _isCreating = false;
  
  MeetingCategory _selectedCategory = MeetingCategory.exercise;
  MeetingType _selectedType = MeetingType.free;
  MeetingScope _selectedScope = MeetingScope.public;
  
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    _addLog("🔧 디버그 위젯 초기화 완료");
  }

  void _addLog(String message) {
    setState(() {
      _debugLogs.add("[${DateTime.now().toIso8601String().substring(11, 19)}] $message");
    });
    print("🔧 DEBUG: $message");
  }

  void _clearLogs() {
    setState(() {
      _debugLogs.clear();
    });
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(limit: 3);
      setState(() {
        _selectedImages.clear();
        _selectedImages.addAll(images.map((xfile) => File(xfile.path)));
      });
      _addLog("📷 이미지 ${images.length}개 선택됨");
    } catch (e) {
      _addLog("❌ 이미지 선택 실패: $e");
    }
  }

  Future<void> _testMeetingCreation() async {
    if (_isCreating) return;
    
    setState(() {
      _isCreating = true;
    });

    try {
      _addLog("🏁 모임 개설 테스트 시작");
      
      // Step 1: 사용자 정보 확인
      final user = ref.read(globalUserProvider);
      _addLog("👤 사용자 정보: ${user.name} (ID: ${user.id})");
      
      // Step 2: 글로벌 모임 상태 확인 (생성 전)
      final initialMeetingCount = ref.read(globalMeetingProvider).availableMeetings.length;
      _addLog("📊 현재 모임 수: $initialMeetingCount개");
      
      // Step 3: MeetingCreationData 생성
      _addLog("📝 테스트 모임 데이터 생성 중...");
      
      // Step 3-1: Provider 초기화
      final creationProvider = ref.read(meetingCreationProvider.notifier);
      creationProvider.reset();
      
      // Step 3-2: 단계별 데이터 입력
      creationProvider.selectCategory(_selectedCategory);
      creationProvider.setScope(_selectedScope);
      creationProvider.setTitle(_titleController.text);
      creationProvider.setDescription(_descriptionController.text);
      creationProvider.setDateTime(DateTime.now().add(Duration(days: 1)));
      creationProvider.setLocation(
        const gmaps.LatLng(37.5665, 126.9780), // 서울시청
        _locationController.text,
        "서울특별시 중구 세종대로 110",
      );
      creationProvider.setParticipants(2, 10);
      creationProvider.setMeetingType(_selectedType);
      creationProvider.setRegistrationMethod(true);
      
      // 이미지 추가
      for (final image in _selectedImages) {
        creationProvider.addPhoto(image);
      }
      
      final meetingData = ref.read(meetingCreationProvider);
      _addLog("✅ MeetingCreationData 생성 완료");
      _addLog("   - 제목: ${meetingData.title}");
      _addLog("   - 카테고리: ${meetingData.selectedCategory?.displayName ?? '없음'}");
      _addLog("   - 이미지: ${meetingData.photos.length}개");
      _addLog("   - 유효성: ${meetingData.isAllDataValid()}");
      
      if (!meetingData.isAllDataValid()) {
        _addLog("❌ 데이터 유효성 검사 실패");
        setState(() {
          _isCreating = false;
        });
        return;
      }

      // Step 4: AvailableMeeting 변환 테스트
      _addLog("🔄 AvailableMeeting 변환 중...");
      final availableMeeting = await meetingData.toAvailableMeeting(
        hostId: user.id,
        hostName: user.name,
      );
      _addLog("✅ AvailableMeeting 변환 완료");
      _addLog("   - ID: ${availableMeeting.id}");
      _addLog("   - 이미지 파일명: ${availableMeeting.imageFileNames.length}개");

      // Step 5: GlobalMeetingProvider에 추가
      _addLog("📝 글로벌 상태에 모임 추가 중...");
      final success = await ref.read(globalMeetingProvider.notifier).addMeeting(availableMeeting);
      
      if (success) {
        _addLog("✅ 글로벌 상태 추가 성공");
        
        // Step 6: 결과 확인
        final finalMeetingCount = ref.read(globalMeetingProvider).availableMeetings.length;
        _addLog("📊 최종 모임 수: $finalMeetingCount개 (증가: ${finalMeetingCount - initialMeetingCount}개)");
        
        if (finalMeetingCount > initialMeetingCount) {
          _addLog("🎉 모임 개설 테스트 성공!");
        } else {
          _addLog("⚠️ 모임 수가 증가하지 않음 - UI 업데이트 문제일 수 있음");
        }
      } else {
        _addLog("❌ 글로벌 상태 추가 실패");
      }

    } catch (e, stackTrace) {
      _addLog("💥 오류 발생: $e");
      _addLog("스택 트레이스: ${stackTrace.toString()}");
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final meetingCount = ref.watch(globalMeetingProvider).availableMeetings.length;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '모임 개설 디버거',
          style: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 현재 상태 표시
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📊 현재 상태',
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('글로벌 모임 수: $meetingCount개', style: GoogleFonts.notoSans()),
                  Text('선택된 이미지: ${_selectedImages.length}개', style: GoogleFonts.notoSans()),
                  Text('생성 중: ${_isCreating ? "Yes" : "No"}', style: GoogleFonts.notoSans()),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 테스트 데이터 입력
            Text(
              '📝 테스트 데이터',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '모임 제목',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: '모임 설명',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: '모임 장소',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<MeetingCategory>(
                    value: _selectedCategory,
                    items: MeetingCategory.values.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: '카테고리',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<MeetingType>(
                    value: _selectedType,
                    items: MeetingType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedType = value;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: '타입',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 이미지 선택
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.image),
                  label: Text('이미지 선택 (${_selectedImages.length})'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 테스트 실행 버튼
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isCreating ? null : _testMeetingCreation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isCreating
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        '🧪 모임 개설 테스트 실행',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 로그 출력 영역
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '📋 디버그 로그',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: _clearLogs,
                  child: Text('로그 지우기'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Container(
              width: double.infinity,
              height: 300,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _debugLogs.map((log) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        log,
                        style: GoogleFonts.robotoMono(
                          fontSize: 12,
                          color: log.contains('❌') || log.contains('💥')
                              ? Colors.red
                              : log.contains('✅') || log.contains('🎉')
                                  ? Colors.green
                                  : log.contains('⚠️')
                                      ? Colors.orange
                                      : Colors.black87,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}