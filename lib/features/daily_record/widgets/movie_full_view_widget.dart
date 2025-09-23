// lib/features/daily_record/widgets/movie_full_view_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/record_colors.dart';
import '../presentation/screens/movie_detail_screen.dart';
import '../presentation/screens/movie_edit_screen.dart';
import '../presentation/screens/movie_add_screen.dart';
import '../../../shared/providers/global_user_provider.dart';
import '../../../shared/utils/haptic_feedback_manager.dart';
import '../../../shared/models/global_user_model.dart';

class MovieFullViewWidget extends ConsumerStatefulWidget {
  const MovieFullViewWidget({super.key});

  @override
  ConsumerState<MovieFullViewWidget> createState() =>
      _MovieFullViewWidgetState();
}

class _MovieFullViewWidgetState extends ConsumerState<MovieFullViewWidget>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(globalUserProvider);
    final movieLogs = user.dailyRecords.movieLogs;

    // 선택된 월의 영화 로그 필터링
    final monthlyLogs = movieLogs.where((log) {
      return log.date.year == _selectedMonth.year &&
          log.date.month == _selectedMonth.month;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.black87, size: 20),
          ),
        ),
        title: Text(
          '영화 기록',
          style: GoogleFonts.notoSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // 배경 그라데이션
            Container(
              height: 280,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFEF4444),
                    Color(0xFFDC2626),
                  ],
                ),
              ),
            ),

            // 메인 콘텐츠
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 120), // AppBar 공간

                  // 월 선택 컨트롤
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildMonthSelector(monthlyLogs),
                  ),

                  const SizedBox(height: 24),

                  // 달력 그리드
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildCalendarGrid(monthlyLogs),
                  ),

                  const SizedBox(height: 24),

                  // 장르 범례
                  if (monthlyLogs.isNotEmpty)
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildGenreLegend(monthlyLogs),
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector(List<MovieLog> monthlyLogs) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              onPressed: () {
                setState(() {
                  _selectedMonth =
                      DateTime(_selectedMonth.year, _selectedMonth.month - 1);
                });
                HapticFeedbackManager.lightImpact();
              },
              icon: const Icon(
                Icons.chevron_left_rounded,
                color: Color(0xFFEF4444),
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                children: [
                  Text(
                    '${_selectedMonth.year}년 ${_selectedMonth.month}월',
                    style: GoogleFonts.notoSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: RecordColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getMonthMessage(monthlyLogs),
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: RecordColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              onPressed: () {
                setState(() {
                  _selectedMonth =
                      DateTime(_selectedMonth.year, _selectedMonth.month + 1);
                });
                HapticFeedbackManager.lightImpact();
              },
              icon: const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFEF4444),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthMessage(List<MovieLog> monthlyLogs) {
    final count = monthlyLogs.length;
    if (count == 0) {
      return '아직 영화 기록이 없어요';
    } else if (count <= 3) {
      return '좋은 시작이에요!';
    } else if (count <= 8) {
      return '영화 감상을 즐기고 계시네요!';
    } else {
      return '영화광이시네요! 👑';
    }
  }

  Widget _buildCalendarGrid(List<MovieLog> monthlyLogs) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // 요일 헤더
          Row(
            children: ['일', '월', '화', '수', '목', '금', '토'].map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: RecordColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // 달력 그리드
          ..._buildCalendarRows(monthlyLogs),
        ],
      ),
    );
  }

  List<Widget> _buildCalendarRows(List<MovieLog> monthlyLogs) {
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final startDate = firstDay.subtract(Duration(days: firstDay.weekday % 7));

    List<Widget> rows = [];
    DateTime currentDate = startDate;

    while (currentDate.isBefore(lastDay.add(const Duration(days: 1)))) {
      List<Widget> weekDays = [];

      for (int i = 0; i < 7; i++) {
        final dayMovies = monthlyLogs
            .where((log) =>
                log.date.year == currentDate.year &&
                log.date.month == currentDate.month &&
                log.date.day == currentDate.day)
            .toList();

        weekDays.add(_buildCalendarDay(currentDate, dayMovies));
        currentDate = currentDate.add(const Duration(days: 1));
      }

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: weekDays),
        ),
      );
    }

    return rows;
  }

  Widget _buildCalendarDay(DateTime date, List<MovieLog> dayMovies) {
    final isCurrentMonth = date.month == _selectedMonth.month;
    final isToday = _isToday(date);
    final hasMovies = dayMovies.isNotEmpty;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onDateTap(date, dayMovies),
        child: Container(
          height: 45,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isToday
                ? const Color(0xFFEF4444).withValues(alpha: 0.1)
                : hasMovies
                    ? Colors.white
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isToday
                  ? const Color(0xFFEF4444)
                  : hasMovies
                      ? const Color(0xFFEF4444).withValues(alpha: 0.2)
                      : Colors.transparent,
              width: isToday ? 2 : 1,
            ),
          ),
          child: Stack(
            children: [
              // 날짜 텍스트
              Center(
                child: Text(
                  '${date.day}',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isCurrentMonth
                        ? (isToday
                            ? const Color(0xFFEF4444)
                            : RecordColors.textPrimary)
                        : RecordColors.textLight,
                  ),
                ),
              ),

              // 영화 표시
              if (hasMovies)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: dayMovies.length > 1
                          ? const Color(0xFFEF4444)
                          : _getGenreColor(dayMovies.first.genre),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: dayMovies.length > 1
                          ? Text(
                              '${dayMovies.length}',
                              style: GoogleFonts.notoSans(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _getGenreEmoji(dayMovies.first.genre),
                              style: const TextStyle(fontSize: 8),
                            ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenreLegend(List<MovieLog> monthlyLogs) {
    final genreMap = <String, Color>{};
    for (final movie in monthlyLogs) {
      genreMap[movie.genre] = _getGenreColor(movie.genre);
    }

    final genres = genreMap.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '장르별 색상',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: RecordColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: genres.map((entry) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: entry.value,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    entry.key,
                    style: GoogleFonts.notoSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: RecordColors.textSecondary,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  void _onDateTap(DateTime date, List<MovieLog> dayMovies) {
    HapticFeedbackManager.lightImpact();

    if (dayMovies.isEmpty) {
      // 영화가 없는 경우 - 빈 날짜 모달
      _showEmptyDateModal(date);
    } else if (dayMovies.length == 1) {
      // 영화가 하나만 있는 경우 - 단일 영화 모달
      _showSingleMovieModal(date, dayMovies.first);
    } else {
      // 여러 영화가 있는 경우 - 다중 영화 모달
      _showMultipleMoviesModal(date, dayMovies);
    }
  }

  void _showEmptyDateModal(DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 핸들
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: RecordColors.textLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 헤더
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.calendar_month,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${date.month}월 ${date.day}일',
                            style: GoogleFonts.notoSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: RecordColors.textPrimary,
                            ),
                          ),
                          Text(
                            '아직 영화 기록이 없어요',
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: RecordColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 빈 날짜 콘텐츠
              _buildEmptyDateContent(date),

              // 영화 기록 작성하기 버튼
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
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
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add, size: 20),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSingleMovieModal(DateTime date, MovieLog movie) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 핸들
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: RecordColors.textLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 헤더
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _getGenreEmoji(movie.genre),
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${date.month}월 ${date.day}일',
                            style: GoogleFonts.notoSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: RecordColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${movie.genre} 영화',
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: RecordColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 단일 영화 미리보기
              _buildSingleMoviePreview(movie),

              // 영화 기록 작성하기 버튼
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
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
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '새 영화 기록 작성하기',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMultipleMoviesModal(DateTime date, List<MovieLog> movies) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 핸들
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: RecordColors.textLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 헤더
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.movie,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${date.month}월 ${date.day}일',
                            style: GoogleFonts.notoSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: RecordColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${movies.length}편 감상',
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: RecordColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 영화 목록
              _buildMultipleMoviesList(movies),

              // 영화 기록 작성하기 버튼
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
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
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '새 영화 기록 작성하기',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyDateContent(DateTime date) {
    final now = DateTime.now();
    final isToday = _isToday(date);
    final isPast = date.isBefore(now.subtract(const Duration(days: 1)));

    String emoji;
    String title;
    String subtitle;
    List<String> suggestions;

    if (isToday) {
      emoji = '🎬';
      title = '오늘 영화를 감상해보는 건 어떨까요?';
      subtitle = '새로운 영화와의 만남을 기록해보세요';
      suggestions = [
        '어떤 장르의 영화를 좋아하세요?',
        '최근 보고 싶었던 영화가 있나요?',
        '친구들과 함께 볼 영화를 찾아보세요',
        '평점이 높은 영화를 추천받아보세요'
      ];
    } else if (isPast) {
      emoji = '🎭';
      title = '${date.month}월 ${date.day}일의 영화 기록';
      subtitle = '그날 감상한 영화가 있다면 기록해보세요';
      suggestions = [
        '어떤 영화를 보셨나요?',
        '영화의 인상적인 장면이 있었나요?',
        '감독이나 배우 연기는 어땠나요?',
        '다른 사람에게 추천하고 싶은 영화인가요?'
      ];
    } else {
      emoji = '🍿';
      title = '앞으로 볼 영화 계획';
      subtitle = '보고 싶은 영화나 계획을 미리 기록해보세요';
      suggestions = [
        '어떤 영화를 보고 싶으세요?',
        '기대하는 개봉 예정 영화가 있나요?',
        '친구들과 함께 볼 영화를 계획해보세요',
        '영화관에서 볼지 집에서 볼지 정해보세요'
      ];
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFEF4444).withValues(alpha: 0.05),
                  const Color(0xFFDC2626).withValues(alpha: 0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  emoji,
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: GoogleFonts.notoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: RecordColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: RecordColors.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: RecordColors.textLight.withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.lightbulb_outline,
                        color: Color(0xFFEF4444),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '이런 걸 기록해보는 건 어떨까요?',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: RecordColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...suggestions.map((suggestion) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            margin: const EdgeInsets.only(top: 8, right: 12),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              suggestion,
                              style: GoogleFonts.notoSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: RecordColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSingleMoviePreview(MovieLog movie) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFEF4444).withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color:
                          _getGenreColor(movie.genre).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        _getGenreEmoji(movie.genre),
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.movieTitle,
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: RecordColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              movie.director,
                              style: GoogleFonts.notoSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: RecordColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              movie.genre,
                              style: GoogleFonts.notoSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _getGenreColor(movie.genre),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      movie.rating.round(),
                      (index) => const Icon(
                        Icons.star,
                        size: 16,
                        color: Color(0xFFFBBF24),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (movie.review != null && movie.review!.isNotEmpty) ...[
                Text(
                  movie.review!,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: RecordColors.textPrimary,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 14,
                    color: RecordColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${movie.watchTimeMinutes}분',
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: RecordColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  if (movie.isShared)
                    const Icon(
                      Icons.share,
                      size: 14,
                      color: RecordColors.primary,
                    ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetailScreen(movie: movie),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side:
                        const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.visibility, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '자세히 보기',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieEditScreen(movie: movie),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.edit, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '수정하기',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMultipleMoviesList(List<MovieLog> movies) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];

          return Container(
            margin:
                EdgeInsets.only(bottom: index == movies.length - 1 ? 0 : 12),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MovieDetailScreen(movie: movie),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color:
                            _getGenreColor(movie.genre).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          _getGenreEmoji(movie.genre),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.movieTitle,
                            style: GoogleFonts.notoSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: RecordColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                movie.director,
                                style: GoogleFonts.notoSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: RecordColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                movie.genre,
                                style: GoogleFonts.notoSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: _getGenreColor(movie.genre),
                                ),
                              ),
                              const Spacer(),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(
                                  movie.rating.round(),
                                  (index) => const Icon(
                                    Icons.star,
                                    size: 12,
                                    color: Color(0xFFFBBF24),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: RecordColors.textLight,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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

  Color _getGenreColor(String genre) {
    switch (genre) {
      case '드라마':
        return const Color(0xFFEF4444);
      case '액션':
        return const Color(0xFFDC2626);
      case 'SF':
        return const Color(0xFF3B82F6);
      case '로맨스':
        return const Color(0xFFEC4899);
      case '코미디':
        return const Color(0xFFF59E0B);
      case '스릴러':
        return const Color(0xFF6B7280);
      case '공포':
        return const Color(0xFF1F2937);
      case '애니메이션':
        return const Color(0xFF10B981);
      case '다큐멘터리':
        return const Color(0xFF8B5CF6);
      case '뮤지컬':
        return const Color(0xFFF97316);
      case '범죄':
        return const Color(0xFF991B1B);
      case '전쟁':
        return const Color(0xFF374151);
      case '판타지':
        return const Color(0xFF7C3AED);
      default:
        return const Color(0xFFEF4444);
    }
  }
}
