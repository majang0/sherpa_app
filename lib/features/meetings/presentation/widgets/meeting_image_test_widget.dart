// lib/features/meetings/presentation/widgets/meeting_image_test_widget.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/modern_colors.dart';
import '../../models/available_meeting_model.dart';
import '../../providers/meeting_creation_provider.dart';
import '../../utils/meeting_image_utils.dart';
import '../widgets/meeting_image_gallery_widget.dart';

/// 🧪 이미지 시스템 테스트 위젯 (개발/테스트 용도)
/// 
/// 모임 이미지 저장/로딩 시스템이 올바르게 동작하는지 테스트
class MeetingImageTestWidget extends ConsumerStatefulWidget {
  const MeetingImageTestWidget({super.key});

  @override
  ConsumerState<MeetingImageTestWidget> createState() => _MeetingImageTestWidgetState();
}

class _MeetingImageTestWidgetState extends ConsumerState<MeetingImageTestWidget> {
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];
  AvailableMeeting? _testMeeting;
  bool _isLoading = false;
  String _status = '이미지를 선택해주세요';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이미지 시스템 테스트'),
        backgroundColor: ModernColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 상태 표시
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ModernColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ModernColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '테스트 상태',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ModernColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _status,
                    style: TextStyle(
                      fontSize: 14,
                      color: ModernColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '선택된 이미지: ${_selectedImages.length}개',
                    style: TextStyle(
                      fontSize: 14,
                      color: ModernColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 버튼들
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _pickImages,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('이미지 선택'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ModernColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (_selectedImages.isNotEmpty && !_isLoading) ? _testSaveAndLoad : null,
                    icon: const Icon(Icons.save),
                    label: const Text('저장 테스트'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ModernColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 추가 버튼들
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _clearTest,
                    icon: const Icon(Icons.clear),
                    label: const Text('초기화'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ModernColors.textPrimary,
                      side: BorderSide(color: ModernColors.borderLight),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _getStorageStats,
                    icon: const Icon(Icons.info),
                    label: const Text('저장소 정보'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ModernColors.primary,
                      side: BorderSide(color: ModernColors.primary),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 로딩 인디케이터
            if (_isLoading) ...[
              Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(ModernColors.primary),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 선택된 이미지 미리보기
            if (_selectedImages.isNotEmpty) ...[
              Text(
                '선택된 이미지 미리보기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _selectedImages[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 테스트 모임 이미지 갤러리
            if (_testMeeting != null && _testMeeting!.hasImages) ...[
              Text(
                '저장된 이미지 갤러리',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ModernColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: MeetingImageGalleryWidget(
                  imageFileNames: _testMeeting!.imageFileNames,
                  height: double.infinity,
                ),
              ),
            ] else ...[
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: ModernColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ModernColors.borderLight),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_album_outlined,
                        size: 64,
                        color: ModernColors.textTertiary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '저장된 이미지가 없습니다\n이미지를 선택하고 저장 테스트를 해보세요',
                        style: TextStyle(
                          color: ModernColors.textTertiary,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 📷 이미지 선택
  Future<void> _pickImages() async {
    try {
      setState(() {
        _isLoading = true;
        _status = '이미지를 선택하는 중...';
      });

      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFiles.isNotEmpty) {
        final selectedFiles = pickedFiles.map((xFile) => File(xFile.path)).toList();
        
        setState(() {
          _selectedImages = selectedFiles;
          _status = '${selectedFiles.length}개의 이미지가 선택되었습니다';
        });
      } else {
        setState(() {
          _status = '이미지 선택이 취소되었습니다';
        });
      }
    } catch (e) {
      setState(() {
        _status = '이미지 선택 중 오류: $e';
      });
      print('❌ Error picking images: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 💾 이미지 저장 및 로딩 테스트
  Future<void> _testSaveAndLoad() async {
    if (_selectedImages.isEmpty) return;

    try {
      setState(() {
        _isLoading = true;
        _status = '이미지를 저장하는 중...';
      });

      // 테스트용 MeetingCreationData 생성
      final testData = MeetingCreationData(
        selectedCategory: MeetingCategory.study,
        title: '테스트 모임',
        description: '이미지 시스템 테스트를 위한 모임입니다',
        dateTime: DateTime.now().add(const Duration(days: 1)),
        photos: _selectedImages,
      );

      // AvailableMeeting으로 변환 (이미지 저장 포함)
      final meeting = await testData.toAvailableMeeting(
        hostId: 'test_host_id',
        hostName: '테스트 호스트',
      );

      setState(() {
        _testMeeting = meeting;
        _status = '✅ ${meeting.imageFileNames.length}개 이미지가 성공적으로 저장되었습니다!\n'
                '파일명: ${meeting.imageFileNames.join(', ')}';
      });

    } catch (e) {
      setState(() {
        _status = '❌ 이미지 저장 중 오류: $e';
      });
      print('❌ Error in save and load test: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 🗑️ 테스트 초기화
  void _clearTest() {
    setState(() {
      _selectedImages.clear();
      _testMeeting = null;
      _status = '테스트가 초기화되었습니다. 이미지를 선택해주세요';
    });
  }

  /// 📊 저장소 통계 정보
  Future<void> _getStorageStats() async {
    try {
      setState(() {
        _isLoading = true;
        _status = '저장소 정보를 가져오는 중...';
      });

      final stats = await MeetingImageUtils.getStorageStats();
      
      setState(() {
        _status = '📊 저장소 정보\n'
                '총 파일 수: ${stats['count']}개\n'
                '총 크기: ${stats['totalSizeMB']}MB';
      });

      // 다이얼로그로도 표시
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('저장소 통계'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('총 파일 수: ${stats['count']}개'),
                Text('총 크기: ${stats['totalSizeMB']} MB'),
                Text('평균 파일 크기: ${stats['count'] > 0 ? (stats['totalSize'] / stats['count'] / 1024).toStringAsFixed(1) : '0'} KB'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _status = '❌ 저장소 정보 조회 중 오류: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}