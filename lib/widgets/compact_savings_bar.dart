import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../providers/savings_providers.dart';
import '../theme/app_theme.dart';

/// Compact savings bar for home screen top
/// Shows today and total savings in a minimal glassmorphic design
class CompactSavingsBar extends ConsumerStatefulWidget {
  const CompactSavingsBar({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  ConsumerState<CompactSavingsBar> createState() => _CompactSavingsBarState();
}

class _CompactSavingsBarState extends ConsumerState<CompactSavingsBar> {
  static const String _betaShownKey = 'savings_beta_shown';

  Future<void> _handleTap() async {
    HapticFeedback.lightImpact();

    // Check if beta message has been shown
    final prefs = await SharedPreferences.getInstance();
    final hasShown = prefs.getBool(_betaShownKey) ?? false;

    if (!hasShown && mounted) {
      // Show beta dialog once
      await _showBetaDialog();
      await prefs.setBool(_betaShownKey, true);
    } else {
      // Navigate to details
      widget.onTap();
    }
  }

  Future<void> _showBetaDialog() async {
    final colors = Theme.of(context).extension<AppColors>()!;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.success.withValues(alpha: 0.2),
                    colors.success.withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.science_outlined,
                size: 48,
                color: colors.success,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Beta Özellik',
              style: GoogleFonts.fraunces(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tasarruf takibi özelliği şu anda beta aşamasındadır. Verileriniz güvenle saklanmaktadır.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onTap();
            },
            child: Text(
              'Anladım',
              style: TextStyle(
                color: colors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final todayAmount = ref.watch(todaySavingsProvider);
    final totalAmount = ref.watch(totalSavingsProvider);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: colors.success.withValues(alpha: 0.1),
        highlightColor: colors.success.withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                colors.success.withValues(alpha: 0.12),
                colors.success.withValues(alpha: 0.08),
                colors.success.withValues(alpha: 0.05),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colors.success.withValues(alpha: 0.25),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.success.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.success.withValues(alpha: 0.25),
                      colors.success.withValues(alpha: 0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.savings_rounded,
                  color: colors.success,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),

              // Today amount
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TASARRUF',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: colors.success,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Bugün ₺${todayAmount.toStringAsFixed(0)}',
                      style: GoogleFonts.fraunces(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),

              // Divider
              Container(
                width: 1,
                height: 32,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colors.success.withValues(alpha: 0.0),
                      colors.success.withValues(alpha: 0.3),
                      colors.success.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),

              // Total amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'TOPLAM',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: colors.success.withValues(alpha: 0.7),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₺${totalAmount.toStringAsFixed(0)}',
                    style: GoogleFonts.fraunces(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 8),

              // Arrow
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: colors.success.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
