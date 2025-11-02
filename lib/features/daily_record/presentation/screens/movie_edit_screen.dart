// lib/features/daily_record/presentation/screens/movie_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/modern_colors.dart';
import '../../../../shared/utils/haptic_feedback_manager.dart';
import 'package:sherpa_app/shared/providers/level_1_user_data/global_user_provider.dart';
import '../../../../shared/models/global_user_model.dart';

class MovieEditScreen extends ConsumerStatefulWidget {
  final MovieLog movie;

  const MovieEditScreen({super.key, required this.movie});

  @override
  ConsumerState<MovieEditScreen> createState() => _MovieEditScreenState();
}

class _MovieEditScreenState extends ConsumerState<MovieEditScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  final TextEditingController _reviewController = TextEditingController();
  double _rating = 3.0;
  bool _isShared = false;
  bool _isSubmitting = false;

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

    // 기존 영화 데이터 로드
    _reviewController.text = widget.movie.review ?? '';
    _rating = widget.movie.rating;
    _isShared = widget.movie.isShared;

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
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        actions: [
          Container(
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
              onPressed: _isSubmitting ? null : _saveMovie,
              icon: Icon(
                Icons.check,
                color: _isSubmitting ? Colors.grey : const Color(0xFFEF4444),
                size: 20,
              ),
            ),
          ),
        ],
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

                  // 헤더 섹션
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildHeader(),
                  ),

                  const SizedBox(height: 24),

                  // 변경 불가능한 정보 섹션
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildReadOnlyInfo(),
                  ),

                  const SizedBox(height: 20),

                  // 평점 섹션
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildRatingSection(),
                  ),

                  const SizedBox(height: 20),

                  // 리뷰 섹션
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildReviewSection(),
                  ),

                  const SizedBox(height: 20),

                  // 공유 설정 섹션
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildShareSection(),
                  ),

                  const SizedBox(height: 32),

                  // 저장 버튼
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildSaveButton(),
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

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 카테고리 아이콘과 정보
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFEF4444),
                      Color(0xFFDC2626),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '영화 기록 수정',
                      style: GoogleFonts.notoSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '평점, 리뷰, 공유 설정을 수정할 수 있어요',
                      style: GoogleFonts.notoSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: ModernColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ModernColors.textTertiary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.lock_outlined,
                    color: ModernColors.textSecondary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '변경 불가 정보',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ModernColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: ModernColors.textTertiary.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  _buildReadOnlyInfoRow('🎬', '영화 제목', widget.movie.movieTitle),
                  const SizedBox(height: 12),
                  _buildReadOnlyInfoRow('🎭', '감독', widget.movie.director),
                  const SizedBox(height: 12),
                  _buildReadOnlyInfoRow(_getGenreEmoji(widget.movie.genre),
                      '장르', widget.movie.genre),
                  const SizedBox(height: 12),
                  _buildReadOnlyInfoRow(
                      '📅', '관람일', _formatDate(widget.movie.date)),
                  const SizedBox(height: 12),
                  _buildReadOnlyInfoRow(
                      '⏰', '상영시간', '${widget.movie.watchTimeMinutes}분'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '영화 제목, 감독, 장르, 관람일, 상영시간은 수정할 수 없습니다',
              style: GoogleFonts.notoSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: ModernColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyInfoRow(String emoji, String label, String value) {
    return Row(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: ModernColors.textSecondary,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.notoSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ModernColors.textPrimary,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBBF24).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Color(0xFFFBBF24),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '평점',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ModernColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_rating.toStringAsFixed(1)}/5.0',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFFBBF24),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFBBF24).withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) {
                        final starValue = index + 1;
                        final isFullStar = _rating >= starValue;
                        final isHalfStar =
                            _rating >= starValue - 0.5 && _rating < starValue;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_rating == starValue) {
                                _rating = (starValue - 0.5).clamp(0.5, 5.0);
                              } else {
                                _rating = starValue.toDouble();
                              }
                            });
                            HapticFeedbackManager.lightImpact();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Stack(
                              children: [
                                const Icon(
                                  Icons.star_border,
                                  size: 32,
                                  color: Color(0xFFFBBF24),
                                ),
                                if (isFullStar)
                                  const Icon(
                                    Icons.star,
                                    size: 32,
                                    color: Color(0xFFFBBF24),
                                  )
                                else if (isHalfStar)
                                  const ClipRect(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: 0.5,
                                      child: Icon(
                                        Icons.star,
                                        size: 32,
                                        color: Color(0xFFFBBF24),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFFFBBF24),
                      inactiveTrackColor:
                          const Color(0xFFFBBF24).withValues(alpha: 0.2),
                      thumbColor: const Color(0xFFFBBF24),
                      overlayColor:
                          const Color(0xFFFBBF24).withValues(alpha: 0.2),
                      trackHeight: 6,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 12),
                    ),
                    child: Slider(
                      value: _rating,
                      min: 1.0,
                      max: 5.0,
                      divisions: 8,
                      onChanged: (value) {
                        setState(() {
                          _rating = value;
                        });
                        HapticFeedbackManager.lightImpact();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.edit_note,
                    color: Color(0xFFEF4444),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '리뷰',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ModernColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(선택사항)',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: ModernColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _reviewController,
                maxLines: 4,
                maxLength: 300,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '영화에 대한 생각이나 느낌을 자유롭게 적어보세요...',
                  hintStyle: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: ModernColors.textTertiary,
                  ),
                  counterText: '',
                ),
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ModernColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.share,
                    color: Color(0xFFEF4444),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '공유 설정',
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ModernColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isShared ? Icons.public : Icons.lock,
                    color: const Color(0xFFEF4444),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isShared ? '공개' : '비공개',
                          style: GoogleFonts.notoSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ModernColors.textPrimary,
                          ),
                        ),
                        Text(
                          _isShared ? '다른 사용자가 볼 수 있어요' : '나만 볼 수 있어요',
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: ModernColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isShared,
                    onChanged: (value) {
                      setState(() {
                        _isShared = value;
                      });
                      HapticFeedbackManager.lightImpact();
                    },
                    activeColor: const Color(0xFFEF4444),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEF4444).withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _saveMovie,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.save, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '수정 완료',
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    return '${date.year}년 ${date.month}월 ${date.day}일 (${weekdays[date.weekday % 7]})';
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

  void _saveMovie() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    HapticFeedbackManager.mediumImpact();

    try {
      final updatedMovie = MovieLog(
        id: widget.movie.id,
        date: widget.movie.date,
        movieTitle: widget.movie.movieTitle,
        director: widget.movie.director,
        genre: widget.movie.genre,
        rating: _rating,
        review: _reviewController.text.isEmpty ? null : _reviewController.text,
        watchTimeMinutes: widget.movie.watchTimeMinutes,
        isShared: _isShared,
      );

      // 영화 로그 업데이트 (새로 추가한 updateMovieLog 메서드 사용)
      ref.read(globalUserProvider.notifier).updateMovieLog(updatedMovie);

      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context); // 상세보기 화면도 닫기

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '영화 기록이 수정되었습니다! 🎬',
              style: GoogleFonts.notoSans(fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '수정 중 오류가 발생했습니다. 다시 시도해주세요.',
              style: GoogleFonts.notoSans(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
