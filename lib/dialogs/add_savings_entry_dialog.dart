import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../constants/app_constants.dart';
import '../models/savings_category.dart';
import '../models/savings_entry.dart';
import '../providers/savings_providers.dart';
import '../theme/app_theme.dart';

class AddSavingsEntryDialog extends ConsumerStatefulWidget {
  final SavingsEntry? entryToEdit;
  final SavingsCategory? initialCategory;

  const AddSavingsEntryDialog({
    super.key,
    this.entryToEdit,
    this.initialCategory,
  });

  @override
  ConsumerState<AddSavingsEntryDialog> createState() =>
      _AddSavingsEntryDialogState();
}

class _AddSavingsEntryDialogState
    extends ConsumerState<AddSavingsEntryDialog> {
  SavingsCategory? _selectedCategory;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _alternativeSpendingController = TextEditingController();
  final _wouldHaveSpentController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedMood;
  String? _selectedDifficulty;
  final List<String> _selectedTags = [];
  bool _isLoading = false;

  final List<String> _moodOptions = ['Mutlu', 'Normal', 'Üzgün', 'Stresli', 'Yorgun'];
  final List<String> _difficultyOptions = ['Kolay', 'Orta', 'Zor'];
  final List<String> _locationOptions = ['Evde', 'Okulda', 'İşte', 'Dışarıda', 'Yolda'];

  @override
  void initState() {
    super.initState();
    if (widget.entryToEdit != null) {
      final entry = widget.entryToEdit!;
      _amountController.text = entry.amount.toStringAsFixed(0);
      _noteController.text = entry.note ?? '';
      _alternativeSpendingController.text = entry.alternativeSpending ?? '';
      _wouldHaveSpentController.text = entry.wouldHaveSpent?.toStringAsFixed(0) ?? '';
      _locationController.text = entry.location ?? '';
      _selectedMood = entry.mood;
      _selectedDifficulty = entry.difficulty;
      _selectedTags.clear();
      if (entry.tags != null) _selectedTags.addAll(entry.tags!);
      _selectedDate = entry.date;
    } else {
      _selectedCategory = widget.initialCategory;
      if (_selectedCategory != null) {
        _amountController.text = _selectedCategory!.defaultAmount.toStringAsFixed(0);
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.entryToEdit != null && _selectedCategory == null) {
      final categories = ref.read(savingsCategoriesProvider);
      final entry = widget.entryToEdit!;
      _selectedCategory = categories.firstWhere(
        (c) => c.id == entry.categoryId,
        orElse: () => categories.isNotEmpty ? categories.first : SavingsCategory(
          name: 'Genel',
          defaultAmount: 0,
          icon: Icons.category,
          color: const Color(0xFFC9A882),
        ),
      );
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _alternativeSpendingController.dispose();
    _wouldHaveSpentController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _save() async {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir kategori seçin')),
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
      final wouldHaveSpent = _wouldHaveSpentController.text.isEmpty
          ? null
          : double.tryParse(_wouldHaveSpentController.text);

      final entry = SavingsEntry(
        id: widget.entryToEdit?.id,
        categoryId: _selectedCategory!.id,
        amount: amount,
        date: _selectedDate,
        note: _noteController.text.isEmpty ? null : _noteController.text,
        alternativeSpending: _alternativeSpendingController.text.isEmpty
            ? null
            : _alternativeSpendingController.text,
        wouldHaveSpent: wouldHaveSpent,
        location: _locationController.text.isEmpty ? null : _locationController.text,
        mood: _selectedMood,
        difficulty: _selectedDifficulty,
        tags: _selectedTags.isEmpty ? null : _selectedTags,
      );

      if (widget.entryToEdit != null) {
        await ref.read(savingsEntriesProvider.notifier).updateEntry(entry);
      } else {
        await ref.read(savingsEntriesProvider.notifier).addEntry(entry);
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
    final categories = ref.watch(savingsCategoriesProvider);

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
                  widget.entryToEdit != null
                      ? 'Tasarruf Düzenle'
                      : 'Yeni Tasarruf Ekle',
                  style: textStyles.titlePage,
                ),
                const SizedBox(height: AppSizes.paddingXL),
                
                // Kategori seçimi
                if (categories.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(AppSizes.paddingL),
                    decoration: BoxDecoration(
                      color: colors.outline.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: colors.textSecondary),
                        const SizedBox(width: AppSizes.paddingS),
                        Expanded(
                          child: Text(
                            'Henüz kategori yok. Önce kategori ekleyin.',
                            style: textStyles.bodySecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  Text('Kategori', style: textStyles.bodyBold),
                  const SizedBox(height: AppSizes.paddingS),
                  Wrap(
                    spacing: AppSizes.paddingS,
                    runSpacing: AppSizes.paddingS,
                    children: categories.map((category) {
                    final isSelected = _selectedCategory?.id == category.id;
                    return ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(category.icon, size: 16, color: category.color),
                          const SizedBox(width: 4),
                          Text(category.name),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          _selectedCategory = category;
                          if (_amountController.text.isEmpty ||
                              _amountController.text == '0') {
                            _amountController.text =
                                category.defaultAmount.toStringAsFixed(0);
                          }
                        });
                        HapticFeedback.selectionClick();
                      },
                      selectedColor: category.color.withValues(alpha: 0.2),
                      checkmarkColor: category.color,
                    );
                  }).toList(),
                  ),
                ],
                const SizedBox(height: AppSizes.paddingL),
                
                // Miktar
                Text('Miktar (₺)', style: textStyles.bodyBold),
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
                
                // Tarih
                Text('Tarih', style: textStyles.bodyBold),
                const SizedBox(height: AppSizes.paddingS),
                InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(AppSizes.radiusL),
                  child: Container(
                    padding: const EdgeInsets.all(AppSizes.paddingM),
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.outline),
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: colors.textSecondary),
                        const SizedBox(width: AppSizes.paddingS),
                        Text(
                          DateFormat('dd MMMM yyyy').format(_selectedDate),
                          style: textStyles.body,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingL),
                
                // Not
                Text('Not (Opsiyonel)', style: textStyles.bodyBold),
                const SizedBox(height: AppSizes.paddingS),
                TextField(
                  controller: _noteController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Örn: Okulda yedim',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingL),
                
                // Alternatif harcama
                Text('Alternatif Harcama (Opsiyonel)', style: textStyles.bodyBold),
                const SizedBox(height: AppSizes.paddingS),
                TextField(
                  controller: _alternativeSpendingController,
                  decoration: InputDecoration(
                    hintText: 'Örn: Dışardan olsaydı 300₺',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingL),
                
                // Diğer türlü harcanacak miktar
                Text('Diğer Türlü Harcanacak Miktar (₺)', style: textStyles.bodyBold),
                const SizedBox(height: AppSizes.paddingS),
                TextField(
                  controller: _wouldHaveSpentController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Örn: 350₺ (dışardan yemek)',
                    prefixText: '₺ ',
                    helperText: 'Bu alanı doldurursanız zarar hesaplaması yapılır',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingL),
                
                // Konum
                Text('Konum (Opsiyonel)', style: textStyles.bodyBold),
                const SizedBox(height: AppSizes.paddingS),
                DropdownButtonFormField<String>(
                  initialValue: _locationController.text.isEmpty ? null : _locationController.text,
                  decoration: InputDecoration(
                    hintText: 'Konum seçin',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                    ),
                  ),
                  items: _locationOptions.map((location) {
                    return DropdownMenuItem(
                      value: location,
                      child: Text(location),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _locationController.text = value ?? '';
                    });
                  },
                ),
                const SizedBox(height: AppSizes.paddingL),
                
                // Ruh hali
                Text('Ruh Hali (Opsiyonel)', style: textStyles.bodyBold),
                const SizedBox(height: AppSizes.paddingS),
                Wrap(
                  spacing: AppSizes.paddingS,
                  children: _moodOptions.map((mood) {
                    final isSelected = _selectedMood == mood;
                    return FilterChip(
                      key: ValueKey('mood_$mood'),
                      label: Text(mood),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedMood = selected ? mood : null;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSizes.paddingL),
                
                // Zorluk seviyesi
                Text('Zorluk Seviyesi (Opsiyonel)', style: textStyles.bodyBold),
                const SizedBox(height: AppSizes.paddingS),
                Wrap(
                  spacing: AppSizes.paddingS,
                  children: _difficultyOptions.map((difficulty) {
                    final isSelected = _selectedDifficulty == difficulty;
                    return FilterChip(
                      key: ValueKey('difficulty_$difficulty'),
                      label: Text(difficulty),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedDifficulty = selected ? difficulty : null;
                        });
                      },
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

