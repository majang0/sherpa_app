// lib/features/meetings/utils/meeting_image_utils.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_app/core/utils/logger_service.dart';

/// 📷 모임 이미지 저장/로딩 유틸리티 클래스
///
/// 모임 생성 시 선택된 이미지들을 앱 내부 저장소에 영구 저장하고,
/// 모임 상세 화면에서 해당 이미지들을 로딩하는 기능을 제공
class MeetingImageUtils {
  /// 모임 이미지 저장 디렉토리명
  static const String _meetingImagesDir = 'meeting_images';

  /// 지원하는 이미지 확장자들
  static const List<String> _supportedExtensions = [
    '.jpg',
    '.jpeg',
    '.png',
    '.webp'
  ];

  /// 📁 모임 이미지 저장 디렉토리 가져오기
  static Future<Directory> _getMeetingImagesDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final meetingDir = Directory(path.join(appDir.path, _meetingImagesDir));

    if (!await meetingDir.exists()) {
      await meetingDir.create(recursive: true);
    }

    return meetingDir;
  }

  /// 💾 임시 이미지 파일들을 영구 저장소로 복사
  ///
  /// [tempFiles] 임시 File 객체들 (image_picker에서 가져온 파일들)
  /// [meetingId] 모임 고유 ID (파일명 충돌 방지용)
  ///
  /// Returns: 저장된 파일명들의 리스트
  static Future<List<String>> saveMeetingImages({
    required List<File> tempFiles,
    required String meetingId,
  }) async {
    if (tempFiles.isEmpty) return [];

    final meetingDir = await _getMeetingImagesDirectory();
    final savedFileNames = <String>[];

    for (int i = 0; i < tempFiles.length; i++) {
      final tempFile = tempFiles[i];

      if (!await tempFile.exists()) {
        LoggerService.instance
            .d('⚠️ Warning: Temporary file does not exist: ${tempFile.path}');
        continue;
      }

      // 고유한 파일명 생성: {meetingId}_{index}_{timestamp}.{extension}
      final extension = _getFileExtension(tempFile.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${meetingId}_${i}_$timestamp$extension';

      final targetFile = File(path.join(meetingDir.path, fileName));

      try {
        // 파일 복사 (임시 파일 → 영구 저장소)
        await tempFile.copy(targetFile.path);
        savedFileNames.add(fileName);

        LoggerService.instance
            .d('✅ Image saved: $fileName (${await tempFile.length()} bytes)');
      } catch (e) {
        LoggerService.instance.d('❌ Error saving image ${tempFile.path}: $e');
      }
    }

    return savedFileNames;
  }

  /// 📂 저장된 모임 이미지 파일 가져오기
  ///
  /// [fileName] 저장된 이미지 파일명
  ///
  /// Returns: 이미지 File 객체 (존재하지 않으면 null)
  static Future<File?> getMeetingImageFile(String fileName) async {
    try {
      final meetingDir = await _getMeetingImagesDirectory();
      final imageFile = File(path.join(meetingDir.path, fileName));

      if (await imageFile.exists()) {
        return imageFile;
      } else {
        LoggerService.instance.d('⚠️ Warning: Image file not found: $fileName');
        return null;
      }
    } catch (e) {
      LoggerService.instance.d('❌ Error loading image file $fileName: $e');
      return null;
    }
  }

  /// 🖼️ 저장된 모임 이미지들을 Uint8List로 로딩
  ///
  /// [fileNames] 이미지 파일명들의 리스트
  ///
  /// Returns: 이미지 데이터들의 리스트 (로딩 실패한 파일은 제외)
  static Future<List<Uint8List>> loadMeetingImages(
      List<String> fileNames) async {
    if (fileNames.isEmpty) return [];

    final imageDataList = <Uint8List>[];

    for (final fileName in fileNames) {
      final imageFile = await getMeetingImageFile(fileName);

      if (imageFile != null) {
        try {
          final imageData = await imageFile.readAsBytes();
          imageDataList.add(imageData);
        } catch (e) {
          LoggerService.instance
              .d('❌ Error reading image data from $fileName: $e');
        }
      }
    }

    return imageDataList;
  }

  /// 🗑️ 특정 모임의 모든 이미지 파일들 삭제
  ///
  /// [fileNames] 삭제할 파일명들의 리스트
  ///
  /// Returns: 성공적으로 삭제된 파일 개수
  static Future<int> deleteMeetingImages(List<String> fileNames) async {
    if (fileNames.isEmpty) return 0;

    int deletedCount = 0;

    for (final fileName in fileNames) {
      final imageFile = await getMeetingImageFile(fileName);

      if (imageFile != null) {
        try {
          await imageFile.delete();
          deletedCount++;
          LoggerService.instance.d('🗑️ Deleted image: $fileName');
        } catch (e) {
          LoggerService.instance.d('❌ Error deleting image $fileName: $e');
        }
      }
    }

    return deletedCount;
  }

  /// 📊 저장된 모든 모임 이미지 통계 정보
  ///
  /// Returns: Map with 'count' and 'totalSize' keys
  static Future<Map<String, dynamic>> getStorageStats() async {
    try {
      final meetingDir = await _getMeetingImagesDirectory();

      if (!await meetingDir.exists()) {
        return {'count': 0, 'totalSize': 0};
      }

      final files = meetingDir.listSync().whereType<File>().toList();
      int totalSize = 0;

      for (final file in files) {
        try {
          totalSize += await file.length();
        } catch (e) {
          LoggerService.instance
              .d('Warning: Could not get size of ${file.path}');
        }
      }

      return {
        'count': files.length,
        'totalSize': totalSize,
        'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
      };
    } catch (e) {
      LoggerService.instance.d('❌ Error getting storage stats: $e');
      return {'count': 0, 'totalSize': 0, 'totalSizeMB': '0.00'};
    }
  }

  /// 🧹 오래된 이미지 파일들 정리 (선택적)
  ///
  /// [daysOld] 몇 일 이상 된 파일들을 삭제할지
  ///
  /// Returns: 삭제된 파일 개수
  static Future<int> cleanupOldImages({int daysOld = 30}) async {
    try {
      final meetingDir = await _getMeetingImagesDirectory();

      if (!await meetingDir.exists()) return 0;

      final files = meetingDir.listSync().whereType<File>().toList();
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      int deletedCount = 0;

      for (final file in files) {
        try {
          final fileStat = await file.stat();
          if (fileStat.modified.isBefore(cutoffDate)) {
            await file.delete();
            deletedCount++;
            LoggerService.instance
                .d('🧹 Cleaned up old image: ${path.basename(file.path)}');
          }
        } catch (e) {
          LoggerService.instance
              .d('Warning: Could not check/delete ${file.path}: $e');
        }
      }

      return deletedCount;
    } catch (e) {
      LoggerService.instance.d('❌ Error during cleanup: $e');
      return 0;
    }
  }

  /// 파일 확장자 추출 (소문자로 변환)
  static String _getFileExtension(String filePath) {
    final ext = path.extension(filePath).toLowerCase();

    // 지원하는 확장자인지 확인
    if (_supportedExtensions.contains(ext)) {
      return ext;
    }

    // 기본값으로 .jpg 사용
    return '.jpg';
  }

  /// 🔍 특정 모임 ID에 속하는 이미지 파일들 검색
  ///
  /// [meetingId] 모임 고유 ID
  ///
  /// Returns: 해당 모임의 이미지 파일명들
  static Future<List<String>> findImagesByMeetingId(String meetingId) async {
    try {
      final meetingDir = await _getMeetingImagesDirectory();

      if (!await meetingDir.exists()) return [];

      final files = meetingDir.listSync().whereType<File>().toList();
      final matchingFiles = <String>[];

      for (final file in files) {
        final fileName = path.basename(file.path);

        // 파일명이 meetingId로 시작하는지 확인
        if (fileName.startsWith('${meetingId}_')) {
          matchingFiles.add(fileName);
        }
      }

      // 파일명 기준으로 정렬 (생성 순서 유지)
      matchingFiles.sort();

      return matchingFiles;
    } catch (e) {
      LoggerService.instance
          .d('❌ Error finding images for meeting $meetingId: $e');
      return [];
    }
  }
}
