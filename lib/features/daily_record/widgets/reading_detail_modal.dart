// lib/features/daily_record/widgets/reading_detail_modal.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/record_colors.dart';
import '../presentation/screens/reading_record_screen.dart';
import '../presentation/screens/reading_detail_screen.dart';
import '../utils/reading_utils.dart';
import '../../../shared/models/global_user_model.dart';
import '../../../shared/utils/haptic_feedback_manager.dart';

class ReadingDetailModal extends StatelessWidget {
  final ReadingLog readingLog;
  final DateTime? selectedDate;

  const ReadingDetailModal({
    Key? key,
    required this.readingLog,
    this.selectedDate,
  }) : super(key: key);

  static void show(
    BuildContext context, 
    ReadingLog readingLog, {
    DateTime? selectedDate,
  }) {
    HapticFeedbackManager.lightImpact();
    
    // 새로운 전체 화면으로 네비게이션
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReadingDetailScreen(
          readingLog: readingLog,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 이 클래스는 이제 단순히 네비게이션을 위한 wrapper 역할만 합니다.
    // 실제 UI는 ReadingDetailScreen에서 처리됩니다.
    return const SizedBox.shrink();
  }
}