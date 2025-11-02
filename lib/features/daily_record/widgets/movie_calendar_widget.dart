// lib/features/daily_record/widgets/movie_calendar_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/modern_colors.dart';
import 'package:sherpa_app/shared/providers/level_1_user_data/global_user_provider.dart';
import '../../../shared/models/global_user_model.dart';
import '../../../shared/utils/haptic_feedback_manager.dart';
import 'movie_full_view_widget.dart';
import '../presentation/screens/movie_detail_screen.dart';
import '../presentation/screens/movie_add_screen.dart';

class MovieCalendarWidget extends ConsumerStatefulWidget {
  const MovieCalendarWidget({super.key});

  @override
  ConsumerState<MovieCalendarWidget> createState() =>
      _MovieCalendarWidgetState();
}

class _MovieCalendarWidgetState extends ConsumerState<MovieCalendarWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    Future.delayed(const Duration(milliseconds: 1400), () {
      _slideController.forward();
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(globalUserProvider);
    final movieLogs = user.dailyRecords.movieLogs;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: ModernColors.borderLight,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444).withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.movie,
                      color: Color(0xFFEF4444),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '영화 기록',
                          style: GoogleFonts.notoSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: ModernColors.textPrimary,
                          ),
                        ),
                        Text(
                          '감상한 영화들을 기록하세요',
                          style: GoogleFonts.notoSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: ModernColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 추가 버튼
                  GestureDetector(
                    onTap: () {
                      HapticFeedbackManager.mediumImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MovieAddScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFFEF4444).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 이번 달 통계
              _buildMonthlyStats(movieLogs),

              const SizedBox(height: 20),

              // 장르별 분석
              if (movieLogs.isNotEmpty) _buildGenreAnalysis(movieLogs),

              const SizedBox(height: 20),

              // 전체 보기 버튼
              _buildFullViewButton(),

              const SizedBox(height: 20),

              // 최근 영화 기록들
              if (movieLogs.isNotEmpty) ...[
                Text(
                  '최근 감상 영화',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ModernColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ...movieLogs.take(3).map((movie) => _buildMovieItem(movie)),
              ] else
                _buildEmptyState(),

              const SizedBox(height: 24),

              // 영화 기록 작성하기 버튼
              _buildWriteButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthlyStats(List<MovieLog> movieLogs) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final thisMonthMovies = movieLogs
        .where((log) =>
            log.date.isAfter(monthStart.subtract(const Duration(days: 1))))
        .toList();

    final totalMovies = thisMonthMovies.length;
    final totalWatchTime =
        thisMonthMovies.fold<int>(0, (sum, log) => sum + log.watchTimeMinutes);
    final avgRating = thisMonthMovies.isEmpty
        ? 0.0
        : thisMonthMovies.fold<double>(0, (sum, log) => sum + log.rating) /
            thisMonthMovies.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFEF4444).withValues(alpha: 0.1),
            const Color(0xFFDC2626).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFEF4444).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              '🎬',
              '$totalMovies편',
              '이번 달',
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: ModernColors.textTertiary.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _buildStatItem(
              '⏱️',
              '${(totalWatchTime / 60).toStringAsFixed(1)}시간',
              '총 감상시간',
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: ModernColors.textTertiary.withValues(alpha: 0.3),
          ),
          Expanded(
            child: _buildStatItem(
              '⭐',
              avgRating > 0 ? '${avgRating.toStringAsFixed(1)}/5.0' : '-',
              '평균 평점',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFEF4444),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: ModernColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildGenreAnalysis(List<MovieLog> movieLogs) {
    // 장르별 통계 계산
    final genreStats = <String, Map<String, dynamic>>{};

    for (final log in movieLogs) {
      if (!genreStats.containsKey(log.genre)) {
        genreStats[log.genre] = {
          'count': 0,
          'totalRating': 0.0,
          'emoji': _getGenreEmoji(log.genre),
        };
      }
      genreStats[log.genre]!['count']++;
      genreStats[log.genre]!['totalRating'] += log.rating;
    }

    // 개수 기준으로 정렬
    final sortedGenres = genreStats.entries.toList()
      ..sort((a, b) => b.value['count'].compareTo(a.value['count']));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '선호 장르 분석',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ModernColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ModernColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ModernColors.borderLight,
              width: 1,
            ),
          ),
          child: Row(
            children: sortedGenres.take(4).map((entry) {
              final isFirst = entry == sortedGenres.first;
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isFirst
                            ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isFirst
                              ? const Color(0xFFEF4444).withValues(alpha: 0.3)
                              : ModernColors.textTertiary
                                  .withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          entry.value['emoji'],
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      entry.key,
                      style: GoogleFonts.notoSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isFirst
                            ? const Color(0xFFEF4444)
                            : ModernColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${entry.value['count']}편',
                      style: GoogleFonts.notoSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: ModernColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMovieItem(MovieLog movie) {
    return GestureDetector(
      onTap: () {
        HapticFeedbackManager.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailScreen(movie: movie),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ModernColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ModernColors.borderLight,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // 장르 아이콘
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  _getGenreEmoji(movie.genre),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // 영화 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          movie.movieTitle,
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: ModernColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ...List.generate(
                        movie.rating.round(),
                        (index) => const Icon(
                          Icons.star,
                          size: 12,
                          color: Color(0xFFFBBF24),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        movie.director,
                        style: GoogleFonts.notoSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: ModernColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        movie.genre,
                        style: GoogleFonts.notoSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFEF4444),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${movie.date.month}/${movie.date.day}',
                        style: GoogleFonts.notoSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: ModernColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 공유 아이콘
            if (movie.isShared)
              const Icon(
                Icons.share,
                size: 14,
                color: ModernColors.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ModernColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ModernColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          const Text(
            '🎬',
            style: TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 8),
          Text(
            '아직 영화 기록이 없어요',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ModernColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '감상한 영화를 기록해보세요',
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: ModernColors.textTertiary,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              HapticFeedbackManager.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MovieAddScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.add,
                    size: 16,
                    color: Color(0xFFEF4444),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '첫 영화 기록하기',
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildFullViewButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: OutlinedButton(
        onPressed: () {
          HapticFeedbackManager.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MovieFullViewWidget(),
            ),
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFEF4444),
          side: BorderSide(
            color: const Color(0xFFEF4444).withValues(alpha: 0.3),
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.calendar_view_month,
              color: Color(0xFFEF4444),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              '전체 영화 기록 보기',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWriteButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedbackManager.mediumImpact();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MovieAddScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEF4444),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          shadowColor: const Color(0xFFEF4444).withValues(alpha: 0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.movie, size: 20),
            const SizedBox(width: 8),
            Text(
              '영화 기록 작성하기',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGenreEmoji(String genre) {
    switch (genre) {
      case '드라마':
        return '🎭';
      case '액션':
        return '💥';
      case 'SF':
        return '🚀';
      case '로맨스':
        return '💕';
      case '코미디':
        return '😂';
      case '스릴러':
        return '😱';
      case '공포':
        return '👻';
      case '애니메이션':
        return '🎨';
      case '다큐멘터리':
        return '📹';
      case '뮤지컬':
        return '🎵';
      case '범죄':
        return '🔍';
      case '전쟁':
        return '⚔️';
      case '판타지':
        return '🪄';
      default:
        return '🎬';
    }
  }
}
