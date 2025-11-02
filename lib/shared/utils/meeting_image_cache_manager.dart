// lib/shared/utils/meeting_image_cache_manager.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 모임 이미지 캐시 매니저
/// 이미지를 메모리에 캐싱하여 반복적인 로딩을 방지하고 성능을 최적화합니다.
class MeetingImageCacheManager {
  static final MeetingImageCacheManager _instance =
      MeetingImageCacheManager._internal();
  factory MeetingImageCacheManager() => _instance;
  MeetingImageCacheManager._internal();

  // 메모리 캐시
  final Map<String, ImageProvider> _memoryCache = {};
  final Map<String, Uint8List> _bytesCache = {};

  // 캐시 메타데이터
  final Map<String, DateTime> _cacheTimestamps = {};
  final Map<String, int> _cacheHitCount = {};

  // 캐시 설정
  static const int maxCacheSize = 50; // 최대 캐시 이미지 개수
  static const Duration cacheExpiry = Duration(hours: 24); // 캐시 만료 시간
  static const int maxMemoryUsageMB = 100; // 최대 메모리 사용량 (MB)

  // 현재 메모리 사용량 추적
  int _currentMemoryUsage = 0;

  /// 이미지 프리로드 (인기있는 모임 등)
  Future<void> preloadImages(List<String> imagePaths) async {
    for (final path in imagePaths) {
      if (!_memoryCache.containsKey(path)) {
        await _loadAndCacheImage(path);
      }
    }
  }

  /// 캐시된 이미지 위젯 반환
  Widget getCachedImage(
    String? imagePath, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    // imagePath가 null이거나 비어있으면 플레이스홀더 반환
    if (imagePath == null || imagePath.isEmpty) {
      return placeholder ?? _buildDefaultPlaceholder();
    }

    // 캐시 확인 및 정리
    _cleanExpiredCache();

    // 캐시 히트 카운트 업데이트
    _cacheHitCount[imagePath] = (_cacheHitCount[imagePath] ?? 0) + 1;

    // 이미지 타입 확인
    if (_isDynamicImagePath(imagePath)) {
      return _buildCachedFileImage(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        placeholder: placeholder,
        errorWidget: errorWidget,
      );
    } else {
      return _buildCachedAssetImage(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        placeholder: placeholder,
        errorWidget: errorWidget,
      );
    }
  }

  /// 파일 이미지 캐싱 및 반환
  Widget _buildCachedFileImage(
    String imagePath, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    // 메모리 캐시 확인
    if (_memoryCache.containsKey(imagePath)) {
      return Image(
        image: _memoryCache[imagePath]!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ?? _buildDefaultErrorWidget(),
      );
    }

    // 캐시 미스 - 이미지 로드 및 캐싱
    final file = File(imagePath);
    if (file.existsSync()) {
      final imageProvider = FileImage(file);
      _cacheImage(imagePath, imageProvider);

      return Image(
        image: imageProvider,
        width: width,
        height: height,
        fit: fit,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) {
            return child;
          }
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: child,
          );
        },
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ?? _buildDefaultErrorWidget(),
      );
    }

    return errorWidget ?? _buildDefaultErrorWidget();
  }

  /// 에셋 이미지 캐싱 및 반환
  Widget _buildCachedAssetImage(
    String imagePath, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    // 메모리 캐시 확인
    if (_memoryCache.containsKey(imagePath)) {
      return Image(
        image: _memoryCache[imagePath]!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ?? _buildDefaultErrorWidget(),
      );
    }

    // 캐시 미스 - 이미지 로드 및 캐싱
    final imageProvider = AssetImage(imagePath);
    _cacheImage(imagePath, imageProvider);

    return Image(
      image: imageProvider,
      width: width,
      height: height,
      fit: fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        }
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: child,
        );
      },
      errorBuilder: (context, error, stackTrace) =>
          errorWidget ?? _buildDefaultErrorWidget(),
    );
  }

  /// 이미지를 캐시에 추가
  void _cacheImage(String path, ImageProvider imageProvider) {
    // 캐시 크기 제한 확인
    if (_memoryCache.length >= maxCacheSize) {
      _evictLeastUsedImage();
    }

    _memoryCache[path] = imageProvider;
    _cacheTimestamps[path] = DateTime.now();
  }

  /// 비동기 이미지 로드 및 캐싱
  Future<void> _loadAndCacheImage(String imagePath) async {
    try {
      if (_isDynamicImagePath(imagePath)) {
        final file = File(imagePath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          _bytesCache[imagePath] = bytes;
          _memoryCache[imagePath] = MemoryImage(bytes);
          _cacheTimestamps[imagePath] = DateTime.now();
        }
      } else {
        // Asset 이미지는 AssetBundle을 통해 로드
        final data = await rootBundle.load(imagePath);
        final bytes = data.buffer.asUint8List();
        _bytesCache[imagePath] = bytes;
        _memoryCache[imagePath] = MemoryImage(bytes);
        _cacheTimestamps[imagePath] = DateTime.now();
      }
    } catch (e) {
    }
  }

  /// 가장 적게 사용된 이미지 제거
  void _evictLeastUsedImage() {
    if (_memoryCache.isEmpty) return;

    String? leastUsedKey;
    int minHitCount = 999999;

    for (final key in _memoryCache.keys) {
      final hitCount = _cacheHitCount[key] ?? 0;
      if (hitCount < minHitCount) {
        minHitCount = hitCount;
        leastUsedKey = key;
      }
    }

    if (leastUsedKey != null) {
      _removeFromCache(leastUsedKey);
    }
  }

  /// 만료된 캐시 정리
  void _cleanExpiredCache() {
    final now = DateTime.now();
    final keysToRemove = <String>[];

    _cacheTimestamps.forEach((key, timestamp) {
      if (now.difference(timestamp) > cacheExpiry) {
        keysToRemove.add(key);
      }
    });

    for (final key in keysToRemove) {
      _removeFromCache(key);
    }
  }

  /// 캐시에서 이미지 제거
  void _removeFromCache(String key) {
    _memoryCache.remove(key);
    _bytesCache.remove(key);
    _cacheTimestamps.remove(key);
    _cacheHitCount.remove(key);
  }

  /// 전체 캐시 초기화
  void clearCache() {
    _memoryCache.clear();
    _bytesCache.clear();
    _cacheTimestamps.clear();
    _cacheHitCount.clear();
    _currentMemoryUsage = 0;
  }

  /// 동적 이미지 경로인지 확인
  bool _isDynamicImagePath(String path) {
    return !path.startsWith('assets/') &&
        (path.contains('/') || path.endsWith('.jpg') || path.endsWith('.png'));
  }

  /// 기본 플레이스홀더 위젯
  Widget _buildDefaultPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[300]!,
            Colors.grey[200]!,
          ],
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  /// 기본 에러 위젯
  Widget _buildDefaultErrorWidget() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[400]!,
            Colors.grey[300]!,
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.image_not_supported_rounded,
          size: 32,
          color: Colors.white54,
        ),
      ),
    );
  }

  /// 캐시 상태 정보 반환 (디버깅용)
  Map<String, dynamic> getCacheStats() {
    return {
      'cacheSize': _memoryCache.length,
      'memoryUsage':
          '${(_currentMemoryUsage / 1024 / 1024).toStringAsFixed(2)} MB',
      'hitCounts': _cacheHitCount,
      'oldestCache': _cacheTimestamps.isNotEmpty
          ? _cacheTimestamps.entries
              .reduce((a, b) => a.value.isBefore(b.value) ? a : b)
              .key
          : null,
    };
  }
}
