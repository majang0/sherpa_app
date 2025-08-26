// lib/features/meetings/presentation/widgets/meeting_creation_steps/quick_datetime_picker.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/modern_colors.dart';

/// 📅 빠른 날짜/시간 선택 - Step 3
/// 직관적인 캘린더와 시간 선택 UI
class QuickDateTimePicker extends StatefulWidget {
  final DateTime? selectedDateTime;
  final Function(DateTime) onDateTimeSelected;

  const QuickDateTimePicker({
    super.key,
    required this.selectedDateTime,
    required this.onDateTimeSelected,
  });

  @override
  State<QuickDateTimePicker> createState() => _QuickDateTimePickerState();
}

class _QuickDateTimePickerState extends State<QuickDateTimePicker> {
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay selectedTime = TimeOfDay(hour: 14, minute: 0);
  
  // 빠른 선택 옵션
  final List<Map<String, dynamic>> quickOptions = [
    {
      'label': '내일 오후 2시',
      'date': DateTime.now().add(const Duration(days: 1)),
      'time': const TimeOfDay(hour: 14, minute: 0),
    },
    {
      'label': '이번 주말 오전 10시',
      'date': DateTime.now().add(Duration(
        days: 6 - DateTime.now().weekday,
      )),
      'time': const TimeOfDay(hour: 10, minute: 0),
    },
    {
      'label': '다음 주 월요일 오후 7시',
      'date': DateTime.now().add(Duration(
        days: 8 - DateTime.now().weekday,
      )),
      'time': const TimeOfDay(hour: 19, minute: 0),
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.selectedDateTime != null) {
      selectedDate = widget.selectedDateTime!;
      selectedTime = TimeOfDay.fromDateTime(widget.selectedDateTime!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 설명 텍스트
          Text(
            '모임 날짜와 시간을 선택해주세요',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: ModernColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 빠른 선택 옵션
          _buildQuickOptions()
            .animate()
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.1, end: 0, duration: 200.ms),
          
          const SizedBox(height: 32),
          
          // 구분선
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '또는 직접 선택',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    color: ModernColors.textSecondary,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300)),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // 날짜 선택
          _buildDateSelector()
            .animate()
            .fadeIn(delay: 100.ms, duration: 300.ms)
            .slideY(begin: 0.1, end: 0, duration: 200.ms),
          
          const SizedBox(height: 24),
          
          // 시간 선택
          _buildTimeSelector()
            .animate()
            .fadeIn(delay: 200.ms, duration: 300.ms)
            .slideY(begin: 0.1, end: 0, duration: 200.ms),
          
          const SizedBox(height: 32),
          
          // 선택된 날짜/시간 미리보기
          _buildPreview()
            .animate()
            .fadeIn(delay: 300.ms, duration: 300.ms)
            .slideY(begin: 0.1, end: 0, duration: 200.ms),
        ],
      ),
    );
  }

  /// ⚡ 빠른 선택 옵션
  Widget _buildQuickOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '빠른 선택',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ModernColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        
        ...quickOptions.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  final dateTime = DateTime(
                    option['date'].year,
                    option['date'].month,
                    option['date'].day,
                    option['time'].hour,
                    option['time'].minute,
                  );
                  
                  setState(() {
                    selectedDate = option['date'];
                    selectedTime = option['time'];
                  });
                  
                  widget.onDateTimeSelected(dateTime);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: ModernColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.schedule_rounded,
                          color: ModernColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          option['label'],
                          style: GoogleFonts.notoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ModernColors.textPrimary,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: ModernColors.textSecondary,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ).animate()
            .fadeIn(
              delay: Duration(milliseconds: 100 * index),
              duration: 300.ms,
            )
            .slideX(
              begin: 0.1,
              end: 0,
              delay: Duration(milliseconds: 100 * index),
              duration: 200.ms,
            );
        }).toList(),
      ],
    );
  }

  /// 📅 날짜 선택
  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '날짜',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ModernColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _showDatePicker,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: ModernColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _formatDate(selectedDate),
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ModernColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    color: ModernColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// ⏰ 시간 선택
  Widget _buildTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '시간',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ModernColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        
        // 인기 시간대 버튼들
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildTimeChip('오전 10:00', const TimeOfDay(hour: 10, minute: 0)),
              _buildTimeChip('오후 2:00', const TimeOfDay(hour: 14, minute: 0)),
              _buildTimeChip('오후 6:00', const TimeOfDay(hour: 18, minute: 0)),
              _buildTimeChip('오후 7:00', const TimeOfDay(hour: 19, minute: 0)),
              _buildTimeChip('직접 선택', null),
            ],
          ),
        ),
      ],
    );
  }

  /// ⏰ 시간 칩
  Widget _buildTimeChip(String label, TimeOfDay? time) {
    final isSelected = time != null && 
        selectedTime.hour == time.hour && 
        selectedTime.minute == time.minute;
    final isCustom = time == null;
    
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (isCustom) {
              _showTimePicker();
            } else {
              setState(() => selectedTime = time!);
              _updateDateTime();
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isSelected || isCustom
                ? ModernColors.primary
                : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected || isCustom
                  ? ModernColors.primary
                  : Colors.grey.shade300,
              ),
            ),
            child: Text(
              isCustom ? label : label,
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected || isCustom
                  ? Colors.white
                  : ModernColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 👀 미리보기
  Widget _buildPreview() {
    final dateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ModernColors.primary.withOpacity(0.1),
            ModernColors.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ModernColors.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: ModernColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.event_available_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '모임 일정',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: ModernColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${_formatDate(selectedDate)} ${_formatTime(selectedTime)}',
                      style: GoogleFonts.notoSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: ModernColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 확인 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onDateTimeSelected(dateTime),
              style: ElevatedButton.styleFrom(
                backgroundColor: ModernColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                '이 시간으로 확정',
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 📅 날짜 선택 다이얼로그
  void _showDatePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ko', 'KR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: ModernColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (date != null) {
      setState(() => selectedDate = date);
      _updateDateTime();
    }
  }

  /// ⏰ 시간 선택 다이얼로그
  void _showTimePicker() async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: ModernColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (time != null) {
      setState(() => selectedTime = time);
      _updateDateTime();
    }
  }

  /// 📅 날짜 포맷
  String _formatDate(DateTime date) {
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[date.weekday - 1];
    
    final now = DateTime.now();
    final daysDiff = DateTime(date.year, date.month, date.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
    
    if (daysDiff == 0) {
      return '오늘 ($weekday)';
    } else if (daysDiff == 1) {
      return '내일 ($weekday)';
    } else if (daysDiff == 2) {
      return '모레 ($weekday)';
    } else {
      return '${date.month}월 ${date.day}일 ($weekday)';
    }
  }

  /// ⏰ 시간 포맷
  String _formatTime(TimeOfDay time) {
    final period = time.hour < 12 ? '오전' : '오후';
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final hourStr = hour == 0 ? 12 : hour;
    final minuteStr = time.minute.toString().padLeft(2, '0');
    
    return '$period ${hourStr}:${minuteStr}';
  }

  /// 🔄 날짜/시간 업데이트
  void _updateDateTime() {
    final dateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    
    // 자동으로 다음 단계로 넘어가지 않고 미리보기만 업데이트
    setState(() {});
  }
}