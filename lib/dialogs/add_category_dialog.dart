import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../models/savings_category.dart';
import '../providers/savings_providers.dart';
import '../theme/app_theme.dart';

class AddCategoryDialog extends ConsumerStatefulWidget {
  final SavingsCategory? categoryToEdit;

  const AddCategoryDialog({
    super.key,
    this.categoryToEdit,
  });

  @override
  ConsumerState<AddCategoryDialog> createState() =>
      _AddCategoryDialogState();
}

class _AddCategoryDialogState extends ConsumerState<AddCategoryDialog> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  IconData _selectedIcon = Icons.category;
  Color _selectedColor = const Color(0xFFC9A882);
  bool _isLoading = false;

  final List<IconData> _icons = [
    // Gıda & İçecek
    Icons.smoking_rooms,
    Icons.restaurant,
    Icons.coffee,
    Icons.fastfood,
    Icons.local_bar,
    Icons.cookie,
    Icons.cake,
    Icons.icecream,
    // Ulaşım
    Icons.directions_bus,
    Icons.local_taxi,
    Icons.local_gas_station,
    Icons.directions_car,
    Icons.train,
    Icons.flight,
    Icons.directions_bike,
    // Eğlence
    Icons.movie,
    Icons.music_note,
    Icons.sports_esports,
    Icons.people,
    Icons.theater_comedy,
    Icons.sports_soccer,
    Icons.casino,
    // Alışveriş
    Icons.shopping_bag,
    Icons.shopping_cart,
    Icons.checkroom,
    Icons.store,
    Icons.storefront,
    // Abonelikler
    Icons.subscriptions,
    Icons.play_circle,
    Icons.phone_android,
    Icons.wifi,
    Icons.computer,
    Icons.tv,
    // Kişisel Bakım
    Icons.content_cut,
    Icons.face,
    Icons.spa,
    Icons.shower,
    Icons.self_improvement,
    // Sağlık
    Icons.medication,
    Icons.fitness_center,
    Icons.local_hospital,
    Icons.health_and_safety,
    // Eğitim
    Icons.school,
    Icons.menu_book,
    Icons.library_books,
    Icons.person,
    // Diğer
    Icons.attach_money,
    Icons.card_giftcard,
    Icons.local_florist,
    Icons.local_laundry_service,
    Icons.edit,
    Icons.category,
    Icons.savings,
    Icons.hotel,
    Icons.phone,
    Icons.book,
    Icons.home,
    Icons.work,
  ];

  final List<Color> _colors = [
    // Bej tonları (mevcut tema)
    const Color(0xFF6B7D5A),
    const Color(0xFFB87D7D),
    const Color(0xFFC9A882),
    const Color(0xFF7A9B9B),
    const Color(0xFF9B8FA8),
    const Color(0xFF8B7A6A),
    const Color(0xFF7A8B7A),
    const Color(0xFF8B9B7A),
    // Renkli tonlar
    const Color(0xFFE74C3C), // Kırmızı
    const Color(0xFF3498DB), // Mavi
    const Color(0xFF2ECC71), // Yeşil
    const Color(0xFFF39C12), // Turuncu
    const Color(0xFF9B59B6), // Mor
    const Color(0xFF1ABC9C), // Turkuaz
    const Color(0xFFE67E22), // Turuncu-koyu
    const Color(0xFF16A085), // Yeşil-koyu
    const Color(0xFF2980B9), // Mavi-koyu
    const Color(0xFF8E44AD), // Mor-koyu
    const Color(0xFFC0392B), // Kırmızı-koyu
    const Color(0xFFD35400), // Turuncu-koyu
    const Color(0xFF27AE60), // Yeşil (success)
  ];

  @override
  void initState() {
    super.initState();
    if (widget.categoryToEdit != null) {
      final category = widget.categoryToEdit!;
      _nameController.text = category.name;
      _amountController.text = category.defaultAmount.toStringAsFixed(0);
      _selectedIcon = category.icon;
      _selectedColor = category.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir isim girin')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçerli bir miktar girin')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final category = SavingsCategory(
        id: widget.categoryToEdit?.id,
        name: _nameController.text,
        defaultAmount: amount,
        icon: _selectedIcon,
        color: _selectedColor,
        isCustom: true,
      );

      if (widget.categoryToEdit != null) {
        await ref.read(savingsCategoriesProvider.notifier).updateCategory(category);
      } else {
        await ref.read(savingsCategoriesProvider.notifier).addCategory(category);
      }

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

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppSizes.paddingL),
      child: Container(
        decoration: BoxDecoration(
          color: colors.elevatedSurface,
          borderRadius: BorderRadius.circular(AppSizes.radiusXXL),
          boxShadow: AppShadows.cardStrong(null),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingXL),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.categoryToEdit != null
                      ? 'Kategori Düzenle'
                      : 'Yeni Kategori Ekle',
                  style: textStyles.titlePage,
                ),
                const SizedBox(height: AppSizes.paddingXL),
                
                // İsim
                Text('İsim', style: textStyles.bodyBold),
                const SizedBox(height: AppSizes.paddingS),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Örn: Sigara',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingL),
                
                // Miktar
                Text('Varsayılan Miktar (₺)', style: textStyles.bodyBold),
                const SizedBox(height: AppSizes.paddingS),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  decoration: InputDecoration(
                    hintText: '0',
                    prefixText: '₺ ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingL),
                
                // İkon seçimi
                Text('İkon', style: textStyles.bodyBold),
                const SizedBox(height: AppSizes.paddingS),
                Wrap(
                  spacing: AppSizes.paddingS,
                  runSpacing: AppSizes.paddingS,
                  children: _icons.map((icon) {
                    final isSelected = _selectedIcon == icon;
                    return InkWell(
                      onTap: () {
                        setState(() => _selectedIcon = icon);
                        HapticFeedback.selectionClick();
                      },
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _selectedColor.withValues(alpha: 0.2)
                              : colors.outline.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                          border: Border.all(
                            color: isSelected
                                ? _selectedColor
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: isSelected ? _selectedColor : colors.textSecondary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSizes.paddingL),
                
                // Renk seçimi
                Text('Renk', style: textStyles.bodyBold),
                const SizedBox(height: AppSizes.paddingS),
                Wrap(
                  spacing: AppSizes.paddingS,
                  runSpacing: AppSizes.paddingS,
                  children: _colors.map((color) {
                    final isSelected = _selectedColor == color;
                    return InkWell(
                      onTap: () {
                        setState(() => _selectedColor = color);
                        HapticFeedback.selectionClick();
                      },
                      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? colors.textPrimary
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: isSelected
                            ? Icon(Icons.check, color: Colors.white, size: 20)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSizes.paddingXL),
                
                // Butonlar
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
      ),
    );
  }
}

