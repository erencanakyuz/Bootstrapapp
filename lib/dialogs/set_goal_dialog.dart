import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../models/savings_goal.dart';
import '../providers/savings_providers.dart';
import '../theme/app_theme.dart';

class SetGoalDialog extends ConsumerStatefulWidget {
  const SetGoalDialog({super.key});

  @override
  ConsumerState<SetGoalDialog> createState() => _SetGoalDialogState();
}

class _SetGoalDialogState extends ConsumerState<SetGoalDialog> {
  final _amountController = TextEditingController();
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentGoal = ref.read(savingsGoalProvider);
    if (currentGoal != null && currentGoal.isCurrentMonth() && _amountController.text.isEmpty) {
      _amountController.text = currentGoal.targetAmount.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçerli bir miktar girin')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final goal = SavingsGoal(
        targetAmount: amount,
        month: now.month,
        year: now.year,
      );

      await ref.read(savingsGoalProvider.notifier).setGoal(goal);

      if (mounted) {
        Navigator.of(context).pop();
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textStyles = AppTextStyles(colors);
    final currentGoal = ref.watch(savingsGoalProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppSizes.paddingL),
      child: Container(
        decoration: BoxDecoration(
          color: colors.elevatedSurface,
          borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
          boxShadow: AppShadows.cardStrong(null),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentGoal != null && currentGoal.isCurrentMonth()
                    ? 'Hedefi Düzenle'
                    : 'Aylık Hedef Belirle',
                style: textStyles.titlePage,
              ),
              const SizedBox(height: AppSizes.paddingXL),
              
              Text(
                'Bu ay için ne kadar tasarruf etmeyi hedefliyorsunuz?',
                style: textStyles.body,
              ),
              const SizedBox(height: AppSizes.paddingL),
              
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  hintText: '0',
                  prefixText: '₺ ',
                  labelText: 'Hedef Miktar',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  ),
                ),
                autofocus: true,
              ),
              const SizedBox(height: AppSizes.paddingXL),
              
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: Text('İptal', style: textStyles.buttonLabelGhost),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.textPrimary,
                        foregroundColor: colors.surface,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSizes.paddingM,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusL),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text('Kaydet', style: textStyles.buttonLabel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

