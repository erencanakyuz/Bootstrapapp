import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/motivation_service.dart';
import '../theme/app_theme.dart';

/// Clean Apple-style daily motivation widget
class DailyMotivationWidget extends ConsumerStatefulWidget {
  const DailyMotivationWidget({super.key});

  @override
  ConsumerState<DailyMotivationWidget> createState() => _DailyMotivationWidgetState();
}

class _DailyMotivationWidgetState extends ConsumerState<DailyMotivationWidget> {
  String? _quote;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _quote = MotivationService.getQuoteOfDay();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    if (_quote == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: colors.elevatedSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.15),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() => _isExpanded = !_isExpanded);
            HapticFeedback.lightImpact();
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    // Quote icon
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.format_quote_rounded,
                        color: colors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title
                    Text(
                      'Daily Inspiration',
                      style: GoogleFonts.fraunces(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    // Expand icon
                    Icon(
                      _isExpanded
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      size: 20,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Quote text
                Text(
                  _quote!,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: colors.textSecondary,
                    letterSpacing: 0,
                  ),
                  maxLines: _isExpanded ? null : 3,
                  overflow: _isExpanded ? null : TextOverflow.ellipsis,
                ),
                if (!_isExpanded && _quote!.length > 100)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Tap to read more',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colors.primary,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

