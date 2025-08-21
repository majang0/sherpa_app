import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:math' as math;

class DailyMotivationWidget extends StatefulWidget {
  @override
  State<DailyMotivationWidget> createState() => _DailyMotivationWidgetState();
}

class _DailyMotivationWidgetState extends State<DailyMotivationWidget>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;

  String _todayMotivation = '';
  String _todayEmoji = '';
  Color _todayColor = Colors.blue;

  final List<Map<String, dynamic>> _motivations = [
    {
      'text': '오늘도 한 걸음씩 성장해나가요! 🌱',
      'emoji': '🌱',
      'color': Color(0xFF4CAF50),
    },
    {
      'text': '작은 성취도 큰 변화의 시작이에요! ⭐',
      'emoji': '⭐',
      'color': Color(0xFFFF9800),
    },
    {
      'text': '당신의 잠재력이 빛나고 있어요! ✨',
      'emoji': '✨',
      'color': Color(0xFF9C27B0),
    },
    {
      'text': '오늘 하루도 멋진 모험이 될 거예요! 🚀',
      'emoji': '🚀',
      'color': Color(0xFF2196F3),
    },
    {
      'text': '함께 성장하는 여정, 응원해요! 💪',
      'emoji': '💪',
      'color': Color(0xFFE91E63),
    },
  ];

  @override
  void initState() {
    super.initState();

    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _floatingAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _floatingController.repeat(reverse: true);
    _generateDailyMotivation();
  }

  void _generateDailyMotivation() {
    final today = DateTime.now();
    final random = math.Random(today.day + today.month + today.year);
    final motivation = _motivations[random.nextInt(_motivations.length)];

    setState(() {
      _todayMotivation = motivation['text'];
      _todayEmoji = motivation['emoji'];
      _todayColor = motivation['color'];
    });
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatingAnimation.value),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _todayColor.withValues(alpha: 0.1),
                  _todayColor.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _todayColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _todayColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _todayEmoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        _todayMotivation,
                        textStyle: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _todayColor,
                        ),
                        speed: const Duration(milliseconds: 50),
                      ),
                    ],
                    totalRepeatCount: 1,
                    displayFullTextOnTap: true,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
