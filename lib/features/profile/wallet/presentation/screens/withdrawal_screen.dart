import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/modern_colors.dart';
import '../../../../../shared/widgets/sherpa_clean_app_bar.dart';
import '../../../../../shared/widgets/sherpa_card.dart';
import '../../../../../shared/models/point_system_model.dart';
import '../../../../../shared/providers/global_point_provider.dart';

class WithdrawalScreen extends ConsumerStatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  ConsumerState<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends ConsumerState<WithdrawalScreen> {
  final TextEditingController _pointsController = TextEditingController();
  int _withdrawalPoints = 0;
  int _withdrawalAmount = 0;
  int _withdrawalFee = 0;

  @override
  void dispose() {
    _pointsController.dispose();
    super.dispose();
  }

  void _calculateWithdrawal(String value) {
    final points = int.tryParse(value) ?? 0;
    setState(() {
      _withdrawalPoints = points;
      _withdrawalAmount = _calculateWithdrawalAmount(points);
      _withdrawalFee = _calculateWithdrawalFee(points);
    });
  }

  int _calculateWithdrawalAmount(int points) {
    final won = points * PointSystemConfig.POINT_TO_WON_RATIO;
    return (won * (1 - PointSystemConfig.WITHDRAWAL_FEE_RATE)).round();
  }

  int _calculateWithdrawalFee(int points) {
    final won = points * PointSystemConfig.POINT_TO_WON_RATIO;
    return (won * PointSystemConfig.WITHDRAWAL_FEE_RATE).round();
  }

  @override
  Widget build(BuildContext context) {
    final pointData = ref.watch(globalPointProvider);

    return Scaffold(
      backgroundColor: ModernColors.background,
      appBar: const SherpaCleanAppBar(
        title: '포인트 출금',
        backgroundColor: ModernColors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentBalance(pointData.totalPoints.toInt()),
            const SizedBox(height: 24),
            _buildWithdrawalInput(),
            const SizedBox(height: 24),
            if (_withdrawalPoints > 0) ...[
              _buildWithdrawalCalculation(),
              const SizedBox(height: 24),
            ],
            _buildWithdrawalButton(context, ref, pointData.totalPoints.toInt()),
            const SizedBox(height: 24),
            _buildWithdrawalInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentBalance(int totalPoints) {
    return SherpaCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '💰 현재 보유 포인트',
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ModernColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${totalPoints}P',
              style: GoogleFonts.notoSans(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: ModernColors.primary,
              ),
            ),
            Text(
              '= $totalPoints원',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                color: ModernColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ModernColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: ModernColors.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: ModernColors.warning,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '최소 출금 금액: 10,000P (10,000원)',
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: ModernColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildWithdrawalInput() {
    return SherpaCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '출금할 포인트',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ModernColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pointsController,
              keyboardType: TextInputType.number,
              onChanged: _calculateWithdrawal,
              decoration: InputDecoration(
                hintText: '출금할 포인트를 입력하세요',
                suffixText: 'P',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: ModernColors.primary),
                ),
              ),
              style: GoogleFonts.notoSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildQuickAmountButton('10,000P', 10000),
                const SizedBox(width: 8),
                _buildQuickAmountButton('50,000P', 50000),
                const SizedBox(width: 8),
                _buildQuickAmountButton('100,000P', 100000),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAmountButton(String label, int amount) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          _pointsController.text = amount.toString();
          _calculateWithdrawal(amount.toString());
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: ModernColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.notoSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: ModernColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildWithdrawalCalculation() {
    return SherpaCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📊 출금 계산',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ModernColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildCalculationRow(
                '출금 포인트', '${_withdrawalPoints}P', ModernColors.primary),
            _buildCalculationRow(
                '원화 환산', '$_withdrawalPoints원', ModernColors.textSecondary),
            _buildCalculationRow(
                '출금 수수료 (10%)', '-$_withdrawalFee원', ModernColors.error),
            const Divider(height: 24),
            _buildCalculationRow(
                '실제 받는 금액', '$_withdrawalAmount원', ModernColors.success,
                isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationRow(String label, String value, Color color,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
              color: ModernColors.textPrimary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.notoSans(
              fontSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalButton(
      BuildContext context, WidgetRef ref, int totalPoints) {
    final canWithdraw =
        _withdrawalPoints >= PointSystemConfig.MIN_WITHDRAWAL_POINTS &&
            _withdrawalPoints <= totalPoints;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canWithdraw ? () => _requestWithdrawal(context, ref) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canWithdraw ? ModernColors.primary : Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          canWithdraw ? '출금 요청하기' : '출금 조건을 확인해주세요',
          style: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildWithdrawalInfo() {
    return SherpaCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📋 출금 안내',
              style: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ModernColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoItem('• 최소 출금 금액: 10,000포인트 (10,000원)'),
            _buildInfoItem('• 출금 수수료: 10%'),
            _buildInfoItem('• 처리 시간: 영업일 기준 1-3일'),
            _buildInfoItem('• 출금 가능 시간: 평일 09:00 - 18:00'),
            _buildInfoItem('• 계좌 정보는 프로필에서 미리 등록해주세요'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: GoogleFonts.notoSans(
          fontSize: 14,
          color: ModernColors.textSecondary,
        ),
      ),
    );
  }

  void _requestWithdrawal(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '출금 요청 확인',
          style: GoogleFonts.notoSans(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('출금 포인트: ${_withdrawalPoints}P'),
            Text('출금 수수료: $_withdrawalFee원'),
            Text('실제 받는 금액: $_withdrawalAmount원'),
            const SizedBox(height: 12),
            Text(
              '출금을 요청하시겠습니까?',
              style: GoogleFonts.notoSans(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: 실제 출금 로직 구현
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('출금 요청이 완료되었습니다!'),
                  backgroundColor: ModernColors.success,
                ),
              );
            },
            child: const Text('출금 요청'),
          ),
        ],
      ),
    );
  }
}
